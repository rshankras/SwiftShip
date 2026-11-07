# Review Guide Template

Written by `/apple:verify` to the project's `.planning/REVIEW-GUIDE.md` at
the end of each phase (replaced each time; the old one is in git).

```markdown
# Phase [N] Review Guide: [phase name]

**[Plain verdict in one sentence: does it work, and is anything waiting on you?]**
Status: [PASS (everything works) | PARTIAL (works, with gaps below) | FAIL (something important is broken)] · [date]

## 1. What changed

[Two sentences in everyday words: what someone using the app will notice.]
Affects: [screens / features], [n] files across [n] commits.

## 2. Choices the agents made

| Chose | Instead of | Why |
|-------|-----------|-----|
| [Drafts stored in SwiftData] | [files on disk] | [sync needs it] |

[None: the plan decided everything. | n more in PLAN.md]
Second opinion: [n high-stakes tasks checked: n agreed, n disagreed (you kept / switched) | none this phase]

## 3. Proof that it works

- **Promised features:** [n of m] proven by a check ([n] gaps: [names])
- **Tests can fail:** [n of m] tests failed before the code and pass now; planted bugs [n of m] caught
- **Test speed:** [n s for n tests (last time n s) | ⚠ n% slower: slowest is [test] ([n] s)]
- **Code rules (lint):** [no new problems | n new]; **test coverage:** [x]% ([kept | dropped] vs the agreed minimum)
- **Design:** [matches the pinned design | n screens changed since the pin (change requests) | no design pinned]

## 4. Problems found

[Critical n · High n · Medium n · Low n], plus [n] reported and then thrown out after a second check.

- [Severity]: [plain one-line description] → [fixed | fix task added | left for later]

## 5. What only you can decide

- [ ] [OK that offline saves show no badge?]
- [ ] [Confirm the assumption: "if both devices changed a note, the newest wins"]
- [ ] [Run the checks that need a person: list]

[Nothing for you to decide.]

---

**Links:** [VERIFICATION.md](VERIFICATION.md) · [REVIEW.md](REVIEW.md) · [PLAN.md](PLAN.md) · commits [abc1234](…)…[def5678](…) · [files mentioned]
```

## Rules

- Follows `templates/_conventions/PLAIN-OUTPUT.md`: everyday words, any
  technical term explained in a few words, numbers say what they mean.
- **One screen** (about 40 lines) before the links. Detail stays in the
  reports it links to; the guide only points.
- Section 5 is the reason the page exists: every open question, unconfirmed
  assumption and check that needs a person is a checkbox here.
- Nothing is invented: every line comes from VERIFICATION.md, REVIEW.md,
  PLAN.md (`<decision>`, `<red-green>`, `<spec-clarifications>`,
  `<second-opinion>`) or git.
