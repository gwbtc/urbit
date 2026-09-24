#!/usr/bin/env bash
# desk-check-marks.sh — refuse a desk Clay would silently drop
#
# Usage: ./desk-check-marks.sh <desk-dir>
#        ./desk-check-marks.sh --self-test
#
# Clay needs a mark for every file it takes, and the way it tells you it has
# none is by doing nothing at all.  Measured on a live ship: a desk with one
# .md file in it committed to NO new revision and printed not one line, while
# the same desk with the .md removed went 2 -> 3.  Nothing logs, nothing
# fails, and the pill ships a desk missing everything else in that commit.
# That is how a %groundwire desk with no %gw-btc in it nearly went out
# (gwbtc/groundwire 336e6e3).  This is the check that would have caught it,
# and it runs BEFORE the commit rather than guessing afterwards.
#
# The rules below are read off the two implementations, not invented here:
#
#   vere, pkg/vere/io/unix.c +_unix_update_dir, never offers Clay a file
#   whose name begins with '.', ends in '~', contains no '.' at all, or is
#   not a sane @ta ((star ;~(pose nud low hep dot sig cab))).  Those are
#   dropped on the runtime side.  They do not break the commit -- but they
#   are not in the desk either, and a build that assumes otherwise is wrong,
#   so they are reported.
#
#   Clay, sys/vane/clay.hoon +validate-page, marks each remaining file by
#   the LAST component of its path: foo/bar.baz mounts as /foo/bar/baz with
#   mark %baz.  It builds that mark with +build-dais unless it is %hoon or
#   %mime, both of which are hardcoded (%hoon additionally has the
#   [%mime %hoon] tube special-cased in +build-bush, which is why .hoon
#   files commit into desks carrying no mar/ at all).  Everything else goes
#   +build-dais -> +build-nave -> +build-fit -> +fit-path, which needs
#   /mar/<mark>/hoon in the SAME desk and resolves it with +try-fit-path:
#   '-' before '/', left to right, so %foo-bar is satisfied by either
#   mar/foo-bar.hoon or mar/foo/bar.hoon.  No file, no mark, no commit.

set -euo pipefail

WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# Every path +try-fit-path would try for a mark, one per line, relative to
# the desk's mar/ directory and without the .hoon.
mark_candidates() {
  local rest="$1" acc="${2:-}" head tail
  if [ "${rest#*-}" = "$rest" ]; then
    printf '%s%s\n' "$acc" "$rest"
    return 0
  fi
  head="${rest%%-*}"; tail="${rest#*-}"
  mark_candidates "$tail" "${acc}${head}-"
  mark_candidates "$tail" "${acc}${head}/"
}

have_mark() {
  local desk="$1" mark="$2" cand
  case "$mark" in
    hoon|mime) return 0 ;;   # hardcoded in +validate-page / +build-bush
  esac
  while IFS= read -r cand; do
    [ -f "${desk}/mar/${cand}.hoon" ] && return 0
  done < <(mark_candidates "$mark")
  return 1
}

check_desk() {
  local desk="${1%/}"
  if [ ! -d "$desk" ]; then
    echo "desk-check-marks: no such directory: $desk" >&2
    return 2
  fi

  local unmarked dropped
  unmarked="${WORK}/unmarked"; dropped="${WORK}/dropped"
  : > "$unmarked"; : > "$dropped"

  local f rel base mark skip n c m
  while IFS= read -r f; do
    rel="${f#"$desk"/}"
    base="${rel##*/}"

    # Anything vere will not hand to Clay in the first place.
    skip=""
    case "/$rel" in */.*) skip="hidden (vere skips names beginning with .)" ;; esac
    if [ -z "$skip" ]; then
      case "$base" in
        *'~') skip="ends in ~ (vere skips these)" ;;
        *.*)  : ;;
        *)    skip="no extension, so no mark (vere skips these)" ;;
      esac
    fi
    if [ -z "$skip" ]; then
      case "$base" in
        *[!a-z0-9._~-]*) skip="not a sane @ta (vere skips these)" ;;
      esac
    fi
    if [ -n "$skip" ]; then
      printf '%s\t%s\n' "$rel" "$skip" >> "$dropped"
      continue
    fi

    mark="${base##*.}"
    if [ -z "$mark" ]; then
      printf '%s\t%s\n' "$rel" "trailing dot, so no mark" >> "$dropped"
      continue
    fi
    have_mark "$desk" "$mark" || printf '%s\t%s\n' "$mark" "$rel" >> "$unmarked"
  done < <(find "$desk" -type f)

  if [ -s "$dropped" ]; then
    echo "desk-check-marks: ${desk}: files the runtime will not put in the desk:"
    sort "$dropped" | head -20 | while IFS=$'\t' read -r rel skip; do
      printf '    %-46s %s\n' "$rel" "$skip"
    done
    n="$(wc -l < "$dropped" | tr -d ' ')"
    [ "$n" -gt 20 ] && echo "    ... and $(( n - 20 )) more"
    echo "  Not fatal. They are simply not going to be there."
  fi

  if [ ! -s "$unmarked" ]; then
    echo "desk-check-marks: ${desk}: every file has a mark."
    return 0
  fi

  {
    echo "ERROR: ${desk} contains files Clay has no mark for."
    echo "Clay does not report this. It takes the commit, changes nothing,"
    echo "prints nothing, and leaves the desk at its old revision -- with"
    echo "everything else in the same commit missing too."
    echo
    for m in $(cut -f1 "$unmarked" | sort -u); do
      echo "  no ${desk}/mar/${m}.hoon (mark %${m}), needed by:"
      awk -F'\t' -v m="$m" '$1==m {print "    " $2}' "$unmarked" | head -5
      c="$(awk -F'\t' -v m="$m" '$1==m' "$unmarked" | wc -l | tr -d ' ')"
      [ "$c" -gt 5 ] && echo "    ... and $(( c - 5 )) more"
    done
    echo
    echo "Either give the desk a mark for it, or keep the file out of the desk."
    echo "Repo documentation belongs outside; see the groundwire Makefile's"
    echo "'rm -rf dist-groundwire/doc'."
  } >&2
  return 1
}

# --------------------------------------------------------------- self-test --
# A guard nobody has watched fire is not a guard. This runs in CI on every
# build, immediately before the guard is trusted with a real desk.
self_test() {
  local t rc fails=0 want name
  t="${WORK}/self-test"
  rm -rf "$t"
  mkdir -p "$t/mar/urb" "$t/app" "$t/lib" "$t/doc"
  : > "$t/mar/bill.hoon"
  : > "$t/mar/kelvin.hoon"
  : > "$t/mar/urb/point.hoon"
  : > "$t/app/gw-btc.hoon"
  : > "$t/lib/gw-verify.hoon"
  : > "$t/desk.bill"
  : > "$t/sys.kelvin"

  expect() {
    want="$1"; name="$2"
    rc=0; check_desk "$t" >/dev/null 2>&1 || rc=$?
    if [ "$rc" = "$want" ]; then
      echo "  ok    $name (exit $rc)"
    else
      echo "  FAIL  $name (wanted exit $want, got $rc)"
      fails=$(( fails + 1 ))
    fi
  }

  echo "desk-check-marks --self-test:"
  expect 0 "a desk whose every file has a mark passes"

  # The measured bug, reproduced: one .md and no mar/md.hoon.
  : > "$t/doc/confidential-comets.md"
  expect 1 "one unmarked .md fails the desk"

  # ...and the message has to name the thing, or nobody can act on it.
  local said
  said="$(check_desk "$t" 2>&1 || true)"
  if printf '%s\n' "$said" | grep -q 'mar/md\.hoon' &&
     printf '%s\n' "$said" | grep -q 'doc/confidential-comets\.md'; then
    echo "  ok    the failure names both the missing mark and the file"
  else
    echo "  FAIL  the failure does not name the missing mark and the file"
    fails=$(( fails + 1 ))
  fi

  rm -f "$t/doc/confidential-comets.md"
  expect 0 "removing the .md makes it pass again"

  # +try-fit-path walks '-' -> '/', so mar/urb/point.hoon serves %urb-point.
  : > "$t/lib/x.urb-point"
  expect 0 "a hyphenated mark resolves through a mar/ subdirectory"
  rm -f "$t/lib/x.urb-point"

  # ...but only when something really is behind it.
  : > "$t/lib/x.urb-block"
  expect 1 "a hyphenated mark with no file behind it fails"
  rm -f "$t/lib/x.urb-block"

  # Files vere drops on the floor are noise, not errors.
  mkdir -p "$t/.git"
  : > "$t/.git/config"
  : > "$t/.gitignore"
  : > "$t/LICENSE"
  : > "$t/app/gw-btc.hoon~"
  expect 0 "dotfiles, extensionless files and editor backups do not fail"

  # %hoon and %mime need no mar/ entry at all.
  rm -f "$t/mar/bill.hoon" "$t/mar/kelvin.hoon" "$t/desk.bill" "$t/sys.kelvin"
  expect 0 "a desk of nothing but .hoon needs no marks"

  echo
  if [ "$fails" = 0 ]; then
    echo "desk-check-marks: self-test passed; the guard fires."
    return 0
  fi
  echo "desk-check-marks: SELF-TEST FAILED ($fails)"
  return 1
}

case "${1:-}" in
  --self-test) self_test ;;
  -h|--help)
    echo "Usage: desk-check-marks.sh <desk-dir>"
    echo "       desk-check-marks.sh --self-test" ;;
  "")
    echo "Usage: desk-check-marks.sh <desk-dir>" >&2
    exit 2 ;;
  *) check_desk "$1" ;;
esac
