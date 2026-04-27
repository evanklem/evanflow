# EvanFlow

**A TDD-driven iterative feedback loop for software development with Claude Code.**

16 cohesive skills + 2 custom subagents walk an idea from brainstorm through implementation, with checkpoints throughout where you stay in control. One entry point: say *"let's evanflow this"* and the orchestrator runs the loop.

```
brainstorm → plan → execute (vertical-slice TDD per task) → iterate → STOP
                    └─ sequential, or parallel coder/overseer
```

TDD is not a separate phase after execute — it's the discipline *inside* each code-writing task. Execute is the harness (task tracking, blockers, quality checks); `evanflow-tdd` is what runs inside any task that produces production code.

The loop is **conductor, not autopilot**: real checkpoints at design approval, plan approval, and after iteration. The agent stops short of every git operation and waits for your direction. No auto-commits. No forced ceremony. No "must invoke a skill" tax.

---

## Quick Install

The **recommended** path — Claude Code's plugin marketplace:

```
/plugin marketplace add evanklem/evanflow
/plugin install evanflow@evanflow
```

Restart, then try:

> "Let's evanflow this — I want to add a small feature that does X."

`evanflow-go` fires and walks the loop. The git-guardrails hook auto-activates with the plugin (no settings.json edit needed). Skills appear under the `evanflow:` namespace (e.g., `/evanflow:evanflow-go`).

See [Installation](#installation) below for two alternative paths.

---

## What Makes It a Feedback Loop

The loop is built around **discipline that compounds across iterations**, not single-shot generation. Every step has a checkpoint that gates the next:

- **Brainstorm** clarifies intent, proposes 2–3 approaches with embedded grill (stress-test) → you approve the design
- **Plan** maps file structure first (deep modules, deletion test) → you approve the plan
- **Execute** runs task-by-task with inline verification → blockers stop the loop and surface to you. Inside each code-writing task, **TDD** is the discipline (not a separate phase that comes after).
- **TDD** is vertical-slice only and **per-cycle full RED → GREEN → REFACTOR**: one failing test → minimal impl → refactor *while the test you just wrote is still fresh as your safety net* → next test. Refactor is not deferred to the end. Tests verify behavior through public interfaces, so they survive refactors
- **Iterate** re-reads the diff with fresh eyes, runs quality checks, screenshots UI changes, and runs against a Five Failure Modes checklist (hallucinated actions, scope creep, cascading errors, context loss, tool misuse). Hard cap of 5 iterations
- **STOP.** Report. Await your direction. The agent never auto-commits, never auto-stages, never proposes a PR

For plans with 3+ truly independent units, the loop forks into a **parallel coder/overseer orchestration**: one coder per unit (using vertical-slice TDD with a RED checkpoint), one overseer per coder (read-only review subagent that can't modify code), plus an integration overseer that runs named integration tests at every touchpoint. The integration tests *are* the executable contract — interfaces can't drift if both sides have to satisfy the same passing test.

## Hard Rules Baked Into the Loop

Each rule below cites the source it came from. If a citation is missing, the rule is opinion from running the loop on real projects, not research — labeled as such.

- **Never invent values** — file paths, env vars, IDs, function names, library APIs. If unsure, the agent stops and asks. *Source: action-hallucination is the top failure mode in [DAPLab/Columbia "9 Critical Failure Patterns of Coding Agents"](https://daplab.cs.columbia.edu/general/2026/01/08/9-critical-failure-patterns-of-coding-agents.html).*
- **Assertion-correctness warning** — over 62% of LLM-generated test assertions were incorrect across HumanEval evaluation of four LLMs. *Source: ["Test-Driven Development for Code Generation" (arXiv 2402.13521)](https://arxiv.org/pdf/2402.13521), §3.2.* Both `evanflow-tdd` and the overseer review explicitly check whether a one-character bug in the implementation would still let the assertion pass.
- **Five Failure Modes pass** in iterate + overseer review — hallucinated actions, scope creep, cascading errors, context loss, tool misuse. *Source: synthesized from the DAPLab failure patterns paper above.*
- **Context drift watch** — `evanflow-compact` triggers at clean phase boundaries and on drift symptoms (re-asking settled questions, contradicting earlier decisions). *Source: nearly 65% of enterprise AI failures in 2025 were attributed to context drift or memory loss during multi-step reasoning, not raw context exhaustion — see [Alex Merced, "Context Management Strategies for OpenCode" (March 2026)](https://datalakehousehub.com/blog/2026-03-context-management-opencode/).*
- **Never auto-commit, never auto-stage** — opinion, not research. Came from running the loop on real projects: every time the agent decided to integrate, it integrated wrong.
- **No skill tax** — opinion. Skills are tools, not a tollbooth.

---

## The Skill Set

### Default Loop (5 skills)

| Skill | Purpose |
|---|---|
| `evanflow-brainstorming` | Clarify intent, propose 2–3 approaches with embedded grill (stress-test). Mockup quick-mode for visual-only requests. |
| `evanflow-writing-plans` | File structure first, bite-sized tasks, embedded grill. Step 2.5 offers `evanflow-coder-overseer` if the plan is parallelizable. |
| `evanflow-executing-plans` | Task-by-task with inline verification. Step 0 re-offers parallel path. Hands off to iterate, then STOPS. |
| `evanflow-tdd` | Vertical-slice TDD. One test → one impl → repeat. Behavior through public interface. Assertion-correctness warning. |
| `evanflow-iterate` | Self-review loop after implementation. Re-read diff, fix issues, run quality checks, screenshot UI (via headless Chromium). Five Failure Modes checklist. Hard cap of 5 iterations. |

### Special-Purpose (8 skills)

| Skill | Purpose |
|---|---|
| `evanflow-go` | **Single entry point.** Say "let's evanflow this" and it walks the whole loop. |
| `evanflow-glossary` | Extract canonical domain terms into `CONTEXT.md`. Flag ambiguities and synonyms. |
| `evanflow-improve-architecture` | Surface refactor opportunities via the deletion test + deep-modules vocabulary. |
| `evanflow-design-interface` | "Design it twice" — spawn 3+ parallel sub-agents with radically different constraints, compare on depth/simplicity/efficiency. |
| `evanflow-debug` | Root-cause discipline. Hypothesis stated explicitly, embedded grill before fixing, failing test first. |
| `evanflow-review` | Both halves of code review (giving + receiving). Don't capitulate to feedback you can't justify. |
| `evanflow-prd` | Synthesize a PRD from existing context. For substantial new features. |
| `evanflow-qa` | Conversational bug discovery → issue draft. Asks before filing. |

### Cross-Cutting (1 skill)

| Skill | Purpose |
|---|---|
| `evanflow-compact` | Long-session context management. Strategies for proactive summarization at clean boundaries. Drift symptoms checklist. |

### Meta (1 skill)

| Skill | Purpose |
|---|---|
| `evanflow` | The index. Shared vocabulary + when to invoke each `evanflow-*` skill. |

### Custom Subagents (2)

In `agents/` — invoked via `Agent` tool with `subagent_type:` parameter:

| Subagent | Tool restrictions | Purpose |
|---|---|---|
| `evanflow-coder` | Read, Edit, Write, Glob, Grep, Bash, TodoWrite | Implementation subagent for `evanflow-coder-overseer`. Tools + system prompt prevent git ops, out-of-scope edits, value hallucination. |
| `evanflow-overseer` | Read, Grep, Glob (no Edit/Write/Bash) | Read-only review subagent. Tools physically enforce "report findings, never fix." |

### Bundled Hook

`hooks/block-dangerous-git.sh` — PreToolUse hook that blocks destructive git ops (`git push`, `git reset --hard`, `git clean -f`, `git branch -D`, `git checkout .`, `git restore .`). Auto-activates with the plugin install path.

---

## Hard Rules (apply to every skill)

1. **Never auto-commit, never auto-stage, never auto-finish.** Every git write op requires you to explicitly ask in the current turn.
2. **Never invent values.** File paths, env vars, IDs, function names, library APIs — if unsure, the agent stops and asks.
3. **No skill tax.** Ad-hoc questions don't require a skill invocation. Skills are tools, not a tollbooth.
4. **No forced spec/plan paths.** Files live where you want them.
5. **Verify before claiming done.** Quality checks (typecheck, lint, test) run before any "done" report.

---

## Requirements

- **[Claude Code](https://claude.com/claude-code)** (any recent version)
- **Bash** — for the bundled hook script (Linux, macOS, or Windows + WSL)
- **`jq`** — used by the hook script to parse Claude's JSON tool input. Install via `apt install jq`, `brew install jq`, or your platform's package manager. **If `jq` is missing, the guardrail hook fails silently and dangerous git ops are NOT blocked.**

Optional but recommended:

- **`chromium`** or `google-chrome` — for `evanflow-iterate`'s visual verification of UI changes (`chromium --headless --screenshot=...`). Falls back gracefully if missing — the skill flags it and asks you to verify visually.

---

## Installation

Three paths, in priority order. All three end with the same skill set in your `.claude/skills/`. The plugin path additionally auto-wires the guardrail hook.

### Path 1 — Claude Code Plugin Marketplace (recommended)

This is the cleanest install. Skills, agents, AND the guardrail hook all activate automatically.

```
/plugin marketplace add evanklem/evanflow
/plugin install evanflow@evanflow
```

Restart Claude Code (or `/reload-plugins`). Skills appear namespaced as `/evanflow:evanflow-go`, `/evanflow:evanflow-tdd`, etc. Auto-invocation via "let's evanflow this" still works regardless of namespace.

To uninstall: `/plugin uninstall evanflow@evanflow`.

### Path 2 — `npx skills@latest add` CLI

Works against any GitHub repo with `SKILL.md`-shaped folders. Installs skills only — **does not install the guardrail hook or custom subagents** (you'd add those manually if you want them).

```bash
# Install all 16 skills at once
npx skills@latest add evanklem/evanflow -s '*' -y

# Or install individual skills
npx skills@latest add evanklem/evanflow/evanflow-go
npx skills@latest add evanklem/evanflow/evanflow-tdd
# ...
```

This places skills under `~/.claude/skills/` (global) or `.claude/skills/` (project, auto-detected).

### Path 3 — Manual Copy

For users who want full control, no CLI dependencies.

```bash
git clone https://github.com/evanklem/evanflow.git
cd evanflow

# Skills (project-level — adjust to ~/.claude/skills/ for global)
mkdir -p .claude/skills
cp -r skills/* .claude/skills/

# Agents (custom subagents used by evanflow-coder-overseer)
mkdir -p .claude/agents
cp agents/*.md .claude/agents/

# Git guardrails hook (optional but recommended)
mkdir -p .claude/hooks
cp hooks/block-dangerous-git.sh .claude/hooks/
chmod +x .claude/hooks/block-dangerous-git.sh
```

Then register the hook in your `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

Optionally, paste `examples/CLAUDE.md.snippet` into your project's `CLAUDE.md` to brief Claude about EvanFlow's conventions.

### Verify Any Install Path

Restart Claude Code. Try saying:

> "Let's evanflow this — I want to add a small feature that does X."

`evanflow-go` should fire and walk you through the loop. To verify the guardrail hook (paths 1 and 3 only): try `git reset --hard HEAD` from the Bash tool — it should be blocked with "BLOCKED: ... matches dangerous pattern".

---

## Customization

Every skill has a clear structure with a `## Hard Rules` section. To adapt to your project:

- **Replace `<frontend>` and `<backend>` placeholders** in skills like `evanflow-writing-plans` with your actual paths if you find yourself answering the same question repeatedly.
- **Document your project's quality checks** in your `CLAUDE.md` — exact `typecheck`, `lint`, and `test` commands. The skills reference these abstractly.
- **Adapt the visual verification step** in `evanflow-iterate` if you don't have `chromium` available — substitute `google-chrome --headless` or another tool.
- **Edit the cohesion contract template** in `evanflow-coder-overseer` to match your project's conventions (your authentication middleware name, your DB write helper, etc.).

The skills are designed to be edited. Treat them as starting points, not gospel.

If you fork to make a vendor-specific variant (your-name-flow), great — that's the spirit.

---

## How EvanFlow Works End-to-End

```
You say: "let's evanflow this — I want to add a feature that does X"
           │
           ▼
       evanflow-go (the conductor)
           │
           ├─ Phase 0: Restate idea, scope check
           ├─ Phase 1: evanflow-brainstorming (CHECKPOINT: design approval)
           ├─ Phase 2: evanflow-writing-plans (CHECKPOINT: plan approval)
           │            └─ Step 2.5: parallelization check
           ├─ Phase 3: evanflow-executing-plans (sequential)
           │            OR
           │            evanflow-coder-overseer (parallel)
           │              ├─ contract with named tests + integration tests
           │              ├─ RED checkpoint (all coders write failing tests, orchestrator verifies)
           │              ├─ GREEN phase (vertical-slice TDD per coder)
           │              ├─ per-coder overseers (review, never fix)
           │              └─ integration overseer (runs touchpoint tests)
           ├─ Phase 4: evanflow-iterate (5x cap, Five Failure Modes pass)
           └─ Phase 5: STOP. Report what was done. Await your direction.
```

Cross-cutting: `evanflow-compact` runs at clean boundaries when context gets heavy.

Special-purpose skills (`evanflow-debug`, `evanflow-improve-architecture`, `evanflow-design-interface`, `evanflow-glossary`, `evanflow-prd`, `evanflow-qa`, `evanflow-review`) are pulled in mid-flow when relevant.

---

## Repository Structure

```
.
├── .claude-plugin/
│   ├── plugin.json          — plugin identity (name, description, version)
│   └── marketplace.json     — marketplace manifest (lists EvanFlow as one bundled plugin)
├── skills/                  — 16 SKILL.md folders
│   ├── evanflow/
│   ├── evanflow-go/
│   ├── evanflow-brainstorming/
│   ... (etc)
├── agents/                  — 2 custom subagent definitions
│   ├── evanflow-coder.md
│   └── evanflow-overseer.md
├── hooks/
│   ├── hooks.json           — auto-activated when plugin installs
│   └── block-dangerous-git.sh
├── examples/
│   └── CLAUDE.md.snippet    — for the manual-copy install path
├── docs/
│   └── skills-audit.md      — verdict on all 38 candidate skills considered
├── README.md
└── LICENSE                  — MIT
```

---

## Credits

EvanFlow synthesizes ideas from:

- **[mattpocock/skills](https://github.com/mattpocock/skills)** by Matt Pocock — vertical-slice TDD, deep modules, deletion test, design-it-twice, ubiquitous language, grill-me, caveman.
- **[superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — verification-before-completion, code review patterns, parallel agent dispatch, finishing-a-development-branch (the 4-option presentation).
- **[git-guardrails-claude-code](https://github.com/mattpocock/skills/tree/main/git-guardrails-claude-code)** — bundled in `hooks/` (script copied verbatim). Original by Matt Pocock.

Industry research informing the design:

- Anthropic's [2026 Agentic Coding Trends Report](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf?hsLang=en)
- [9 Critical Failure Patterns of Coding Agents (DAPLab, Columbia)](https://daplab.cs.columbia.edu/general/2026/01/08/9-critical-failure-patterns-of-coding-agents.html)
- [Test-Driven Development for Code Generation](https://arxiv.org/pdf/2402.13521) (arXiv 2402.13521) — assertion-correctness findings

---

## License

MIT. See [LICENSE](LICENSE).

---

## Contributing

Issues and pull requests welcome. EvanFlow is opinionated by design — proposals to add ceremony or auto-actions will be politely declined. Proposals to **further reduce** ceremony, sharpen rules, or add evidence-backed improvements are very welcome.
