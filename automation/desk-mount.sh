#!/usr/bin/env bash
# desk-mount.sh — mount a clay desk and poll until sys.kelvin appears
#
# Usage: ./desk-mount.sh <desk-name> <pier-path> <conn-sock> [vere-bin] [max-attempts]

set -euo pipefail

DESK="${1:?Usage: desk-mount.sh <desk-name> <pier-path> <conn-sock> [vere-bin] [max-attempts]}"
PIER="${2:?Usage: desk-mount.sh <desk-name> <pier-path> <conn-sock> [vere-bin] [max-attempts]}"
CONN_SOCK="${3:?Usage: desk-mount.sh <desk-name> <pier-path> <conn-sock> [vere-bin] [max-attempts]}"
export VERE_BIN="${4:-urbit}"
MAX="${5:-18}"

export CONN_SOCK
source "$(dirname "$0")/fyrd.sh"

read -r -d '' MOUNT_FYRD << HOON || true
:*  0
    %fyrd  %base  %khan-eval  %noun  %ted-eval
    :_  :~  /sur/spider/hoon  /lib/strandio/hoon  ==
    '''
    =/  m  (strand ,vase)  ^-  form:m
    ;<  our=@p   bind:m  get-our
    ;<  now=@da  bind:m  get-time
    ;<  ~  bind:m
      %:  poke-our  %hood  %kiln-mount
          !>([(en-beam [[our %${DESK} [%da now]] /]) %${DESK}])  ==
    (pure:m !>(~))
    '''
==
HOON

MOUNT_PATH="${PIER}/${DESK}"
echo "Polling to mount %${DESK} at ${MOUNT_PATH} (up to ${MAX} attempts)..."
for i in $(seq 1 "$MAX"); do
  send_fyrd "$MOUNT_FYRD" > /dev/null
  sleep 5
  if [ -e "${MOUNT_PATH}/sys.kelvin" ]; then
    echo "%${DESK} mounted successfully (attempt $i)."
    exit 0
  fi
  echo "  attempt $i: not yet, waiting 10s..."
  sleep 10
done
echo "ERROR: %${DESK} never mounted after ${MAX} attempts"
exit 1
