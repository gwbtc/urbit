#!/usr/bin/env bash
# gwsup.sh <name> -- supervisor for one Groundwire ship.
#
# THIS FILE IS THE SOURCE. It ships in the release tarball beside gw-vere and
# tcp-sidecar; causeway/public/boot.sh installs it to $GW_DIR/bin/gwsup.sh and
# starts it. It used to be a heredoc inside boot.sh; see gwlib.sh's header for
# why it is not any more.
#
# groundwire's ops/gwsup.sh is the campaign's version of this and it is NOT
# reused verbatim, for three reasons: it hardcodes the droplet layout
# (/opt/gw/piers/<name>, /opt/gw/bin, /opt/gw/*.log) which does not exist in a
# user-space install; it is Linux-only (flock(1), stat -c, /proc/<pid>/cwd,
# ss) and this installer supports macOS; and it shells out to four Python
# tools that expect the gwharness package importable from /opt/gw, which is
# not in any release artifact. The ALGORITHM is reused unchanged, trap for
# trap -- singleton, data.mdb liveness, exact process matching, and the
# kill-peer-connections-plus-reseed that makes a sidecar restart actually
# recover. CHANGE BOTH: keep this and groundwire's ops/gwsup.sh in sync when
# either changes.
#
# Filed against gwbtc/node#1: the tcp-sidecar SIGSEGVs, %bitcoin-client goes
# on believing its peers are live, every send returns "no such connection"
# forever, and the ship stops following the chain while looking healthy. It
# does not self-heal, and restarting the sidecar alone does NOT fix it -- the
# agent's peer table has to be cleared with &kill-peer-connections and
# re-seeded. A plain Restart=always unit gets the process back and leaves the
# ship wedged.
set -u

GW_NAME="${1:?usage: gwsup.sh <name>}"
GW_DIR="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$GW_DIR/var/$GW_NAME.env" ] || { echo "no $GW_DIR/var/$GW_NAME.env" >&2; exit 1; }
# shellcheck disable=SC1090
. "$GW_DIR/var/$GW_NAME.env"
# shellcheck disable=SC1091
. "$GW_DIR/lib/gwlib.sh"
gwl_pick_sock_tool

SUPLOG="$GW_DIR/var/sup-$GW_NAME.log"
STALE=300      # seconds with no event-log write => WEDGED
POLL=30
COOLDOWN=300   # minimum seconds between recoveries

# SINGLETON. Two supervisors on one pier both see VERE-DOWN, both relaunch,
# and the loser's ship dies on "mesa: bind: address already in use", which
# reads exactly like a crash loop. In one cleanroom run all three droplets
# were found running two supervisors per pier, which is also why ships that
# had been deliberately stopped came back. flock(1) is Linux-only, so this is
# a mkdir lock -- atomic everywhere -- with a liveness check so a supervisor
# killed with SIGKILL does not lock the pier out forever.
LOCK="$GW_DIR/var/sup-$GW_NAME.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  oldpid="$(cat "$LOCK/pid" 2>/dev/null || echo)"
  if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null &&
     ps -o args= -p "$oldpid" 2>/dev/null | grep -q gwsup.sh; then
    echo "gwsup.sh: a supervisor for $GW_NAME is already running (pid $oldpid); refusing"
    exit 0
  fi
  rm -rf "$LOCK"
  mkdir "$LOCK" 2>/dev/null || { echo "gwsup.sh: lost the lock race; refusing"; exit 0; }
fi
echo $$ > "$LOCK/pid"
trap 'rm -rf "$LOCK"' EXIT INT TERM
sleep 1
[ "$(cat "$LOCK/pid" 2>/dev/null)" = "$$" ] || { echo "gwsup.sh: lost the lock race; refusing"; exit 0; }

log() { echo "$(date -u +%FT%TZ) [$GW_NAME] $*" >> "$SUPLOG"; }

# Counters are re-derived from the log so "how often did this fire" stays a
# true cumulative number across supervisor restarts. NB `grep -c` prints 0 AND
# exits 1 when there is no match, which in the original cost a ship: the
# arithmetic that followed became a syntax error and the watchdog killed
# itself at the moment it was first needed.
_count() { local n; n="$(grep -c "$1" "$SUPLOG" 2>/dev/null | head -1)"; echo "${n:-0}"; }
N_WEDGE="$(_count 'WEDGE (recover')"
N_VERE="$(_count 'VERE-DOWN')"
N_SIDE="$(_count 'SIDECAR-DOWN')"
LAST_RECOVER=0

recover() {
  N_WEDGE=$(( N_WEDGE + 1 ))
  log "INTERVENTION #$(( N_WEDGE + N_VERE + N_SIDE )) WEDGE (recover #$N_WEDGE): $1"
  [ -n "$(gwl_sidecar_pids)" ] || gwl_start_sidecar
  sleep 3
  if gwl_poke bitcoin-client kill-peer-connections '!>(~)' 150 >/dev/null 2>&1; then
    log "  kill-peer-connections ok"
  else
    log "  kill-peer-connections FAILED (control socket unresponsive)"
  fi
  sleep 5
  left="$(gwl_pool_left)"
  [ "${left:-0}" -lt 20 ] && log "  pool refill: +$(gwl_pool_fill 4)"
  ip="$(gwl_take_peers 1)"
  # One peer, then let getaddr gossip refill: header sync asks ONE peer for
  # 2000 headers and waits, so extra peers buy resilience, not speed.
  if [ -n "$ip" ] && gwl_add_peers "$ip" >/dev/null 2>&1; then
    log "  re-seeded 1 peer: $ip"
  else
    log "  re-seed FAILED ($ip)"
  fi
  LAST_RECOVER="$(date +%s)"
}

log "supervisor start (pier=$GW_PIER stale=${STALE}s poll=${POLL}s sidecar=${GW_SIDECAR:-none})"

while true; do
  # 1. runtime alive?
  if [ -z "$(gwl_king_pid)" ] && [ -z "$(gwl_serf_pid)" ]; then
    N_VERE=$(( N_VERE + 1 ))
    log "INTERVENTION #$(( N_WEDGE + N_VERE + N_SIDE )) VERE-DOWN (restart #$N_VERE)"
    gwl_start_vere_restart
    sleep 60
    continue
  fi

  # 2. sidecar alive?  A dead sidecar IS the wedge trigger, so do not wait out
  #    the staleness window for it.
  if [ -x "${GW_SIDECAR:-}" ] && [ -z "$(gwl_sidecar_pids)" ]; then
    N_SIDE=$(( N_SIDE + 1 ))
    log "INTERVENTION #$(( N_WEDGE + N_VERE + N_SIDE )) SIDECAR-DOWN (restart #$N_SIDE)"
    gwl_start_sidecar
    now="$(date +%s)"
    if [ $(( now - LAST_RECOVER )) -ge $COOLDOWN ]; then recover "sidecar had died"; fi
    sleep $POLL
    continue
  fi

  # 3. event-log progress
  AGE="$(gwl_evt_age)"
  if [ "$AGE" -gt "$STALE" ]; then
    now="$(date +%s)"
    if [ $(( now - LAST_RECOVER )) -ge $COOLDOWN ]; then recover "event log stale ${AGE}s"; fi
  fi

  sleep $POLL
done
