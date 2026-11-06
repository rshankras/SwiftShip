#!/bin/bash
# test-scripts.sh — run the shared command scripts (templates/_scripts/)
# against small fixture projects and check their output. Called by
# validate.sh; runs anywhere (a fake swiftlint stands in for the real one).
# Exit 0 = all pass, 1 = failures.
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$REPO_DIR/templates/_scripts"
FIX="$REPO_DIR/tests/fixtures"
FAILS=0
ok()  { echo "  ✓ $1"; }
bad() { echo "  ✗ $1"; FAILS=$((FAILS + 1)); }
expect() { # expect <name> <haystack> <needle>
  if printf '%s' "$2" | grep -qF -- "$3"; then ok "$1"; else bad "$1 — expected: $3"; printf '%s\n' "$2" | sed 's/^/      | /' | head -15; fi
}
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

# Fixture app as a git repo with history (paths include spaces on purpose).
APP="$WORK/app"; cp -R "$FIX/app" "$APP"
( cd "$APP" && git init -q && git config user.email t@t && git config user.name t \
  && git add . && git commit -qm one \
  && echo "// edit" >> "Watch App/Views/Home View.swift" && git commit -qam two ) || bad "fixture git setup"

# Fake swiftlint: lint → canned JSON; --write-baseline F → copy $STUB_BASELINE to F.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/swiftlint" <<'STUB'
#!/bin/bash
prev=""; for a in "$@"; do [ "$prev" = "--write-baseline" ] && { cp "$STUB_BASELINE" "$a"; exit 0; }; prev="$a"; done
sed "s|@ROOT@|$PWD|g" "$STUB_LINT_JSON"
STUB
chmod +x "$WORK/bin/swiftlint"

# --- design-debt.sh -----------------------------------------------------------
out=$(cd "$APP" && bash "$SCRIPTS/design-debt.sh" 2>&1)
expect "design-debt: score over both view files (tests + tokens excluded)" "$out" "**Design debt score: 71%** (5 raw style values of 7 style calls across 2 view files)"
expect "design-debt: folder with spaces is its own row" "$out" "| Watch App/Views | 1 | 1 | 1 | 1 | 0 | 100% |"
empty="$WORK/empty"; mkdir -p "$empty" && ( cd "$empty" && git init -q )
expect "design-debt: no view files" "$(cd "$empty" && bash "$SCRIPTS/design-debt.sh" 2>&1)" "No SwiftUI view files found"

# --- debt-measure.sh ------------------------------------------------------------
if command -v jq >/dev/null; then
  cat > "$WORK/lint.json" <<'JSON'
[
 {"file":"@ROOT@/Watch App/Views/Home View.swift","rule_id":"ds_raw_font_size"},
 {"file":"@ROOT@/Watch App/Views/Home View.swift","rule_id":"ds_raw_spacing"},
 {"file":"@ROOT@/Watch App/Views/Home View.swift","rule_id":"line_length"},
 {"file":"@ROOT@/App/Views/ProfileView.swift","rule_id":"force_unwrapping"},
 {"file":"@ROOT@/App/Views/ProfileView.swift","rule_id":"file_length"},
 {"file":"@ROOT@/AppTests/ProfileViewTests.swift","rule_id":"force_try"}
]
JSON
  out=$(cd "$APP" && PATH="$WORK/bin:$PATH" STUB_LINT_JSON="$WORK/lint.json" SWIFTSHIP_SKILLS="$WORK/none" bash "$SCRIPTS/debt-measure.sh" 2>&1)
  expect "debt-measure: spaces in folder keep their commit count" "$out" "| Watch App/Views | 2 | 0 | 0 | 0 | 2 | 2 | 6 |"
  expect "debt-measure: rule sets mapped, style rules ignored" "$out" "| App/Views | 0 | 1 | 0 | 1 | 2 | 1 | 4 |"
  expect "debt-measure: tests excluded from totals" "$out" "**Totals:** design 2 · size 1 · concurrency 0 · practices 1"
  first=$(printf '%s\n' "$out" | sed -n 3p)
  expect "debt-measure: highest priority first" "$first" "| Watch App/Views |"

# --- baseline-refresh.sh --------------------------------------------------------
  bl() { printf '['; sep=""; for r in "$@"; do printf '%s{"violation":{"ruleIdentifier":"%s"}}' "$sep" "$r"; sep=","; done; printf ']'; }
  bl force_unwrapping force_unwrapping > "$APP/.swiftlint-baseline.json"
  bl force_unwrapping force_unwrapping ds_raw_spacing ds_raw_spacing ds_raw_spacing > "$WORK/new-ok.json"
  out=$(cd "$APP" && PATH="$WORK/bin:$PATH" STUB_BASELINE="$WORK/new-ok.json" bash "$SCRIPTS/baseline-refresh.sh" 2>&1); code=$?
  expect "baseline-refresh: new rule added" "$out" "added	ds_raw_spacing	3"
  [ "$code" = 0 ] && ok "baseline-refresh: exit 0 when only new rules appear" || bad "baseline-refresh: exit $code, wanted 0"
  bl force_unwrapping force_unwrapping force_unwrapping ds_raw_spacing ds_raw_spacing ds_raw_spacing > "$WORK/new-bad.json"
  out=$(cd "$APP" && PATH="$WORK/bin:$PATH" STUB_BASELINE="$WORK/new-bad.json" bash "$SCRIPTS/baseline-refresh.sh" 2>&1); code=$?
  expect "baseline-refresh: growth in an existing rule is reported" "$out" "grew	force_unwrapping	2 -> 3"
  [ "$code" = 3 ] && ok "baseline-refresh: exit 3 on growth" || bad "baseline-refresh: exit $code, wanted 3"
  n=$(cd "$APP" && jq length .swiftlint-baseline.json)
  [ "$n" = 5 ] && ok "baseline-refresh: previous baseline restored on growth" || bad "baseline-refresh: baseline has $n entries, wanted 5 (restored)"
else
  echo "  ⚠ jq not found — skipped debt-measure and baseline-refresh tests"
fi

# --- design-pin.sh + design-compare.sh ------------------------------------------
EXP="$WORK/export"; mkdir -p "$EXP"
printf a > "$EXP/Home.png"; printf b > "$EXP/Profile Edit.png"; printf c > "$EXP/Settings.png"
out=$(cd "$APP" && bash "$SCRIPTS/design-pin.sh" 2 "$EXP" 2>&1)
expect "design-pin: pins every frame" "$out" "Pinned 3 frames"
expect "design-pin: names with spaces hashed" "$(cat "$APP/.planning/design/phase-2/pin.tsv")" "Profile Edit.png	"
out=$(cd "$APP" && bash "$SCRIPTS/design-compare.sh" 2 "$EXP" 2>&1)
[ -z "$out" ] && ok "design-compare: unchanged design prints nothing" || bad "design-compare: expected no output, got: $out"
printf B > "$EXP/Profile Edit.png"; rm "$EXP/Settings.png"; printf d > "$EXP/Onboarding.png"
out=$(cd "$APP" && bash "$SCRIPTS/design-compare.sh" 2 "$EXP" 2>&1)
expect "design-compare: added" "$out" "added	Onboarding.png"
expect "design-compare: changed (name with spaces)" "$out" "changed	Profile Edit.png"
expect "design-compare: removed" "$out" "removed	Settings.png"

# --- expect-red.sh (#111) --------------------------------------------------------
R="$WORK/red"; mkdir -p "$R/tests"
( cd "$R" && git init -q && git config user.email t@t && git config user.name t \
  && printf 'add() { echo $(( $1 + $2 )); }\n' > calc.sh && git add . && git commit -qm base ) || bad "expect-red fixture setup"
# The task in progress: new code + its test, not committed yet (as in build).
printf 'add() { echo $(( $1 + $2 )); }\ndouble() { echo $(( $1 * 2 )); }\n' > "$R/calc.sh"
printf '. ./calc.sh; [ "$(double 3)" = 6 ]\n' > "$R/tests/test_double.sh"
printf 'exit 0\n' > "$R/tests/test_weak.sh"
before=$(cd "$R" && git status --porcelain)
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --copy tests/test_double.sh -- bash tests/test_double.sh); rc=$?
[ $rc = 0 ] && ok "expect-red: new test fails against the old code (red first)" || bad "expect-red: red-first wanted exit 0, got $rc: $out"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --copy tests/test_weak.sh -- bash tests/test_weak.sh); rc=$?
[ $rc = 1 ] && ok "expect-red: a test that passes without the code is caught" || bad "expect-red: weak test wanted exit 1, got $rc: $out"
[ "$(cd "$R" && git status --porcelain)" = "$before" ] && ok "expect-red: working tree untouched" || bad "expect-red: working tree changed"
[ "$(cd "$R" && git worktree list | wc -l | tr -d ' ')" = 1 ] && ok "expect-red: scratch copy removed" || bad "expect-red: scratch worktree left behind"
# Verify: the feature is committed; plant bugs in the copy.
( cd "$R" && git add . && git commit -qm feature )
cp "$R/calc.sh" "$WORK/calc.orig"
sed 's/\* 2/* 1/' "$WORK/calc.orig" > "$R/calc.sh"; ( cd "$R" && git diff > "$WORK/bug.diff" && git checkout -q calc.sh )
printf '# comment\n' >> "$R/calc.sh"; ( cd "$R" && git diff > "$WORK/noop.diff" && git checkout -q calc.sh )
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --patch "$WORK/bug.diff" -- bash tests/test_double.sh); rc=$?
[ $rc = 0 ] && ok "expect-red: planted bug caught" || bad "expect-red: planted bug wanted exit 0, got $rc: $out"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --patch "$WORK/noop.diff" -- bash tests/test_double.sh); rc=$?
[ $rc = 1 ] && ok "expect-red: harmless change stays green" || bad "expect-red: no-op patch wanted exit 1, got $rc: $out"
cmp -s "$R/calc.sh" "$WORK/calc.orig" && [ -z "$(cd "$R" && git status --porcelain)" ] && ok "expect-red: planted bug never reaches the working tree" || bad "expect-red: working tree changed after planting"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --patch "$WORK/bug.diff" --at HEAD~1 -- bash tests/test_double.sh); rc=$?
[ $rc = 2 ] && ok "expect-red: patch that doesn't apply is a setup problem" || bad "expect-red: bad patch wanted exit 2, got $rc: $out"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --swap calc.sh '$1 * 2' '$1 * 1' -- bash tests/test_double.sh); rc=$?
[ $rc = 0 ] && ok "expect-red: --swap plants a bug that gets caught" || bad "expect-red: --swap wanted exit 0, got $rc: $out"
cmp -s "$R/calc.sh" "$WORK/calc.orig" && ok "expect-red: --swap leaves the real file alone" || bad "expect-red: --swap changed the working tree"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" --swap calc.sh 'echo' 'true' -- bash tests/test_double.sh); rc=$?
[ $rc = 2 ] && ok "expect-red: --swap text found twice is refused" || bad "expect-red: ambiguous --swap wanted exit 2, got $rc: $out"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" -- sh -c 'echo "/x/Foo.swift:3:5: error: cannot find Bar in scope"; exit 1'); rc=$?
[ $rc = 3 ] && ok "expect-red: compile error is NO-BUILD, not red" || bad "expect-red: compile error wanted exit 3, got $rc: $out"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" -- sh -c 'echo "/x/FooTests.swift:12: error: -[FooTests testA] : XCTAssertEqual failed"; exit 1'); rc=$?
[ $rc = 0 ] && ok "expect-red: failed assertion is red" || bad "expect-red: assertion failure wanted exit 0, got $rc: $out"
out=$(cd "$R" && bash "$SCRIPTS/expect-red.sh" -- sh -c 'echo "Executed 0 tests, with 0 failures"; exit 0'); rc=$?
[ $rc = 2 ] && ok "expect-red: no tests ran is a setup problem" || bad "expect-red: 0 tests wanted exit 2, got $rc: $out"

# --- check-frontmatter.sh (#109) ------------------------------------------------
if command -v ruby >/dev/null; then
  bash "$REPO_DIR/scripts/check-frontmatter.sh" "$FIX/frontmatter/good.md" >/dev/null && ok "frontmatter: quoted hint passes" || bad "frontmatter: good.md should pass"
  out=$(bash "$REPO_DIR/scripts/check-frontmatter.sh" "$FIX/frontmatter/bad-hint.md"); [ $? = 1 ] && ok "frontmatter: #108's unquoted hint fails" || bad "frontmatter: bad-hint.md should fail"
  expect "frontmatter: parse error is explained" "$out" "not valid YAML"
  out=$(bash "$REPO_DIR/scripts/check-frontmatter.sh" "$FIX/frontmatter/list-hint.md"); [ $? = 1 ] && ok "frontmatter: list-shaped hint fails" || bad "frontmatter: list-hint.md should fail"
else
  echo "  ⚠ ruby not found — skipped frontmatter tests"
fi

[ "$FAILS" -eq 0 ] && exit 0 || exit 1
