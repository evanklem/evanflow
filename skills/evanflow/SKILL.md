---
name: evanflow
description: Meta skill for the EvanFlow system. Loads the shared vocabulary (deep modules, deletion test, vertical slice, grill, mockup quick-mode, no-auto-commit) and describes when to invoke each evanflow-* skill. Use when starting a new task and unsure which evanflow skill applies, or when you need to ground reasoning in the shared vocabulary.
---

# EvanFlow

A TDD-driven iterative feedback loop for software development with Claude Code. 16 cohesive skills + 2 custom subagents walk an idea from brainstorm → plan → execute → tdd → iterate, with checkpoints throughout. Vertical-slice TDD, parallel coder/overseer review, executable cohesion contracts, context compaction. Never auto-commits — the user controls every git op.

## Single Entry Point: `evanflow-go`

When the user says "let's evanflow this", "use evanflow", "evanflow this idea", "run this through evanflow", or anything similar — invoke `evanflow-go`. It's the orchestrator that walks the entire loop end-to-end (brainstorm → plan → execute → tdd → iterate → STOP), announces each step, respects checkpoints (design approval, plan approval), and hands off to the right sub-skill at each phase. The user gets the full EvanFlow workflow without having to remember which sub-skill applies when.

`evanflow-go` is conductor, not autopilot — every checkpoint is real and the user can interrupt or switch paths anytime.

## Shared Vocabulary

Every `evanflow-*` skill speaks this. Cross-reference here, don't redefine.

- **Module** — any unit with interface + implementation (function, class, package). Scale-agnostic.
- **Interface** — complete caller knowledge: type signature, invariants, ordering constraints, error modes, performance characteristics.
- **Depth** — large behavior behind a small interface = deep (good). Large interface, thin behavior = shallow (avoid).
- **Seam** — where an interface lives; a place behavior can shift without editing in place.
- **Adapter** — concrete implementation satisfying an interface at a seam.
- **Deletion test** — does removing this module concentrate complexity across N callers, or does complexity vanish? The first is a real module; the second is bloat.
- **Vertical slice** — one test → one impl → repeat. Never write all tests first then all code (horizontal slicing produces tests of imagined behavior).
- **Behavior through public interface** — tests describe *what*, not *how*. They survive refactors. If a rename breaks a test but behavior didn't change, the test was wrong.
- **Grill** — opt-in interview pattern, embedded as a labeled section inside planning skills. Stress-test before committing to a path. Not a separate skill invocation in EvanFlow.
- **Ubiquitous language** — canonical domain terms in `CONTEXT.md`. New terms added as discovered.
- **Mockup quick-mode** — when user just wants visual concepts, skip spec/plan ceremony. Produce mockups directly in whatever form the project uses (HTML files, Figma frames, ASCII layouts, etc.) — no full design loop required.

## Hard Rules (apply to every evanflow skill)

- **Never auto-commit, never auto-stage, never auto-finish.** Every git write op (`commit`, `push`, `merge`, `rebase`, `tag`, `branch -d/-D`) requires the user to explicitly ask for it in the current turn. Even `git add` should not happen on the agent's initiative — leave files unstaged until the user signals they're about to commit.
- **No "finish/integrate" workflow on the agent's initiative.** After implementation + iterate, the agent reports what was done and **stops**. The user decides whether to commit, merge, open a PR, keep iterating, or change direction.
- **Never invent values you don't authoritatively have.** This includes: file paths, env var values, API keys, secret values, IDs (UUIDs, foreign keys, third-party object IDs), URLs, port numbers, hostnames, version numbers, third-party service names, function names you haven't verified exist. **If unsure, STOP and ask** — don't guess. Action-hallucination (an agent confidently doing the wrong thing) is the most dangerous failure mode in agentic coding (industry research, 2026). The cost of asking is one round-trip; the cost of acting on a hallucinated value is potentially catastrophic.
- **Watch for context drift.** If you find yourself re-asking established questions, contradicting earlier decisions, or losing track of constraints set earlier in the session, invoke `evanflow-compact` to preserve anchors and propose a `/clear`. ~65% of agent failures trace to context drift, not raw token exhaustion.
- **No skill tax.** Ad-hoc questions don't require a skill invocation. Skills are tools, not a tollbooth.
- **No forced spec/plan paths.** Specs and plans live wherever the user wants. Default to `docs/` only if no preference is stated.
- **No forced sub-skill chains.** Each evanflow skill stands alone. Hand-offs are suggestions, not mandates.
- **Verify before claiming done.** Run the project's quality checks (typecheck, lint, test) and confirm output before reporting completion.

## The Default Loop

```
1. (optional)  evanflow-brainstorming   — clarify intent, propose 2-3 approaches, embedded grill.
                                          Mockup-only requests use mockup quick-mode.
                                          (Hands off to evanflow-prd for substantial features.)
2. (if non-trivial) evanflow-writing-plans — file structure, bite-sized tasks, embedded grill.
                                          Step 2.5: parallelization check — offers
                                          coder-overseer if 3+ independent units exist.
3. EXECUTE     evanflow-executing-plans  — task harness: critical review, TaskCreate, inline
                                          verification, blockers, quality checks. Step 0:
                                          parallelization check (offers coder-overseer).
        OR     evanflow-coder-overseer   — same harness role, parallel: contract → RED checkpoint →
                                          coders → per-coder overseers → integration overseer.

   ↳ INSIDE every code-writing task in EXECUTE:
       evanflow-tdd                      — vertical-slice RED → GREEN → REFACTOR per cycle.
                                          NOT a separate phase. The discipline that runs
                                          inside the task harness for any production code.

4.             evanflow-iterate          — self-review loop AFTER all tasks are done:
                                          re-read diff, fix issues, re-run checks,
                                          (UI) view the page. Repeat until clean.
5.             STOP. Report what was done. Await user direction.
```

**The loop is interlinked end-to-end.** Each step actively offers the right next-step skill when conditions match — including offering `evanflow-coder-overseer` at both planning time (step 2) and execution time (step 3) when the plan is parallelizable.

**Cross-cutting:** `evanflow-compact` runs alongside the loop whenever context drift symptoms appear or at clean phase boundaries. Don't wait for token-limit warnings — proactive compaction at boundaries is far higher quality than reactive mid-flow compaction.

**There is no auto-commit, no auto-finish, no auto-integration step.** The user controls when to commit, when to merge, when to push, when to open a PR. After step 5, the agent reports and waits.

Ad-hoc questions, quick mockups, exploratory reads: **no skill invoked**. Just answer.

## When to Invoke Each Skill

| Trigger | Skill |
|---|---|
| **"Let's evanflow this" / "use evanflow" / "evanflow this idea" / any "run this through evanflow"** | **`evanflow-go`** (entry point — walks the whole loop) |
| "Help me think through X" / "I want to build Y" / new feature scoping (without saying "evanflow") | `evanflow-brainstorming` (or invoke `evanflow-go` if user wants the full loop) |
| "Plan out Z" / spec exists, ready to break into tasks | `evanflow-writing-plans` |
| "Execute the plan" / picking up an existing plan doc | `evanflow-executing-plans` |
| Any production code change | `evanflow-tdd` |
| "Polish this" / "review this" / "make sure it's clean" / after implementation | `evanflow-iterate` |
| Plan has 3+ truly independent parallel tasks with a shared contract | `evanflow-coder-overseer` (instead of `evanflow-executing-plans`) |
| Long session, drift symptoms, major phase boundary, or session feels heavy | `evanflow-compact` |
| "Commit this" / "push" / "merge" / "open a PR" — **user-initiated only** | (no skill — just do it directly when explicitly asked) |
| "Write a PRD for X" / new feature in PRD shape | `evanflow-prd` |
| "Refactor X" / "this file is too big" / architecture concerns | `evanflow-improve-architecture` |
| "Design the API for X" / interface design | `evanflow-design-interface` |
| "Update CONTEXT.md" / new domain term emerged | `evanflow-glossary` |
| "Debug Y" / unexpected behavior, root-cause needed | `evanflow-debug` |
| Code review (giving or receiving) | `evanflow-review` |
| "File a bug for X" / QA session | `evanflow-qa` |
| Token-heavy session, want compression | `caveman` (upstream, kept as-is) |

## Compatible Tooling

EvanFlow is self-contained — none of these are required. But some standalone utilities from other Claude Code skill sets compose well alongside if you happen to have them installed:

- A **git worktrees** skill, for isolating big refactors
- A **verification-before-completion** rule (already baked into `evanflow-executing-plans` and `evanflow-iterate`)
- A **parallel-agents** dispatch pattern (already used inside `evanflow-design-interface` and `evanflow-coder-overseer`)
- A **token-compression** mode for very long sessions (complements `evanflow-compact`)

For the historical record of which existing-ecosystem skills inspired which EvanFlow skills, and which were deliberately not adopted, see `docs/skills-audit.md`.
