#!/usr/bin/env bash
# wait-idle.sh — poll a ship until it responds to a FYRD
#
# Usage: ./wait-idle.sh <conn-sock> [vere-bin] [max-attempts]
#
# Polls every 10s. Exits 0 on success, 1 on timeout.

set -euo pipefail

CONN_SOCK="${1:?Usage: wait-idle.sh <conn-sock> [vere-bin] [max-attempts]}"
export VERE_BIN="${2:-urbit}"
MAX="${3:-60}"

export CONN_SOCK
source "$(dirname "$0")/fyrd.sh"

FYRD=':*  0
          %fyrd
          %base
          %khan-eval
          %noun
          %ted-eval
          :_  ~
          '"'''
          =/  m  (strand ,vase)
          (pure:m !>('"'"'Success!'"'"'))
          '''
      =="

echo "Polling ship until idle (max ${MAX} attempts, 10s apart)..."
for i in $(seq 1 "$MAX"); do
  echo "Attempt $i of $MAX ($((i * 10))s elapsed)..."
  RESULT=$(send_fyrd "$FYRD")
  echo "Result: $RESULT"
  if echo "$RESULT" | grep -q "%avow"; then
    echo "Ship is idle and responsive after $((i * 10)) seconds."
    exit 0
  fi
  echo "Ship not ready yet, waiting 10s..."
  sleep 10
done
echo "ERROR: Ship never became idle after $((MAX * 10)) seconds."
exit 1
