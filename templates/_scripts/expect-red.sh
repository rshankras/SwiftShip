#!/bin/bash
# expect-red.sh [--at REF] [--copy PATH]... [--swap PATH OLD NEW] [--patch FILE] [--log FILE] -- TEST-COMMAND...
#
# Proves tests can fail (#111). Runs TEST-COMMAND in a throwaway copy of the
# repo (a git worktree of REF, default HEAD), never in your working tree:
#   --copy PATH   copy this file from your working tree into the copy first
#                 (build: the task's new tests, run against the pre-task code)
#   --swap PATH OLD NEW
#                 in the copy, replace the exact text OLD (must occur once)
#                 with NEW (verify: a planted bug, run against the finished code)
#   --patch FILE  apply this diff to the copy first (same use as --swap)
# Run from the project root. The copy is removed afterwards, whatever happens.
#
# Prints one line and exits:
#   0 RED        tests failed: good, they notice
#   1 GREEN      tests passed: they check nothing here
#   2 SETUP      couldn't run: not a repo, patch didn't apply, no tests ran
#   3 NO-BUILD   code didn't compile (fine for a brand-new type in build;
#                a planted bug must compile, so pick another in verify)
set -u
ref=HEAD; patch=""; log=""; copies=(); swaps=()
while [ $# -gt 0 ]; do
  case "$1" in
    --at) ref="$2"; shift 2 ;;
    --copy) copies+=("$2"); shift 2 ;;
    --swap) [ $# -ge 4 ] || { echo "SETUP: --swap needs PATH OLD NEW"; exit 2; }; swaps+=("$2" "$3" "$4"); shift 4 ;;
    --patch) patch="$2"; shift 2 ;;
    --log) log="$2"; shift 2 ;;
    --) shift; break ;;
    *) echo "usage: expect-red.sh [--at REF] [--copy PATH]... [--swap PATH OLD NEW] [--patch FILE] [--log FILE] -- TEST-COMMAND..." >&2; exit 2 ;;
  esac
done
[ $# -gt 0 ] || { echo "SETUP: no test command given"; exit 2; }
root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "SETUP: not inside a git repository"; exit 2; }
cd "$root" || exit 2
case "$patch" in ""|/*) ;; *) patch="$root/$patch" ;; esac

scratch=$(mktemp -d "${TMPDIR:-/tmp}/expect-red.XXXXXX")
wt="$scratch/repo"
[ -n "$log" ] || log="$scratch.log"
cleanup() { git worktree remove --force "$wt" >/dev/null 2>&1; git worktree prune >/dev/null 2>&1; rm -rf "$scratch"; }
trap cleanup EXIT

git worktree add --detach -q "$wt" "$ref" 2>/dev/null || { echo "SETUP: can't check out $ref"; exit 2; }
for p in ${copies[@]+"${copies[@]}"}; do
  [ -f "$p" ] || { echo "SETUP: --copy file not found: $p"; exit 2; }
  mkdir -p "$wt/$(dirname "$p")" && cp "$p" "$wt/$p"
done
if [ -n "$patch" ]; then
  [ -f "$patch" ] || { echo "SETUP: patch not found: $patch"; exit 2; }
  ( cd "$wt" && git apply "$patch" ) 2>/dev/null || { echo "SETUP: patch didn't apply"; exit 2; }
fi
i=0
while [ $i -lt ${#swaps[@]} ]; do
  f="$wt/${swaps[$i]}"
  [ -f "$f" ] || { echo "SETUP: --swap file not found: ${swaps[$i]}"; exit 2; }
  n=$(OLD="${swaps[$((i+1))]}" perl -0777 -ne '$c = () = /\Q$ENV{OLD}\E/g; print $c' "$f")
  [ "$n" = 1 ] || { echo "SETUP: --swap text found $n times in ${swaps[$i]} (needs exactly 1)"; exit 2; }
  OLD="${swaps[$((i+1))]}" NEW="${swaps[$((i+2))]}" perl -0777 -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/' "$f"
  i=$((i + 3))
done

( cd "$wt" && "$@" ) > "$log" 2>&1
code=$?

# A compiler error has file:line:column; a failed XCTest assertion has only file:line.
if grep -qE '\*\* BUILD FAILED \*\*|\.swift:[0-9]+:[0-9]+: error:|error: compile command failed' "$log"; then
  echo "NO-BUILD (log: $log)"; exit 3
fi
if grep -qE 'Executed 0 tests|0 tests in 0 suites|No matching test cases' "$log"; then
  echo "SETUP: no tests ran; check the test names (log: $log)"; exit 2
fi
if [ "$code" -ne 0 ]; then echo "RED (log: $log)"; exit 0; fi
echo "GREEN (log: $log)"; exit 1
