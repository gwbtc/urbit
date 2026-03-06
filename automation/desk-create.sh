#!/usr/bin/env bash
# desk-create.sh — create a new desk as a full copy of %base via %kiln-merge %init
#
# Usage: ./desk-create.sh <desk-name> <conn-sock> [vere-bin]

set -euo pipefail

DESK="${1:?Usage: desk-create.sh <desk-name> <conn-sock> [vere-bin]}"
CONN_SOCK="${2:?Usage: desk-create.sh <desk-name> <conn-sock> [vere-bin]}"
export VERE_BIN="${3:-urbit}"

export CONN_SOCK
source "$(dirname "$0")/fyrd.sh"

read -r -d '' MERGE_FYRD << HOON || true
:*  0
    %fyrd  %base  %khan-eval  %noun  %ted-eval
    :_  :~  /sur/spider/hoon  /lib/strandio/hoon  ==
    '''
    =/  m  (strand ,vase)  ^-  form:m
    ;<  our=@p  bind:m  get-our
    ;<  now=@da  bind:m  get-time
    ;<  ~  bind:m
      (poke-our %hood %kiln-merge !>([%${DESK} our %base [%da now] %init]))
    (pure:m !>('Merge sent!'))
    '''
==
HOON

echo "Creating %${DESK} desk via merge..."
RESULT=$(send_fyrd "$MERGE_FYRD")
echo "Result: $RESULT"
