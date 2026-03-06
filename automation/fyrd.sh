#!/usr/bin/env bash
# fyrd.sh — shared FYRD helpers for Urbit ship automation
#
# Source this file in other scripts:
#   source "$(dirname "$0")/fyrd.sh"
#
# Required env or arguments:
#   CONN_SOCK — path to the ship's conn.sock
#   VERE_BIN  — path to vere/urbit binary (default: "urbit")

VERE_BIN="${VERE_BIN:-urbit}"

send_fyrd() {
  local fyrd="$1"
  local sock="${2:-$CONN_SOCK}"
  echo "$fyrd" | "$VERE_BIN" eval -jn 2>/dev/null | \
    nc -U -W 3 "$sock" 2>/dev/null | \
    "$VERE_BIN" eval -cn 2>/dev/null || true
}

fire_and_forget_fyrd() {
  local fyrd="$1"
  local sock="${2:-$CONN_SOCK}"
  echo "$fyrd" | "$VERE_BIN" eval -jn 2>/dev/null | \
    nc -U -W 1 "$sock" 2>/dev/null > /dev/null &
}
