#!/bin/bash

# SwiftShip repo validator — the static tier of the eval story.
# Catches silent rot: broken skill/template references, count drift,
# unregistered commands, malformed frontmatter.
#
# Skills location resolves like install.sh:
#   $SWIFTSHIP_SKILLS_DIR → first argument → sibling ../claude-code-apple-skills
# If the skills checkout is missing, skill-reference checks are skipped with a
# warning (set REQUIRE_SKILLS=1 to make that a failure, as CI does).
#
# Usage:  ./scripts/validate.sh [/path/to/claude-code-apple-skills]
# Exit:   0 = clean, 1 = violations found

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR" || exit 1

VIOLATIONS=0
fail() {
    echo "  ✗ $1"
    VIOLATIONS=$((VIOLATIONS + 1))
}
section() {
    echo ""
    echo "== $1 =="
}

# --- Resolve the skills checkout (same order as install.sh) -----------------
SKILLS_SRC="${SWIFTSHIP_SKILLS_DIR:-${1:-}}"
if [ -z "$SKILLS_SRC" ]; then
    SKILLS_SRC="$REPO_DIR/../claude-code-apple-skills"
fi
if [ -d "$SKILLS_SRC/skills" ]; then
    SKILLS_SRC="$SKILLS_SRC/skills"
fi
if [ -d "$SKILLS_SRC" ]; then
    SKILLS_SRC="$(cd "$SKILLS_SRC" && pwd)"
    SKILLS_OK=1
else
    SKILLS_OK=0
    if [ "${REQUIRE_SKILLS:-0}" = "1" ]; then
        echo "✗ Skills checkout not found at: $SKILLS_SRC (REQUIRE_SKILLS=1)"
        exit 1
    fi
    echo "⚠️  Skills checkout not found at: $SKILLS_SRC — skipping skill-reference checks"
fi

MD_SOURCES="commands/apple agents"

# --- 1. Skill references resolve ---------------------------------------------
if [ "$SKILLS_OK" = "1" ]; then
    section "Skill references resolve against $SKILLS_SRC"

    # Category alternation built from the actual skills checkout (dirs only),
    # so new categories are picked up automatically.
    CATEGORIES=$(find "$SKILLS_SRC" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | tr '\n' '|' | sed 's/|$//')

    # Matches explicit paths (~/.claude/swiftship-skills/..., full fidelity —
    # the prefix disambiguates, so SKILL.md and mixed case are kept) and bare
    # category/skill references in prose or tables (e.g. `swift/memory`),
    # where lowercase-kebab segments keep prose like "design/APIs" out.
    REF_RE="(~/.claude/swiftship-skills/[A-Za-z0-9_./-]+|($CATEGORIES)/[a-z0-9_.-]+(/[a-z0-9_.-]+)*)"

    grep -rnoE "$REF_RE" $MD_SOURCES \
        | sed 's/[),.:;`]*$//' \
        | sort -u \
        | while IFS=: read -r file line ref; do
            rel="${ref#\~/.claude/swiftship-skills/}"
            # Skip template placeholders that survived extraction
            case "$rel" in *\[*) continue ;; esac
            # For bare refs, skip matches that are fragments of something
            # longer: preceded by '/' (a project path like .planning/legal/x),
            # '[' (a placeholder like [ios/macos]), or another path segment.
            if [ "$ref" = "$rel" ]; then
                text=$(sed -n "${line}p" "$file")
                case "$text" in
                    *"/$ref"*|*"[$ref"*) continue ;;
                esac
            fi
            if [ ! -e "$SKILLS_SRC/$rel" ] && [ ! -d "$SKILLS_SRC/${rel%/}" ]; then
                echo "MISS $file:$line $rel"
            fi
        done > /tmp/swiftship-validate-skills.$$

    if [ -s /tmp/swiftship-validate-skills.$$ ]; then
        while read -r _ loc ref; do
            fail "$loc — unresolved skill reference: $ref"
        done < /tmp/swiftship-validate-skills.$$
    fi
    rm -f /tmp/swiftship-validate-skills.$$
    CHECKED=$(grep -rhoE "$REF_RE" $MD_SOURCES | sort -u | wc -l | tr -d ' ')
    echo "  checked $CHECKED unique references"
fi

# --- 2. Template references resolve ------------------------------------------
section "Template references resolve against ./templates"
grep -rnoE "~/.claude/swiftship-templates/[A-Za-z0-9_./-]+" $MD_SOURCES \
    | sed 's/[),.:;`]*$//' \
    | sort -u \
    | while IFS=: read -r file line ref; do
        rel="${ref#\~/.claude/swiftship-templates/}"
        case "$rel" in *\[*) continue ;; esac
        if [ ! -e "templates/$rel" ]; then
            echo "MISS $file:$line $rel"
        fi
    done > /tmp/swiftship-validate-tpl.$$
if [ -s /tmp/swiftship-validate-tpl.$$ ]; then
    while read -r _ loc ref; do
        fail "$loc — unresolved template reference: templates/$ref"
    done < /tmp/swiftship-validate-tpl.$$
fi
rm -f /tmp/swiftship-validate-tpl.$$
echo "  checked $(grep -rhoE '~/.claude/swiftship-templates/[A-Za-z0-9_./-]+' $MD_SOURCES | sort -u | wc -l | tr -d ' ') unique references"

# --- 3. Documented counts match reality ---------------------------------------
section "Documented counts match reality"
CMD_COUNT=$(ls commands/apple/*.md | wc -l | tr -d ' ')
AGENT_COUNT=$(ls agents/*.md | wc -l | tr -d ' ')

readme_cmd=$(grep -oE '[0-9]+ workflow commands' README.md | grep -oE '[0-9]+' | head -1)
readme_cmd_hl=$(grep -oE '\*\*[0-9]+ commands\*\*' README.md | grep -oE '[0-9]+' | head -1)
readme_agents=$(grep -oE '[0-9]+ specialist agents' README.md | grep -oE '[0-9]+' | head -1)

[ "$readme_cmd" = "$CMD_COUNT" ]    || fail "README directory-structure says '$readme_cmd workflow commands', actual: $CMD_COUNT"
[ "$readme_cmd_hl" = "$CMD_COUNT" ] || fail "README Highlights says '$readme_cmd_hl commands', actual: $CMD_COUNT"
[ "$readme_agents" = "$AGENT_COUNT" ] || fail "README says '$readme_agents specialist agents', actual: $AGENT_COUNT"
echo "  commands: $CMD_COUNT, agents: $AGENT_COUNT"

# --- 4. Every command is registered in help.md --------------------------------
section "Every command registered in help.md"
for f in commands/apple/*.md; do
    name=$(basename "$f" .md)
    grep -q "/apple:$name" commands/apple/help.md || fail "commands/apple/$name.md not listed in help.md"
done
echo "  checked $CMD_COUNT commands"

# --- 5. Frontmatter well-formed ------------------------------------------------
section "Frontmatter well-formed"
for f in commands/apple/*.md; do
    fm=$(awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$f")
    echo "$fm" | grep -q '^description:'   || fail "$f — missing 'description:' in frontmatter"
    echo "$fm" | grep -q '^allowed-tools:' || fail "$f — missing 'allowed-tools:' in frontmatter"
done
for f in agents/*.md; do
    fm=$(awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$f")
    echo "$fm" | grep -q '^name:'          || fail "$f — missing 'name:' in frontmatter"
    echo "$fm" | grep -q '^description:'   || fail "$f — missing 'description:' in frontmatter"
    echo "$fm" | grep -q '^model: sonnet$' || fail "$f — model must be 'sonnet' (repo convention; update validator if intentional)"
    echo "$fm" | grep -q '^tools:'         || fail "$f — missing 'tools:' in frontmatter"
done
echo "  checked $CMD_COUNT commands + $AGENT_COUNT agents"

# --- 6. Shell scripts are sane --------------------------------------------------
section "Shell scripts executable and parse"
for s in install.sh hooks/*.sh scripts/*.sh; do
    [ -x "$s" ] || fail "$s is not executable (chmod +x)"
    bash -n "$s" 2>/dev/null || fail "$s has a bash syntax error"
done
echo "  checked install.sh, hooks/, scripts/"

# --- Summary --------------------------------------------------------------------
echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
    echo "✗ $VIOLATIONS violation(s) found"
    exit 1
fi
echo "✓ All checks passed"
exit 0
