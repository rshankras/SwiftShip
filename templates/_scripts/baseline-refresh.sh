#!/bin/bash
# baseline-refresh.sh — rewrite .swiftlint-baseline.json after new rules were
# added, without absorbing new violations of rules that were already there.
# Used by /apple:debt Step 6. Run from the project root.
#
# A rule already in the old baseline may only stay the same or go down.
# If one grew, the old baseline is restored and the growth is listed (exit 3):
# someone added violations since the last baseline, and those must be fixed,
# not frozen. Exit 0 = refreshed. Exit 2 = swiftlint/jq missing.
set -u
command -v swiftlint >/dev/null || { echo "baseline-refresh: swiftlint not found (brew install swiftlint)" >&2; exit 2; }
command -v jq >/dev/null || { echo "baseline-refresh: jq not found (brew install jq)" >&2; exit 2; }
B=.swiftlint-baseline.json
t="${TMPDIR:-/tmp}/baseline.$$"
counts() { jq -r '.[].violation.ruleIdentifier' "$1" | sort | uniq -c | awk '{ print $2 "\t" $1 }'; }
: > "$t.before"
if [ -f "$B" ]; then cp "$B" "$t.old"; counts "$B" > "$t.before"; fi
swiftlint lint --quiet --write-baseline "$B" >/dev/null 2>&1
[ -f "$B" ] || { echo "baseline-refresh: swiftlint wrote no baseline" >&2; exit 1; }
counts "$B" > "$t.after"
awk -F'\t' 'FNR==NR { old[$1]=$2; next }
  { new[$1]=$2 }
  END {
    for (r in new) if (r in old) { if (new[r] > old[r]) printf "grew\t%s\t%d -> %d\n", r, old[r], new[r]
                                   else if (new[r] < old[r]) printf "shrank\t%s\t%d -> %d\n", r, old[r], new[r] }
                   else printf "added\t%s\t%d\n", r, new[r]
    for (r in old) if (!(r in new)) printf "cleared\t%s\t%d -> 0\n", r, old[r]
  }' "$t.before" "$t.after" | sort > "$t.diff"
cat "$t.diff"
if grep -q '^grew' "$t.diff"; then
  if [ -f "$t.old" ]; then cp "$t.old" "$B"; else rm -f "$B"; fi
  echo "✗ Existing rules grew since the last baseline. Old baseline restored; fix those violations first." >&2
  rm -f "$t".*; exit 3
fi
total=$(jq length "$B")
echo "✓ Baseline refreshed: $total violations frozen"
rm -f "$t".*
exit 0
