#!/usr/bin/env bash
# desk-commit.sh — commit a mounted desk to clay, and prove that it landed
#
# Usage: ./desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]
#
# Two things here beyond poking %kiln-commit, because a commit that does
# nothing is otherwise indistinguishable from one that worked:
#
#   1. BEFORE committing, every file in the mount is checked against the
#      desk's own marks (desk-check-marks.sh).  Clay answers a file it has
#      no mark for by dropping the whole commit -- no new revision, no log
#      line, nothing.  That is how a %groundwire desk with no %gw-btc in it
#      nearly shipped; see gwbtc/groundwire 336e6e3.
#
#   2. AFTER committing, the desk's revision is read back out of Clay and
#      this script fails unless it advanced.  The ack on a %kiln-commit poke
#      says the poke arrived, not that Clay took a commit; the old version
#      of this script exited 0 on a commit that no-opped, and the pill job
#      built happily on top of it.
#
# Env:
#   DESK_COMMIT_TIMEOUT     seconds to wait for the revision to move (600)
#   DESK_COMMIT_ALLOW_NOOP  set to 1 where committing identical content and
#                           getting no new revision is the right answer

set -euo pipefail

DESK="${1:?Usage: desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]}"
PIER="${2:?Usage: desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]}"
CONN_SOCK="${3:?Usage: desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]}"
export VERE_BIN="${4:-urbit}"

export CONN_SOCK
HERE="$(dirname "$0")"
source "${HERE}/fyrd.sh"

TIMEOUT="${DESK_COMMIT_TIMEOUT:-600}"

# ---------------------------------------------------------------- the mark --
# Run this first: a desk Clay will refuse is worth catching before the ship
# spends minutes not-committing it.
"${HERE}/desk-check-marks.sh" "${PIER}/${DESK}"

# ------------------------------------------------------------ the revision --
# %cw is clay's case scry: +read-w returns a $cass, whose ud is the desk's
# aeon.  Reading it costs one strand and settles the question the commit poke
# cannot answer.
desk_aeon() {
  local fyrd
  read -r -d '' fyrd << HOON || true
:*  0
    %fyrd  %base  %khan-eval  %noun  %ted-eval
    :_  :~  /sur/spider/hoon  /lib/strandio/hoon  ==
    '''
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  our=@p   bind:m  get-our
    ;<  now=@da  bind:m  get-time
    =/  cas  .^(cass:clay %cw /(scot %p our)/${DESK}/(scot %da now))
    (pure:m !>((crip (weld "desk-aeon=" (scow %ud ud.cas)))))
    '''
==
HOON
  send_fyrd "$fyrd" 2>/dev/null \
    | grep -oE 'desk-aeon=[0-9.]+' | tail -1 | sed 's/^desk-aeon=//; s/\.//g' || true
}

BEFORE="$(desk_aeon)"
if [ -z "$BEFORE" ]; then
  echo "ERROR: could not read %${DESK}'s revision out of Clay before committing." >&2
  echo "The desk should already exist here -- desk-create.sh merged it from"      >&2
  echo "%base. Not being able to read it means the ship is not answering, and"    >&2
  echo "everything after this would be guesswork."                                >&2
  exit 1
fi
echo "%${DESK} is at revision ${BEFORE}"

# ---------------------------------------------------------------- the poke --
read -r -d '' COMMIT_FYRD << HOON || true
:*  0
    %fyrd  %base  %khan-eval  %noun  %ted-eval
    :_  :~  /sur/spider/hoon  /lib/strandio/hoon  ==
    '''
    =/  m  (strand ,vase)
    ^-  form:m
    ;<  ~  bind:m
      (poke-our %hood %kiln-commit !>([%${DESK} %.n]))
    (pure:m !>('Commit sent!'))
    '''
==
HOON

echo "Committing %${DESK}..."
RESULT=$(send_fyrd "$COMMIT_FYRD")
echo "Result: $RESULT"

# ----------------------------------------------------------------- the proof --
# The poke is asynchronous and a big desk can spend minutes inside the commit
# event, during which the ship does not answer at all -- so this loop is
# blocking on the ship as much as it is sleeping.
START="$(date +%s)"
AFTER="$BEFORE"
while :; do
  AFTER="$(desk_aeon)"
  if [ -n "$AFTER" ] && [ "$AFTER" -gt "$BEFORE" ]; then
    echo "%${DESK} committed: revision ${BEFORE} -> ${AFTER}"
    exit 0
  fi
  if [ $(( $(date +%s) - START )) -ge "$TIMEOUT" ]; then
    break
  fi
  sleep 5
done

if [ "${DESK_COMMIT_ALLOW_NOOP:-0}" = 1 ]; then
  echo "%${DESK} is still at revision ${BEFORE}; DESK_COMMIT_ALLOW_NOOP is set, continuing."
  exit 0
fi

cat >&2 <<EOF
ERROR: %${DESK} is still at revision ${BEFORE} after ${TIMEOUT}s.

Clay did not take this commit. It does not say so: a commit it will not take
is a commit that changes nothing, prints nothing and fails nothing, and the
build goes on to bake a desk missing whatever was in it.

What this usually is, in order:
  - a file whose mark the desk does not carry. desk-check-marks.sh ran
    before the commit and passed, so this would be a mark it resolves on
    disk but Clay cannot build -- read the ship's log.
  - sys.kelvin naming a kernel version this ship is not at, which parks the
    commit in wic.dom as a commit-in-waiting rather than applying it.
  - the mount not being synced: desk-mount.sh has to have run, and the
    files have to be under ${PIER}/${DESK}.
  - the ship still chewing; raise DESK_COMMIT_TIMEOUT (now ${TIMEOUT}s).
EOF
exit 1
