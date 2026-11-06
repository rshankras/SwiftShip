# Plain Output

How SwiftShip writes anything a **person** reads: completion messages, the
top of reports (VERIFICATION.md, REVIEW.md, DEBT.md, CODEBASE.md), and
questions. The checks and evidence never change. Only the wording does.

Commands reference this file. Don't copy its rules into them.

## The reader setting

`.planning/PREFERENCES.md` may have one line (asked once by `/apple:discuss`):

```
reader: plain        # default: everyday words, terms explained
reader: technical    # the terse expert style: tables, rule names, no explanations
```

No PREFERENCES.md, or no `reader:` line → **plain**. Agents' own working notes
and files only agents read (PLAN.md task XML, pin.tsv, the usage ledger) are
not affected.

## Rules for `reader: plain`

1. **Start with one plain sentence**: what happened, and what (if anything)
   the person needs to do. Put it first, before any table or list.
   - ✅ "Phase 2 works, but 3 screens still use hand-set colours. Nothing for you to do; they're queued for the next phase."
   - ❌ "PARTIAL — DoD #1 ❌ ×3, baseline +3 ds_raw_color"
2. **Everyday words.** When a technical term is needed, explain it the first
   time it appears, in a few words:
   - "baseline (the list of old problems we've agreed to fix later)"
   - "Critical finding (a problem serious enough to stop the release)"
3. **Say what a number means**, not just the number:
   "4 new styling shortcuts that will make a future redesign harder", not
   "4 ds_* violations".
4. **Short sentences.** One idea each. No stacked abbreviations (DoD, UAT,
   CR); write the words out or skip them.
5. **Keep file paths and commands**, and say what each one is for:
   "`.planning/DEBT.md`: the full list, area by area".
6. **Tables come after the plain summary, never instead of it.** Keep them
   if they help; add a one-line "what this table shows" above any table
   with more than three columns.
7. **Decisions stand out.** End with "**You need to decide:**" and a short
   list, or "Nothing for you to decide." Questions offer plain choices
   ("Fix now / Leave for later"), with the recommended one first.
8. **Status words are explained once:** PASS ("everything works"),
   PARTIAL ("works, with gaps listed below"), FAIL ("something important is
   broken").
9. **Emoji are optional markers, never the only signal.** "❌ Failed",
   not just "❌".

## Rules for `reader: technical`

Use the commands' existing terse formats unchanged.

## Checklist before printing

- Could someone who doesn't write Swift tell what happened from the first sentence?
- Is every abbreviation and rule name explained or removed?
- Does the person know whether they need to do anything?

## Rules for commands using this convention

- Read `reader:` once at the start; never ask about it outside `/apple:discuss`.
- The file is absent (older install) → write as before.
- Never drop evidence to make text shorter. Plain wording sits on top of the
  same tables, paths and numbers.
