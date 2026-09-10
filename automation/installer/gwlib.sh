#!/usr/bin/env bash
# gwlib.sh -- shared helpers for the Groundwire installer and its supervisor.
#
# THIS FILE IS THE SOURCE. It ships in the release tarball beside gw-vere and
# tcp-sidecar, and causeway/public/boot.sh installs it to $GW_DIR/lib/gwlib.sh
# and sources it; so does the supervisor, gwsup.sh, next to it in the tarball.
#
# It used to live inside boot.sh as a heredoc, for the honest reason that a
# script piped in from curl has no file to re-exec and the supervisor needs
# exactly these helpers. That cost boot.sh 463 of its 1,521 lines -- a third
# of the installer that a reader had to audit before they could believe the
# other two thirds, on a script that runs as you and installs a daemon
# mediating all your Bitcoin traffic. Shipping the same bytes in the tarball
# leaves boot.sh's own audit surface at "does it fetch and exec the right
# thing", which is a question you can finish before pressing return.
#
# What it costs: these are no longer covered by reading the one-liner's
# target. They are covered by the release SHA256SUMS, which boot.sh checks
# the tarball against, and by this file being in git.
#
# Expects, from the caller: GW_DIR GW_NAME GW_PIER GW_VERE GW_LOG GW_SC_LOG
#                           GW_SIDECAR GW_AMES_PORT GW_LOOM SOCK_TOOL DNS_TOOL

gwl_have() { command -v "$1" >/dev/null 2>&1; }

gwl_pick_sock_tool() {
  if [ -n "${SOCK_TOOL:-}" ]; then return 0; fi
  if gwl_have python3 && python3 -c 'print(1)' >/dev/null 2>&1; then SOCK_TOOL=python3
  elif gwl_have nc && nc -h 2>&1 | grep -q 'W recvlimit'; then SOCK_TOOL=nc-W
  elif gwl_have nc; then SOCK_TOOL=nc
  elif gwl_have socat; then SOCK_TOOL=socat
  else SOCK_TOOL=""; fi
}

# stdin: request bytes.  stdout: reply bytes.  $1: seconds to wait for the
# FIRST byte of the reply.  A ship chewing through filter-header batches has
# been measured taking 120-380 s to answer (OPERATIONS.md 5.7), so this has to
# be generous; once bytes start arriving the reply completes immediately.
# NB the connection is made from INSIDE the pier, by relative path. A unix
# socket address is capped at 104 bytes on macOS (108 on Linux), and
# <pier>/.urb/conn.sock with a 56-character comet name in it goes straight
# through that ceiling for any pier more than a couple of directories deep:
# python reports "AF_UNIX path too long", nc reports nothing at all, and the
# ship looks hung when it is in fact up and idle. Measured on a real boot.
# vere itself is unaffected -- it binds the socket from within the pier.
gwl_sock() {
  local first="${1:-60}" sock=".urb/conn.sock"
  cd "$GW_PIER" 2>/dev/null || return 1
  case "${SOCK_TOOL:-}" in
    python3) python3 -c '
import socket, sys
sock, first = sys.argv[1], float(sys.argv[2])
data = sys.stdin.buffer.read()
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(first)
try:
    s.connect(sock)
    s.sendall(data)
    out = []
    while True:
        try:
            b = s.recv(65536)
        except socket.timeout:
            break
        if not b:
            break
        out.append(b)
        s.settimeout(0.4)          # reply started; drain and go
    sys.stdout.buffer.write(b"".join(out))
except OSError as e:
    print("gwlib: control socket: %s" % e, file=sys.stderr)
finally:
    s.close()
' "$sock" "$first" ;;
    nc-W)  nc -U -W 3 -w "$first" "$sock" ;;
    nc)    nc -U -w 5 "$sock" ;;
    socat) socat -T5 - "UNIX-CONNECT:$sock" ;;
    *)     return 1 ;;
  esac
}

# Wrap a strand body (on stdin) in the khan FYRD envelope.  The body and the
# ''' delimiters must share an indentation column, so we indent both here.
gwl_thread() {
  printf '%s\n' \
    ':*  0' \
    '    %fyrd' \
    '    %base' \
    '    %khan-eval' \
    '    %noun' \
    '    %ted-eval' \
    '    :_  :~  /sur/spider/hoon' \
    '            /lib/strandio/hoon' \
    '        ==' \
    "    '''" \
    '    =/  m  (strand ,vase)' \
    '    ^-  form:m' \
    '    ;<  our=@p   bind:m  get-our' \
    '    ;<  now=@da  bind:m  get-time'
  sed 's/^/    /'
  printf '%s\n' "    '''" '=='
}

# Run a strand body (stdin) on the ship; print the decoded reply.
# $1: seconds to wait for the first byte (default 60).
# NB every pipeline in this file ends in `|| true`. gwlib.sh is sourced by a
# script running `set -eo pipefail`, where one grep that matches nothing
# would otherwise take the whole installer down -- and "no [%headers N] in
# the log yet" is the normal state for the first minute of every sync.
gwl_eval() {
  # gwl_sock cd's into the pier; it is inside a pipeline, so that cd happens
  # in a subshell and cannot leak into the caller.
  gwl_thread | "$GW_VERE" eval -jn 2>/dev/null | gwl_sock "${1:-60}" \
    | "$GW_VERE" eval -cn 2>/dev/null || true
}

# $1 agent  $2 mark  $3 vase expression  [$4 timeout]
gwl_poke() {
  printf ';<  ~  bind:m  (poke-our %%%s %%%s %s)\n(pure:m !>(%%ok))\n' "$1" "$2" "$3" \
    | gwl_eval "${4:-60}"
}

# The web login code (+code), as jael answers it.  A comet code is four
# syllable pairs (sontec-hospun-ridwep-matnep); the grep is the shape, so
# eval noise around the cord cannot leak into the answer.
gwl_code() {
  printf "(pure:m !>((crip (slag 1 (scow %%p .^(@p %%j /(scot %%p our)/code/(scot %%da now)/(scot %%p our)))))))\n" \
    | gwl_eval "${1:-90}" | grep -oE "[a-z]{6}(-[a-z]{6}){3}" | head -1 || true
}

gwl_our() {
  # A comet @p has a DOUBLE hyphen in the middle: four syllable pairs, '--',
  # four more. A '-'-only pattern matches the first half and stops, and the
  # identity check then rejects every comet ever minted. Measured on a real
  # boot: ~raclep-habfus-sogwer-tilrep for ~raclep-...-mipdeb.
  printf '(pure:m !>((scot %%p our)))\n' | gwl_eval "${1:-120}" \
    | grep -oE '~[a-z]{6}(-{1,2}[a-z]{6})+' | head -1 || true
}

# /x/ready, but ONLY if %gw-btc is actually running.  A `%gx` scry into an
# agent gall is not running -- or into a path that agent's +on-peek does not
# handle -- is not a soft miss.  It bails, and the bail takes %spider with it:
#
#   peek bad result
#   "unexpected scry into %urb-watcher on path /x/ready"
#   spider crashed, killing all strands: %arvo-response
#
# "all strands" includes kiln's OTA sync strands, one per desk carrying a
# desk.ship, and each one logs its own death:
#
#   kiln: activation failed into %groundwire from ~watwyd-.../%groundwire; retrying sync
#
# That line is about the OTA sync, not about the desk, and the desk stays
# live either way -- but it reads like an activation failure, and a --status
# run against a release whose pill predates %gw-btc printed one per desk and
# sent an afternoon chasing a bug that was not there.  Measured on a fresh
# comet booted from groundwire-daily-2026.8.7.
#
# `mule` does not help: the bail is in gall's peek, not in our nock, so it is
# not ours to catch.  The only safe guard is not to send the scry.  This is
# the same hazard the +gwl_agent_installed comment below describes; that one
# was written about %gu and the rule is general.
gwl_ready() {
  if ! gwl_agent_installed gw-btc; then return 0; fi
  printf '%s\n' \
    '=/  r  .^(* %gx /(scot %p our)/gw-btc/(scot %da now)/ready/noun)' \
    '(pure:m !>(r))' | gwl_eval "${1:-120}"
}

gwl_desks() {
  printf '%s\n' \
    ';<  dez=(set desk)  bind:m  (scry (set desk) %cd %$ /)' \
    "(pure:m !>((crip (tape (join ' ' ~(tap in dez))))))" | gwl_eval "${1:-120}"
}

# Has a gall agent been installed?  Read it out of the ship's log, not with a
# scry.  `.^(? %gu ...)` is the dojo idiom for this and it does NOT survive
# being run inside a khan thread: measured on a live ship it returns
# [%thread-fail %cancelled] even for %dojo, which is definitely running.  A
# scry a vane declines is worse than useless here -- it can bail the strand
# and take every OTHER in-flight strand on the ship down with it, including a
# running verification (see the warning in ops/gwctl.py cmd_pass).
gwl_agent_installed() {
  grep -q "gall: installing %$1\b" "$GW_LOG" 2>/dev/null
}

# -------------------------------------------------------------- processes --
# Matched exactly, never by pgrep -f prefix: p4c1 prefix-matches p4c1b, and
# killing the wrong pier is worse than killing none (OPERATIONS.md 5.9).
gwl_king_pid() {
  ps -eo pid=,args= 2>/dev/null | awk -v p="$GW_PIER" '
    /gw-vere/ && !/--snap-dir/ { for (i=2;i<=NF;i++) if ($i==p) { print $1; break } }'
}
gwl_serf_pid() {
  ps -eo pid=,args= 2>/dev/null | awk -v p="$GW_PIER" '
    /snap-dir/ { for (i=1;i<=NF;i++) if ($i=="--snap-dir" && $(i+1)==p) print $1 }'
}
gwl_proc_cwd() {
  if [ -r "/proc/$1/cwd" ]; then
    readlink "/proc/$1/cwd" 2>/dev/null
  elif gwl_have lsof; then
    lsof -a -p "$1" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1
  fi
}
# The sidecar has no port and no distinctive argv: its pier is its cwd.
gwl_sidecar_pids() {
  local pid
  for pid in $(pgrep -f 'tcp-sidecar' 2>/dev/null || true); do
    [ "$(gwl_proc_cwd "$pid")" = "$GW_PIER" ] && echo "$pid"
  done
  return 0
}

gwl_mtime() {
  if stat -c %Y "$1" >/dev/null 2>&1; then stat -c %Y "$1"
  else stat -f %m "$1" 2>/dev/null; fi
}

# Liveness is the newest mtime across <pier>/.urb/log/*/data.mdb.  The
# .urb/log DIRECTORY is a dirent that LMDB never touches -- measured 21 h
# stale on a ship demonstrably processing events (OPERATIONS.md 5.9).  Piers
# roll epochs, so glob the epoch dirs rather than assuming 0i0.
gwl_evt_age() {
  local f newest="" t now
  for f in "$GW_PIER"/.urb/log/*/data.mdb; do
    [ -f "$f" ] || continue
    t="$(gwl_mtime "$f")"
    [ -n "$t" ] || continue
    if [ -z "$newest" ] || [ "$t" -gt "$newest" ]; then newest="$t"; fi
  done
  if [ -z "$newest" ]; then echo 99999; return; fi
  now="$(date +%s)"
  echo $(( now - newest ))
}

gwl_start_sidecar() {
  [ -x "${GW_SIDECAR:-}" ] || return 1
  local cert=""
  for cert in /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem \
              /etc/pki/tls/certs/ca-bundle.crt ""; do
    [ -n "$cert" ] && [ -f "$cert" ] && break
  done
  # main.c:618 sets SSL_VERIFY_PEER with the default verify paths; a host that
  # keeps its roots somewhere unusual needs SSL_CERT_FILE pointing at them.
  ( cd "$GW_PIER" || exit 1
    if [ -n "$cert" ]; then export SSL_CERT_FILE="$cert"; fi
    if gwl_have setsid; then
      setsid nohup "$GW_SIDECAR" . >> "$GW_SC_LOG" 2>&1 </dev/null &
    else
      nohup "$GW_SIDECAR" . >> "$GW_SC_LOG" 2>&1 </dev/null &
    fi ) >/dev/null 2>&1
  sleep 3
  [ -n "$(gwl_sidecar_pids)" ]
}

gwl_start_vere_restart() {
  # The restart form: no -c, -w, -G or -B; the pier is the trailing argument.
  rm -f "$GW_PIER/.vere.lock"
  local args="-t --loom $GW_LOOM"
  [ -n "${GW_AMES_PORT:-}" ] && args="$args -p $GW_AMES_PORT"
  # Without this, every restart -- boot.sh's and the supervisor's -- silently
  # moved the web UI: vere's default is port 80 (which macOS grants to
  # unprivileged binds), while everything printed to the user says 8080.
  [ -n "${GW_HTTP_PORT:-}" ] && args="$args --http-port $GW_HTTP_PORT"
  if gwl_have setsid; then
    # shellcheck disable=SC2086
    setsid nohup "$GW_VERE" $args "$GW_PIER" >> "$GW_LOG" 2>&1 </dev/null &
  else
    # shellcheck disable=SC2086
    nohup "$GW_VERE" $args "$GW_PIER" >> "$GW_LOG" 2>&1 </dev/null &
  fi
}

# ------------------------------------------------------------- peer pool ---
# Filter headers are only servable by peers advertising NODE_COMPACT_FILTERS.
# %bitcoin-client makes it a REQUIRED service, so a pool from unfiltered DNS
# seeds leaves filter sync at height 1 forever -- the single biggest time sink
# in the procedure, and what killed the Phase 4 run (OPERATIONS.md 5.6).
# x49 = NODE_NETWORK(1) | NODE_WITNESS(8) | NODE_COMPACT_FILTERS(64).
GWL_SEEDS="seed.bitcoin.sipa.be dnsseed.bluematt.me seed.bitcoinstats.com
seed.bitcoin.jonasschnelli.ch dnsseed.emzy.de seed.bitcoin.wiz.biz
seed.btc.petertodd.net seed.bitcoin.sprovoost.nl seed.mainnet.achownodes.xyz
dnsseed.bitcoin.dashjr-list-of-p2p-nodes.us"

gwl_resolve_a() {
  case "${DNS_TOOL:-}" in
    dig)  dig +short +time=3 +tries=1 A "$1" 2>/dev/null ;;
    host) host -W 3 -t A "$1" 2>/dev/null | awk '/has address/ {print $NF}' ;;
    getent) getent ahostsv4 "$1" 2>/dev/null | awk '{print $1}' ;;
    python3) python3 -c '
import socket, sys
try:
    for r in socket.getaddrinfo(sys.argv[1], 8333, socket.AF_INET):
        print(r[4][0])
except Exception:
    pass
' "$1" ;;
    *) return 1 ;;
  esac
}

# Each seed returns a small random slice per query, so ask repeatedly.
gwl_pool_fill() {
  local rounds="${1:-6}" pool="$GW_DIR/var/peerpool.txt" s i before after
  touch "$pool"
  before="$(wc -l < "$pool" | tr -d ' ')"
  i=0
  while [ "$i" -lt "$rounds" ]; do
    for s in $GWL_SEEDS; do
      gwl_resolve_a "x49.$s"
    done
    i=$(( i + 1 ))
  done | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' \
       | grep -vE '^(0\.|10\.|127\.|169\.254\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)' \
       | sort -u >> "$pool" || true
  sort -u "$pool" -o "$pool"
  after="$(wc -l < "$pool" | tr -d ' ')"
  echo "$(( after - before ))"
}

gwl_pool_left() {
  local pool="$GW_DIR/var/peerpool.txt" used="$GW_DIR/var/used-$GW_NAME.txt"
  touch "$pool" "$used"
  # grep -c prints its 0 BEFORE exiting 1, so `|| echo 0` emitted a second
  # zero -- and "0\n0" fed to [ -lt ] errors, which bash treats as FALSE,
  # which skipped the DNS harvest entirely: one extra zero, no peers at all.
  grep -vxF -f "$used" "$pool" 2>/dev/null | grep -c . || true
}

# An IP handed to the same ship twice is wasted: %bitcoin-client's blacklist
# expiry is ~d3, so a burned seed stays burned for three days.
gwl_take_peers() {
  local n="$1" pool="$GW_DIR/var/peerpool.txt" used="$GW_DIR/var/used-$GW_NAME.txt" ips
  touch "$pool" "$used"
  ips="$(grep -vxF -f "$used" "$pool" 2>/dev/null | head -n "$n" || true)"
  [ -n "$ips" ] && printf '%s\n' "$ips" >> "$used"
  printf '%s' "$ips"
}

# A Hoon @ux literal is dot-grouped every four hex digits from the right, and
# the leading group carries no padding zeros.
gwl_hoonhex() {
  local h="$1" out=""
  while [ "${#h}" -gt 4 ]; do
    out=".${h: -4}$out"
    h="${h:0:${#h}-4}"
  done
  h="$(printf '%s' "$h" | sed 's/^0*//')"
  [ -z "$h" ] && h=0
  printf '0x%s%s' "$h" "$out"
}

gwl_ip_hoon() {
  local a b c d
  IFS=. read -r a b c d <<EOF
$1
EOF
  gwl_hoonhex "$(printf '%x' $(( (a << 24) | (b << 16) | (c << 8) | d )))"
}

# One strand for the whole batch.  ~25 at a time: adding 200-300 at once
# reliably SIGSEGVs the sidecar, after which live-earth-peers goes to 0 and
# sync stalls (gwbtc/node#1, OPERATIONS.md 5.6).
gwl_add_peers() {
  local ip vals=""
  for ip in $1; do
    vals="$vals $(gwl_ip_hoon "$ip")"
  done
  [ -n "$vals" ] || return 1
  # shellcheck disable=SC2016  # $(ips t.ips) is Hoon recursion, not shell
  { printf '=/  ips=(list @ux)  ~[%s]\n' "$vals"
    printf '|-  ^-  form:m\n'
    printf "?~  ips  (pure:m !>('done'))\n"
    printf ';<  ~  bind:m  (poke-our %%bitcoin-client %%bitcoin-client-connect-peer !>([%%ipv4 i.ips 8.333]))\n'
    printf '$(ips t.ips)\n'
  } | gwl_eval 300
}

# %bitcoin-client's ++peek is literally ~ for every path
# (bitcoin-client.hoon:181-184), so status cannot be scried: &log-info dumps
# it into the ship's log and we read it back out of there.
gwl_log_info() { gwl_poke bitcoin-client log-info '!>(~)' 30 >/dev/null 2>&1 || true; }

# $1 key, e.g. %headers.  Prints the last value seen, dots stripped.
gwl_log_last() {
  tail -n 4000 "$GW_LOG" 2>/dev/null \
    | grep -oE "\[%$1 [0-9.]+\]" | tail -1 \
    | grep -oE '[0-9.]+' | tr -d '.' || true
}
gwl_log_synced() {
  tail -n 4000 "$GW_LOG" 2>/dev/null \
    | grep -oE '\[%is-synced %\.[yn]\]' | tail -1 || true
}
