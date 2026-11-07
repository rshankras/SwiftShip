#!/bin/bash
# test-times.sh <phase> [--log FILE] -- TEST-COMMAND...
#
# Runs the test suite, times it, and warns when tests get slow (#114).
# Used by /apple:verify 3.2. Run from the project root. Never blocks: the
# exit code is the test command's own.
#
# Prints the last 30 lines of test output, then a "Test speed" block.
# Appends one row to .planning/test-times.tsv (date, phase, seconds, tests)
# and replaces .planning/test-slowest.tsv (the 10 slowest tests of this run,
# read by /apple:debt tests).
#
# Warns (never fails) when:
#   - the suite took over 25% longer than the previous row, and at least
#     5 seconds longer (so 2 s → 3 s isn't news)
#   - any single test took over 10 seconds
# Reads XCTest ("Test Case '…' passed (1.2 seconds)") and Swift Testing
# ("✔ Test name() passed after 1.2 seconds") result lines.
set -u
[ $# -ge 3 ] || { echo "usage: test-times.sh <phase> [--log FILE] -- TEST-COMMAND..." >&2; exit 2; }
phase="$1"; shift
log=""
while [ $# -gt 0 ]; do
  case "$1" in
    --log) log="$2"; shift 2 ;;
    --) shift; break ;;
    *) echo "usage: test-times.sh <phase> [--log FILE] -- TEST-COMMAND..." >&2; exit 2 ;;
  esac
done
[ $# -gt 0 ] || { echo "test-times: no test command given" >&2; exit 2; }
[ -n "$log" ] || log=$(mktemp "${TMPDIR:-/tmp}/test-times.XXXXXX")

start=$(date +%s)
"$@" > "$log" 2>&1
code=$?
secs=${TEST_TIMES_SECONDS:-$(( $(date +%s) - start ))}   # override only for SwiftShip's own tests
tail -30 "$log"

# One line per test: seconds <TAB> name
per=$(perl -ne '
  if (/Test Case \x27-?\[?([^\x27]*?)\]?\x27 (?:passed|failed) \(([0-9.]+) seconds\)/) { my ($n, $t) = ($1, $2); $n =~ s/ /\//; print "$t\t$n\n"; next }
  if (/(?:^|\s)Test (?!run with)(.+?) (?:passed|failed) after ([0-9.]+) seconds/) { print "$2\t$1\n" }
' "$log" | sort -t$'\t' -k1,1rn)
count=$(printf '%s' "$per" | grep -c . )

mkdir -p .planning
tsv=.planning/test-times.tsv
[ -s "$tsv" ] || printf 'date\tphase\tseconds\ttests\n' > "$tsv"
prev=$(tail -n +2 "$tsv" | tail -1 | cut -f3)
printf '%s\t%s\t%s\t%s\n' "$(date +%Y-%m-%d)" "$phase" "$secs" "$count" >> "$tsv"
{ printf 'seconds\ttest\n'; printf '%s\n' "$per" | grep . | head -10; } > .planning/test-slowest.tsv

echo
echo "--- Test speed ---"
if [ -n "$prev" ] && [ "$prev" -gt 0 ] 2>/dev/null; then
  pct=$(( (secs - prev) * 100 / prev ))
  echo "Tests took ${secs} s for ${count} tests (last time: ${prev} s, $( [ $pct -ge 0 ] && echo "+")${pct}%)."
  if [ $pct -gt 25 ] && [ $((secs - prev)) -ge 5 ]; then
    echo "⚠ The tests got ${pct}% slower than last time (${prev} s → ${secs} s)."
  fi
else
  echo "Tests took ${secs} s for ${count} tests (first measurement)."
fi
slow=$(printf '%s\n' "$per" | awk -F'\t' '$1 > 10' | grep -c .)
[ "$slow" -gt 0 ] && echo "⚠ ${slow} test(s) take over 10 s each."
if [ "$count" -gt 0 ]; then
  echo "Slowest 5:"
  printf '%s\n' "$per" | head -5 | awk -F'\t' '{ printf "  %6.1f s  %s\n", $1, $2 }'
else
  echo "(No per-test times found in the output.)"
fi
exit $code
