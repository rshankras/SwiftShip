#!/bin/bash
# folder-imports.sh            → which frameworks each folder uses
# folder-imports.sh --files X  → the files that use X
#
# Used by /apple:map to suggest "must not" folder rules (#116). Run from the
# project root. Shipping code only: test folders, Pods, .build, DerivedData
# and generated code are skipped.
#
# Table output, one line per folder and framework, tab-separated:
#   folder  name  files
# name is an imported module (SwiftUI, CloudKit, StoreKit, …) or a direct API
# use that needs no import of its own: api:URLSession, api:CKContainer,
# api:CKDatabase, api:Product.purchase, api:AppStore.sync. Commented-out
# lines don't count. Files at the root are folder ".".
set -u
mode=table; want=""
if [ "${1:-}" = "--files" ]; then
  [ $# -eq 2 ] || { echo "usage: folder-imports.sh [--files NAME]" >&2; exit 2; }
  mode=files; want="$2"
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -c core.quotepath=off ls-files --cached --others --exclude-standard -- '*.swift' | sort -u
else
  find . -name '*.swift' -type f | sed 's|^\./||'
fi | grep -vE '(^|/)[^/]*Tests?/|(^|/)(Pods|\.build|DerivedData|Generated|build)/' > "${TMPDIR:-/tmp}/fi.$$"

while IFS= read -r f; do
  [ -f "$f" ] || continue
  d=$(dirname "$f")
  awk -v d="$d" -v f="$f" '
    /^[[:space:]]*\/\// { next }
    /^[[:space:]]*(@[A-Za-z_]+[[:space:]]+)*import[[:space:]]/ {
      s = $0
      sub(/^[[:space:]]*(@[A-Za-z_]+[[:space:]]+)*import[[:space:]]+/, "", s)
      if (s ~ /^(struct|class|enum|protocol|typealias|func|var|let)[[:space:]]/) sub(/^[a-z]+[[:space:]]+/, "", s)
      split(s, a, /[.[:space:]]/); seen[a[1]] = 1
    }
    /URLSession/        { seen["api:URLSession"] = 1 }
    /CKContainer/       { seen["api:CKContainer"] = 1 }
    /CKDatabase/        { seen["api:CKDatabase"] = 1 }
    /Product[^ ]*\.purchase|\.purchase\(/ { seen["api:Product.purchase"] = 1 }
    /AppStore\.sync/    { seen["api:AppStore.sync"] = 1 }
    END { for (n in seen) print d "\t" n "\t" f }
  ' "$f"
done < "${TMPDIR:-/tmp}/fi.$$" > "${TMPDIR:-/tmp}/fi.$$.out"

if [ "$mode" = files ]; then
  awk -F'\t' -v w="$want" '$2 == w { print $3 }' "${TMPDIR:-/tmp}/fi.$$.out" | sort
else
  awk -F'\t' '{ c[$1 "\t" $2]++ } END { for (k in c) print k "\t" c[k] }' "${TMPDIR:-/tmp}/fi.$$.out" | sort
fi
rm -f "${TMPDIR:-/tmp}/fi.$$" "${TMPDIR:-/tmp}/fi.$$.out"
