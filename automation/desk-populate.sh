#!/usr/bin/env bash
# desk-populate.sh — prepare a desk's mounted directory for new content
#
# After desk-create.sh copies %base into a new desk, the mount contains
# all of %base's files (including desk.bill with %acme, etc). This script
# clears everything except mar/ (mark definitions Clay needs to process
# commits), ensures essential marks exist, and writes sys.kelvin.
#
# Usage: ./desk-populate.sh <desk-name> <pier-path> [kelvin]
#
# After this script, rsync/copy your desk content into the mount, then
# run desk-commit.sh.

set -euo pipefail

DESK="${1:?Usage: desk-populate.sh <desk-name> <pier-path> [kelvin]}"
PIER="${2:?Usage: desk-populate.sh <desk-name> <pier-path> [kelvin]}"
KELVIN="${3:-408}"

DESK_PATH="${PIER}/${DESK}"
BASE_PATH="${PIER}/base"

if [ ! -d "$DESK_PATH" ]; then
  echo "ERROR: ${DESK_PATH} does not exist (is the desk mounted?)"
  exit 1
fi

# Clear everything.
echo "Clearing %${DESK} (preserving mar/)..."
cd "$DESK_PATH"
ls | grep -v '^mar$' | xargs rm -rf
cd - > /dev/null

# Write sys.kelvin
echo "[%zuse ${KELVIN}]" > "${DESK_PATH}/sys.kelvin"

echo "%${DESK} ready for content (kelvin ${KELVIN})."
