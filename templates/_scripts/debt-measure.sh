#!/bin/bash
# debt-measure.sh — violations per area × rule set, ranked by recent commits.
# Used by /apple:debt Step 1. Run from the project root.
# Needs swiftlint + jq. Lints with the project's .swiftlint.yml plus the skills'
# fragments (as extra --config files; nothing in the project changes).
# Output: a markdown table + a Totals line. Priority = violations × (commits in 6 months + 1).
set -u
command -v swiftlint >/dev/null || { echo "debt-measure: swiftlint not found (brew install swiftlint)" >&2; exit 2; }
command -v jq >/dev/null || { echo "debt-measure: jq not found (brew install jq)" >&2; exit 2; }
S="${SWIFTSHIP_SKILLS:-$HOME/.claude/swiftship-skills}"
set --
[ -f .swiftlint.yml ] && set -- --config .swiftlint.yml
for f in design/design-system swift/code-size swift/concurrency ios/coding-best-practices; do
  [ -f "$S/$f/rules/swiftlint.yml" ] && set -- "$@" --config "$S/$f/rules/swiftlint.yml"
done
out="${TMPDIR:-/tmp}/debt.$$"
swiftlint lint --quiet --reporter json "$@" 2>/dev/null > "$out.json"
jq -r --arg root "$PWD/" '.[] | [(.file | ltrimstr($root)), .rule_id] | @tsv' "$out.json" \
| awk -F'\t' '
  $1 ~ /Tests?\// || $1 ~ /(^|\/)(Pods|\.build|DerivedData|Spikes?)\// { next }
  { r=$2; s="";
    if (r ~ /^ds_/) s="design"
    else if (r ~ /^(cyclomatic_complexity|function_body_length|type_body_length|file_length|function_parameter_count)$/) s="size"
    else if (r == "unchecked_sendable") s="concurrency"
    else if (r ~ /^(force_unwrapping|force_try|print_in_production|observable_object_legacy)$/) s="practices"
    if (s == "") next
    a=$1; sub(/\/[^\/]*$/, "", a); print a "\t" s }' > "$out.v"
git log --since="6 months ago" --name-only --format= -- '*.swift' 2>/dev/null \
| awk 'NF { a=$0; sub(/\/[^\/]*$/, "", a); print a }' | sort | uniq -c \
| awk '{ c=$1; $1=""; sub(/^ /, ""); print $0 "\t" c }' > "$out.c"
awk -F'\t' '
  FNR==NR { churn[$1]=$2; next }
  { n[$1]++; v[$1,$2]++; T[$2]++ }
  END {
    printf "| Area | Design | Size | Concurrency | Practices | Total | Commits (6 mo) | Priority |\n"
    printf "|------|--------|------|-------------|-----------|-------|----------------|----------|\n"
    for (a in n) printf "| %s | %d | %d | %d | %d | %d | %d | %d |\n", a, v[a,"design"], v[a,"size"], v[a,"concurrency"], v[a,"practices"], n[a], churn[a]+0, n[a]*(churn[a]+1) | "sort -t\"|\" -k9,9rn -k7,7rn"
    close("sort -t\"|\" -k9,9rn -k7,7rn")
    printf "\n**Totals:** design %d · size %d · concurrency %d · practices %d\n", T["design"], T["size"], T["concurrency"], T["practices"]
  }' "$out.c" "$out.v"
rm -f "$out.json" "$out.v" "$out.c"
