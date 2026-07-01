# SwiftShip

**Spec-driven development for iOS & macOS apps, run entirely through [Claude Code](https://claude.com/claude-code).**

SwiftShip combines [GSD's workflow methodology](https://github.com/open-gsd/gsd-core) with deep Apple-platform expertise to walk you from *"I have an app idea"* all the way to *"it's live on the App Store"* — without losing context between sessions.

---

## What is SwiftShip?

Imagine building an app with an AI assistant that, left alone, is brilliant but forgetful — it doesn't remember last week's decisions, and it doesn't automatically know all of Apple's rules.

**SwiftShip is a project manager + a team of Apple specialists that sits on top of Claude Code.** It gives you:

- **A clear path** — a sequence of simple commands (you type `/apple:something`) that take you from idea → design → build → test → ship.
- **A memory** — a hidden `.planning/` folder inside your project that records your spec, roadmap, decisions, and progress, so you can stop today and resume tomorrow exactly where you left off.
- **Specialists on call** — for the tricky parts (SwiftUI screens, in‑app purchases, iCloud sync, App Store review), the right "agent" is brought in automatically.

> **Important:** SwiftShip is *not* an app and *not* a program you compile. It's a set of carefully‑written instruction files (Markdown) that teach Claude Code how to behave like that project manager. There's nothing to build — you just install it and start typing commands.

### A simple mental model

Building an app is like building a house:

| House | SwiftShip |
|---|---|
| Blueprints & permits | the `.planning/` files (spec, roadmap, plan) |
| The foreman you give orders to | the `/apple:*` commands you type |
| The plumber, electrician, roofer | the specialist *agents* the foreman calls in |
| The building‑code manuals on the shelf | the **skills library** (a separate companion project) |

---

## Highlights

- **48 commands** covering the whole lifecycle: idea validation, planning, building, testing, App Store metadata, screenshots, TestFlight, submission, and post‑launch.
- **Works for brand‑new apps *and* existing apps** — one command maps your existing code, and another turns it into a phased feature‑plus‑bug‑fix release plan.
- **Run & screenshot your app** — quality commands can actually launch your app (iOS Simulator *or* a real Mac app) and look at it, instead of just asking you "does it work?"
- **Optional App Store Connect automation** — with the right tool connected, commands can *push* your metadata, release notes, and TestFlight setup straight to App Store Connect — always after showing you a preview and asking first. (The final "Submit for Review" always stays your decision.)
- **Data‑driven planning** — pull real downloads, sales, crashes, and reviews into your "what to build next" decisions.
- **Portable** — installs on any Mac with one script; no hardcoded paths to edit.
- **Graceful by default** — every "smart" capability is optional. If a tool isn't installed, the command quietly falls back to plain manual instructions. Nothing breaks.

---

## How it works

```
┌─────────────────────────────────────────────────────────────────────────┐
│  COMMANDS  (you type these)                                              │
│  /apple:validate → /apple:new-app → /apple:roadmap → /apple:plan → ...   │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PLANNING FILES  (your project's memory, in .planning/)                  │
│  VALIDATION · APP · ROADMAP · STATE · PLAN · REVIEW · ASO · ...          │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  AGENTS  (specialists, called automatically)                 │
│  swiftui-builder · storekit-expert · hig-reviewer · ...      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  SKILLS  (the "manuals" — from claude-code-apple-skills)     │
│  ios/ · macos/ · generators/ · app-store/ · security/ · ...  │
└─────────────────────────────────────────────────────────────┘
```

**Optional tool handoffs:** where a supported tool is connected, some commands can *act* (push your metadata, screenshot the running app, read your sales) instead of only printing manual steps. These are always **opt‑in, preview‑first, and confirm‑before‑acting**, and they **degrade gracefully** — with nothing connected, every command simply gives you manual instructions. (Details in [Optional power‑ups](#optional-power-ups-tool-handoffs).)

---

## Installation

SwiftShip needs three things on your Mac:

1. **[Claude Code](https://claude.com/claude-code)** — the assistant SwiftShip runs inside.
2. **Xcode + the Swift toolchain** — to build and test the apps you create.
3. **[claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills)** — the companion "manuals" library SwiftShip reads from. Check it out anywhere; the installer finds it automatically if it sits next to this repo.

Then:

```bash
cd /path/to/SwiftShip
chmod +x install.sh
./install.sh
```

The installer figures out where your skills library lives, in this order — so it works on any machine with no edits:

```bash
./install.sh                                              # auto-detect ../claude-code-apple-skills
./install.sh /path/to/claude-code-apple-skills            # or pass it explicitly
SWIFTSHIP_SKILLS_DIR=/path/to/claude-code-apple-skills ./install.sh   # or via env var
```

It creates **home‑relative symlinks** in `~/.claude/` so the commands work in any project, on any user account:

| Symlink | Points to |
|---|---|
| `~/.claude/commands/apple` | this repo's `commands/apple/` |
| `~/.claude/agents` | this repo's `agents/` |
| `~/.claude/swiftship-templates` | this repo's `templates/` |
| `~/.claude/swiftship-skills` | the `skills/` folder of your `claude-code-apple-skills` checkout |

Because everything is referenced via `~/...` paths (which expand per‑user), there are **no machine‑specific absolute paths to edit**. Re‑run `./install.sh` any time you move the skills library.

### Optional: fewer permission prompts

So Claude Code doesn't ask permission for every read, you can pre‑allow common safe commands in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Bash(ls:*)", "Bash(cat:*)", "Bash(find:*)", "Bash(grep:*)", "Bash(wc:*)",
      "Bash(git status:*)", "Bash(git log:*)", "Bash(git diff:*)", "Bash(git branch:*)"
    ]
  }
}
```

Or let Claude Code set this up for you automatically with the `/fewer-permission-prompts` skill.

---

## Quick start

```bash
# (run these as slash commands inside Claude Code, in your project folder)

/apple:validate "menu bar app for focus and hydration"   # is the idea worth it?
/apple:new-app HydrationBuddy                             # define the app
/apple:roadmap                                            # break it into phases
/apple:plan 1                                             # detail phase 1
/apple:build                                              # build phase 1
/apple:review                                             # quality gate
# ...repeat plan → build → review per phase...
/apple:testflight                                         # beta test
/apple:submit                                             # ship it
/apple:help                                               # see everything, any time
```

---

## Using SwiftShip on a **new app**

This is the main, end‑to‑end flow. Each step writes a file into `.planning/` so nothing is forgotten.

1. **Validate the idea — `/apple:validate "your idea"`**
   Claude researches market size, competitors, feature gaps, and revenue potential, and gives you a **GO / PIVOT / NO‑GO** recommendation. Saves you from building something nobody wants. → `.planning/VALIDATION.md`

2. **Define the app — `/apple:new-app MyApp`**
   A guided interview: platform (iOS/macOS/both), the problem you're solving, target users, core features, how it makes money, and which Apple frameworks you'll need. → `.planning/APP.md` (+ a project `CLAUDE.md`)

3. **Create the roadmap — `/apple:roadmap`**
   Turns your spec into **7 phases**: Foundation → Core Features → Polish & Platform Features → Monetization → Quality & Testing → Pre‑Release → Submission. → `.planning/ROADMAP.md`, `STATE.md`

4. **(Optional) Set preferences — `/apple:discuss [phase]`**
   Before planning, Claude asks how *you* like to work: architecture (MVVM, etc.), navigation, error handling, testing depth. These choices are remembered and applied automatically when planning and building. → `.planning/PREFERENCES.md`

5. **(Optional) De‑risk a tricky API — `/apple:spike "topic"`**
   Apple ships new APIs every year, most gated by OS version and device. A *spike* is a quick throwaway experiment that answers "does this actually work on my minimum OS / on these devices?" **before** you commit it to a plan. → `.planning/spikes/...`

6. **Plan the phase — `/apple:plan 1`**
   Breaks a phase into concrete tasks, each tagged `auto` (Claude does it with a specialist), `generator` (uses a ready‑made code recipe), or `manual` (you do it, e.g. create the Xcode project). → `.planning/PLAN.md`

7. **Build the phase — `/apple:build`**
   Works through the task list: brings in the right specialist agent, writes the code, runs checks, commits after each task, and updates the project's memory. At the end it runs a quality gate automatically.

8. **Verify it works — `/apple:verify`**
   Confirms the features actually work (builds, tests, and — if a supported tool is connected — it can **launch and screenshot the running app** and look at it). → `.planning/VERIFICATION.md`

9. **Review quality — `/apple:review`**
   Runs **5 reviewers at once**: code quality, Apple Human Interface Guidelines, App Store rules, performance, and security. → `.planning/REVIEW.md`

10. **Repeat 6–9 for each phase.** Or, to move faster, **`/apple:autonomous`** runs plan → build → verify across *several* phases hands‑off, pausing only when it needs you (a manual task, a blocker, or a serious issue).

11. **Prepare the store listing**
    - **`/apple:metadata`** — app name, subtitle, keywords, description. → `.planning/ASO.md`
    - **`/apple:screenshots`** — plan and automate App Store screenshots.
    - **`/apple:release-notes`** — "What's New" text for every channel.

12. **Beta test — `/apple:testflight`**
    Prepares your TestFlight beta and tracks tester feedback. → `.planning/FEEDBACK.md`

13. **Submit — `/apple:submit`**
    A final pre‑submission checklist plus an automated rejection‑risk review. (The actual "Submit for Review" click stays yours.)

14. **Wrap up & iterate**
    - **`/apple:milestone`** — archive the finished version and tag it in git.
    - **`/apple:next-version`** — start planning the next release (and pull in real user data to decide what to build).

---

## Using SwiftShip on an **existing app**

Already have an app — maybe half‑built, inherited, or shipped years ago? SwiftShip meets you where you are. There are two ways in.

### Option A — Adopt the full workflow

1. **Map the codebase — `/apple:map`**
   Read‑only. Claude scans your project and writes a clear summary: architecture (SwiftUI vs UIKit, SwiftData vs Core Data, navigation style), the key files (views, models, services), dependencies, and tech debt (TODOs, force‑unwraps, missing tests, rough test coverage). → `.planning/CODEBASE.md`
   *(This only describes your code — it never changes it.)*

2. **Plan the release — `/apple:release "add Search, fix the settings crash"`**
   The existing‑app counterpart to `/apple:roadmap` (which assumes a greenfield v1.0). It **reads the `map` analysis** so it won't re‑plan code you already have, **detects your shipped version** from the project and proposes the next one, and scopes this update's **new features *and* bug fixes together** into one phased plan — Build → Fix → Harden → Ship, scaled to what you're actually shipping. → `.planning/RELEASE.md` + `.planning/ROADMAP.md`
   *(No prior SwiftShip history needed — this works on an app that has never touched SwiftShip.)*

3. **Build and ship — `/apple:plan` → `/apple:build` → … → `/apple:milestone`**
   The same `plan → build → verify → review` loop as a new app. Features become build tasks; **each bug becomes a tracked task with its own regression test** (instead of drifting off on its own); the flows next to your changes get re‑checked so you don't break what already worked; then release notes, TestFlight, and submit. Close it out with `/apple:milestone` to tag and archive.

> **Where the other commands fit:** want a full written spec too? Run `/apple:new-app` first (optional) to capture `APP.md`. And once you're shipping version after version *through* SwiftShip, `/apple:next-version` picks up where a milestone left off — pulling in deferred items, captured ideas, and real user data.

### Option B — Use individual commands à la carte

Most commands work standalone on any existing code — no roadmap required. Just run the one you need:

- **`/apple:bugfix "crash in settings"`** — fast lane for a bug you understand: locate, fix, add a regression test, commit.
- **`/apple:debug "..."`** — systematic investigation for a *mystery* bug, with state tracking.
- **`/apple:test [file | phase | "recent"]`** — generate tests for code you point it at (it matches your existing framework — Swift Testing or XCTest — and won't silently mangle your Xcode project).
- **`/apple:perf "slow scrolling"`** — profile and diagnose performance issues.
- **`/apple:security`** — full security audit (secrets, Keychain, network, privacy manifest). → `.planning/SECURITY.md`
- **`/apple:visual-qa`** — visual/UI audit from screenshots or by scanning your SwiftUI for anti‑patterns (and it can capture fresh screenshots for you).
- **`/apple:review`** — the 5‑reviewer quality sweep.
- **`/apple:spike "..."`** — try a new Apple API safely before adopting it.

> **Tip:** `map` is *analysis only* — it tells you the shape of your code; it doesn't refactor anything. Use the à‑la‑carte commands for actual changes.

---

## Optional power-ups (tool handoffs)

This is what's special about SwiftShip beyond planning: where a supported tool is connected to Claude Code, certain commands can **do the last mile for you** instead of just telling you to go do it. Every one of these is **opt‑in**, shows you a **before → after preview**, and **asks before acting** — and if the tool isn't connected, the command simply gives you the manual steps as before.

| Capability | What it does | Commands |
|---|---|---|
| **Run & screenshot your app** | Builds, launches, and screenshots the running app — iOS Simulator *or* a real macOS app (menu‑bar apps included) — and looks at the result. | `/apple:verify`, `/apple:visual-qa` |
| **Push to App Store Connect** | Pushes generated name / subtitle / keywords / description / promo text / "What's New" straight to your listing, each field previewed and confirmed — including per‑market translations. | `/apple:metadata`, `/apple:release-notes`, `/apple:localize` |
| **Manage TestFlight** | Lists/creates beta groups, adds testers (with a clear "this emails a real person" confirmation), and pulls crash feedback into your notes. | `/apple:testflight` |
| **Pre‑fill a submission** | Creates the App Store version record and pushes final metadata — then stops. `ship` also uploads media + build and drives the last mile (submission stays gated). | `/apple:submit`, `/apple:ship` |
| **Finalize IAPs & subscriptions & legal URLs** | Sets a one‑time IAP's price + localized name/description, creates subscription groups/tiers/offers, and publishes legal pages + sets the ASC Privacy/Support URLs — each write previewed and confirmed (dry‑run → apply), via your own ASC API key. | `/apple:iap`, `/apple:subscription`, `/apple:privacy` |
| **A/B test the product page** | Creates Product Page Optimization experiments (icon / screenshots / subtitle), reads the results, and promotes the confident winner. | `/apple:experiment` |
| **Run in‑app events** | Creates and localizes App Store in‑app event cards (challenges, seasonal moments) that surface in Search & Today. | `/apple:event` |
| **Data‑driven planning** | Pulls real downloads, sales, crashes, sessions, and low‑star reviews into your "what to build next" decisions and milestone summaries. | `/apple:next-version`, `/apple:milestone`, `/apple:learn-from-store` |

**Safety rules built in:**
- **Manual is always the default.** The "smart" path is offered, never forced.
- **Nothing outward‑facing happens without an explicit yes**, one action at a time (no silent batches).
- **Reversible by design where possible** — e.g. metadata stays editable until you submit.
- **The "Submit for Review" button is never automated.** It's reviewer‑facing and hard to undo, so it always stays a manual click in App Store Connect.
- **Least privilege.** Each command can only touch the specific tools it needs.

These rely on optional, *separately‑installed* tools (an App Store Connect connector, a "run in Simulator" helper, sales/health reporters). They are **not** required to use SwiftShip — they're bonuses that activate only when present.

---

## All commands

> See them any time inside Claude Code with **`/apple:help`**.

### Idea & setup
| Command | What it does |
|---|---|
| `/apple:brainstorm [focus]` | Brainstorm app ideas tailored to your skills |
| `/apple:validate [idea]` | Validate an idea with market & competitor research |
| `/apple:new-app [name]` | Define a new app through guided questions |
| `/apple:map` | Analyze an existing codebase (brownfield) |

### Design
| Command | What it does |
|---|---|
| `/apple:prototype [screen]` | Explore divergent UI directions as named `#Preview`s, remix, and tune — before you plan |
| `/apple:icon [style]` | Generate an app icon — placeholder + light/dark/tinted variants, and layered source for Icon Composer |

### Planning
| Command | What it does |
|---|---|
| `/apple:roadmap` | Create the 7‑phase development roadmap (new app) |
| `/apple:release [scope]` | Plan a feature + bug‑fix release for an **existing** app |
| `/apple:discuss [phase]` | Capture implementation preferences before planning |
| `/apple:plan [phase]` | Break a phase into detailed tasks |
| `/apple:spike [topic]` | Validate an Apple API before planning around it |

### Building
| Command | What it does |
|---|---|
| `/apple:build` | Execute the current phase's tasks with specialist agents |
| `/apple:autonomous [start] [--to N]` | Run plan → build → verify across multiple phases, hands‑off |
| `/apple:debug [issue]` | Systematic debugging with state tracking |
| `/apple:bugfix [bug]` | Quick fix for a known bug + regression test |

### Quality
| Command | What it does |
|---|---|
| `/apple:test [target]` | Generate or expand tests on demand |
| `/apple:verify` | Verify completed work (and optionally run the app) |
| `/apple:review` | 5‑reviewer code / HIG / App Store / perf / security sweep |
| `/apple:security [focus]` | Full security audit |
| `/apple:perf [problem]` | Profile and diagnose performance issues |
| `/apple:visual-qa [paths]` | Visual/UI audit from screenshots or code |
| `/apple:walkthrough [flow]` | Drive user flows in the Simulator; audit the nav graph for dead-ends |
| `/apple:differentiate [app\|idea]` | Originality / 4.3‑spam guardrail — function + metadata distinctness; protects the account |
| `/apple:modernize [path]` | Sweep deprecations + adopt new‑OS APIs (Liquid Glass, toolbars) each cycle |

### Release
| Command | What it does |
|---|---|
| `/apple:metadata` | Generate App Store content (name, keywords, description) |
| `/apple:screenshots` | Plan and automate screenshot capture |
| `/apple:deploy` | Set up Fastlane + CI for automated deployment |
| `/apple:testflight` | Prepare and manage a TestFlight beta |
| `/apple:release-notes` | Generate release notes for every channel |
| `/apple:iap` | Finalize a one-time IAP's price + localization in App Store Connect (dry-run) |
| `/apple:privacy` | Publish legal pages + set the ASC Privacy/Support URLs (dry-run) |
| `/apple:subscription [product]` | Auto‑renewable subscriptions — groups, tiers, offers + StoreKit 2 lifecycle |
| `/apple:localize [locales]` | Translate listing + in‑app strings; add locales; re‑optimize keywords per market |
| `/apple:submit` | Final App Store submission checklist |
| `/apple:ship [version]` | One‑command final mile — upload media + build, price IAP, category/URLs, submit (dry‑run/gated) |
| `/apple:rejection [reason]` | Work an App Review rejection to resolution + Resolution Center reply |

### Growth & operate
| Command | What it does |
|---|---|
| `/apple:learn-from-store` | Turn live reviews/analytics/sales/crashes into a metric‑tagged backlog + verify last cycle |
| `/apple:experiment [lever]` | A/B the product page (icon/screenshots/subtitle) via Product Page Optimization; promote the winner |
| `/apple:event [name]` | Create App Store in‑app events for discovery & re‑engagement |

### Version & ideas
| Command | What it does |
|---|---|
| `/apple:milestone` | Complete a version, archive docs, tag in git |
| `/apple:next-version [name]` | Start planning the next version |
| `/apple:idea [text]` | Capture an idea without disrupting your work |
| `/apple:ideas` | Review and manage captured ideas |

### Session management
| Command | What it does |
|---|---|
| `/apple:progress` | Show current status and next steps |
| `/apple:pause` | Write a handoff doc when you stop |
| `/apple:resume` | Restore context from a previous session |
| `/apple:learn [lesson]` | Capture a mistake/pattern so it never recurs |
| `/apple:help` | Show all commands |

---

## Planning files

SwiftShip's "memory" lives in a `.planning/` folder inside *your* project. You can read, edit, and commit these like any other file.

```
.planning/
├── BRAINSTORM.md     # Ranked idea shortlist (from /apple:brainstorm)
├── VALIDATION.md     # Idea validation (market, competitors)
├── APP.md            # App specification
├── CODEBASE.md       # Existing-code analysis (from /apple:map)
├── PROTOTYPE.md      # UI direction exploration (from /apple:prototype)
├── ROADMAP.md        # Development phases
├── RELEASE.md        # Release scope: features + bug fixes (from /apple:release)
├── STATE.md          # Where you are right now
├── PREFERENCES.md    # Your implementation choices
├── PLAN.md           # Tasks for the current phase
├── spikes/           # API validation findings
├── DEBUG.md          # Debug session log (from /apple:debug)
├── VERIFICATION.md   # "Does it work?" results
├── REVIEW.md         # Quality findings
├── SECURITY.md       # Security audit
├── PERFORMANCE.md    # Performance analysis
├── VISUAL-QA.md      # Visual/UI findings
├── WALKTHROUGH.md    # Flow walkthrough findings (from /apple:walkthrough)
├── ASO.md            # App Store content
├── SCREENSHOTS.md    # Screenshot plan
├── FEEDBACK.md       # TestFlight feedback
├── RELEASE-NOTES.md  # Release text for all channels
├── SIGNALS.md        # Store-signal ledger + hypotheses (from /apple:learn-from-store)
├── IDEAS.md          # Captured ideas
├── HANDOFF.md        # Session handoff notes
└── archive/          # Completed, tagged versions
```

---

## Specialized agents

For `auto` tasks, `/apple:build` brings in the right specialist (all run on a cost‑efficient model):

| Agent | Expertise |
|---|---|
| `swiftui-builder` | Modern SwiftUI, `@Observable`, NavigationStack |
| `storekit-expert` | StoreKit 2, subscriptions, in‑app purchases |
| `cloudkit-expert` | iCloud sync, conflict resolution |
| `hig-reviewer` | Human Interface Guidelines (read‑only) |
| `app-store-reviewer` | App Store Review Guidelines (read‑only) |

---

## The skills library (companion project)

SwiftShip is the *manager*; the **[claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills)** repo is the *knowledge* — 140+ reusable "skills" (Apple coding playbooks and code generators). When SwiftShip builds a paywall, a settings screen, or a privacy manifest, it's following a recipe from there. The two are designed as a pair. A few examples of what gets pulled in when:

| When… | Uses… |
|---|---|
| Validating an idea | `product/market-research`, `product/competitive-analysis` |
| Building SwiftUI views | `ios/coding-best-practices`, `macos/coding-best-practices` |
| Implementing a paywall | `generators/paywall-generator` |
| Adding a settings screen | `generators/settings-screen` |
| Apple Intelligence features | `apple-intelligence/foundation-models`, `…/app-intents`, `…/visual-intelligence` |
| Running a security audit | `security/`, `security/privacy-manifests` |
| Optimizing App Store keywords | `app-store/keyword-optimizer`, `app-store/app-description-writer` |
| Setting up CI/CD | `generators/ci-cd-setup`, `generators/error-monitoring` |

*(That's a tiny sample — the library spans 23 categories.)*

---

## Directory structure

```
SwiftShip/
├── commands/apple/        # 48 workflow commands (the /apple:* you type)
├── agents/                # 5 specialist agents
├── templates/             # planning-file templates copied into your project
│   └── _conventions/      # shared rules (e.g. the optional tool-handoff convention)
├── install.sh             # one-script installer (symlinks into ~/.claude/)
├── CLAUDE.md              # guidance for Claude when editing this repo
└── README.md              # you are here
```

---

## FAQ

**Do I need to know how to code?**
It helps, but SwiftShip is designed so you can drive at a high level. You'll still want Xcode installed and an Apple Developer account to actually ship.

**Will it change my code without asking?**
Building (`/apple:build`, `/apple:bugfix`, `/apple:test`) writes code and commits — that's the point. Analysis commands (`/apple:map`, `/apple:review`, `/apple:security`) are read‑only. Anything that touches the *outside world* (App Store Connect, TestFlight emails) always previews and asks first, and is off unless you've connected the optional tool.

**Is anything sent to Apple automatically?**
Only if you opt in to a tool handoff and confirm it. The final **Submit for Review** is never automated.

**What if I don't install the optional tools?**
Everything still works — those commands just give you manual instructions instead. SwiftShip degrades gracefully.

**Can I use it on a project that's already on the App Store?**
Yes — start with `/apple:map`, or just use commands like `/apple:bugfix`, `/apple:test`, `/apple:perf`, and `/apple:metadata` à la carte.

---

## Philosophy

1. **Spec‑driven** — every app starts with a clear, written specification.
2. **Phased** — work in focused phases, not overwhelming scope.
3. **Specialized** — the right agent for each kind of task.
4. **Persistent** — planning files keep context across sessions.
5. **Apple‑first** — built specifically for iOS/macOS and Apple's guidelines.
6. **Safe by default** — manual fallback always works; outward actions are opt‑in and confirmed.

---

## Related projects

SwiftShip is one of a family of Claude Code projects for Apple developers:

| Project | What it is |
|---|---|
| [claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills) | The **skills library** SwiftShip reads from — Apple coding playbooks and code generators. The *knowledge* behind the *workflow*. |

## Credits

SwiftShip's workflow methodology is adapted from **[GSD (Get Sh*t Done)](https://github.com/open-gsd/gsd-core)**, re‑focused for Apple‑platform development and paired with the `claude-code-apple-skills` knowledge library.

## License

MIT
