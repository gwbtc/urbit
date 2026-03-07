#!/usr/bin/env bash
# desk-commit.sh — commit a mounted desk to clay
#
# Usage: ./desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]

set -euo pipefail

DESK="${1:?Usage: desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]}"
PIER="${2:?Usage: desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]}"
CONN_SOCK="${3:?Usage: desk-commit.sh <desk-name> <pier-path> <conn-sock> [vere-bin]}"
export VERE_BIN="${4:-urbit}"

export CONN_SOCK
source "$(dirname "$0")/fyrd.sh"

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
