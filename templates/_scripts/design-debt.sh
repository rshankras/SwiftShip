#!/bin/bash
# design-debt.sh — how much styling bypasses the design tokens, per area.
# Used by /apple:map Step 4.4 (and /apple:debt). Run from the project root.
# Output: a markdown table (one row per folder holding view files), a
# "Design debt score" line, and a custom-font check.
# Area = the folder that holds the view file (token/style folders and tests excluded).
set -u
tmp="${TMPDIR:-/tmp}/dd.$$"
# View files: paths may contain spaces, so read line by line.
git ls-files '*.swift' | grep -vE 'Tests?/|(^|/)(Pods|\.build|DerivedData)/' \
  | grep -vE '(^|/)(DesignSystem|Tokens|Theme|Styles)/' \
  | while IFS= read -r f; do grep -qE ':\s*View\b|some View' "$f" 2>/dev/null && printf '%s\n' "$f"; done > "$tmp.files"
[ -s "$tmp.files" ] || { echo "No SwiftUI view files found"; rm -f "$tmp.files"; exit 0; }
c() { grep -oE "$1" "$2" 2>/dev/null | wc -l | tr -d ' '; }
while IFS= read -r f; do
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(dirname "$f")" \
    "$(c '\.font\(\s*\.system\(\s*size:|Font\.system\(\s*size:' "$f")" \
    "$(c '\b(Color|UIColor|NSColor)\(\s*(red|white|hue|hex):|Color\(\s*#' "$f")" \
    "$(c '(\.padding\(\s*(\.[a-zA-Z]+\s*,\s*)?|\.cornerRadius\(\s*|cornerRadius:\s*|\.frame\(\s*width:\s*)[1-9][0-9]*(\.[0-9]+)?' "$f")" \
    "$(c '\.(textCase|tracking|kerning)\(|\.uppercased\(\)' "$f")" \
    "$(c '\.font\(|\.foregroundStyle\(|\.foregroundColor\(|\.background\(|\.padding\(|\.cornerRadius\(|cornerRadius:|\.frame\(\s*width:|\.tracking\(|\.textCase\(' "$f")" \
    "$(wc -l < "$f" | tr -d ' ')" \
    "$(c 'accessibilityIdentifier\(' "$f")" \
    "$(c '\b(Button|Toggle|TextField|SecureField|Picker|Stepper|Slider|NavigationLink|Menu)\s*[\(\{]' "$f")"
done < "$tmp.files" | awk -F'\t' '
{ a=$1; n[a]++; fs[a]+=$2; co[a]+=$3; sp[a]+=$4; cs[a]+=$5; tot[a]+=$6
  if ($7>500) big[a]++; else if ($7>300) mid[a]++; id[a]+=$8; ia[a]+=$9 }
END {
  printf "| Area | Files | Raw font | Raw colour | Raw spacing | Call-site case | Debt %% | >300 / >500 lines | IDs / interactive |\n"
  printf "|------|-------|----------|------------|-------------|----------------|--------|-------------------|-------------------|\n"
  for (a in n) { raw=fs[a]+co[a]+sp[a]+cs[a]; d=(tot[a]?100*raw/tot[a]:0)
    printf "| %s | %d | %d | %d | %d | %d | %.0f%% | %d / %d | %d / %d |\n", a,n[a],fs[a],co[a],sp[a],cs[a],d,mid[a]+0,big[a]+0,id[a],ia[a]
    R+=raw; T+=tot[a]; F+=n[a] }
  printf "\n**Design debt score: %.0f%%** (%d raw style values of %d style calls across %d view files)\n", (T?100*R/T:0), R, T, F
}' > "$tmp"
head -2 "$tmp"; sed -n '3,$p' "$tmp" | grep '^| ' | sort -t'|' -k8,8rn
grep '^\*\*' "$tmp"; rm -f "$tmp" "$tmp.files"
# Custom fonts: declared in Info.plist (UIAppFonts) vs present in the repo. macOS only (PlistBuddy).
[ -x /usr/libexec/PlistBuddy ] || exit 0
git ls-files '*Info.plist' | while IFS= read -r plist; do
  /usr/libexec/PlistBuddy -c 'Print :UIAppFonts' "$plist" 2>/dev/null | sed '1d;$d' | while IFS= read -r font; do
    font=$(printf '%s' "$font" | sed 's/^ *//; s/ *$//'); [ -z "$font" ] && continue
    if git ls-files | grep -qF "/$(basename "$font")"; then echo "font ok: $font"; else echo "⚠️ font declared but not in repo: $font ($plist)"; fi
  done
done | sort -u
