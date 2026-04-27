# Skills Audit — EvanFlow Synthesis

**Scope:** All 38 candidate skills considered (17 from `superpowers` + 21 from `mattpocock/skills`) when designing EvanFlow.

**Outcome:** 15 custom `evanflow-*` skills authored; 2 custom subagents in `agents/`; 6 upstream skills recommended kept as-is for users who want them; 19 cut.

---

## Verdicts

Three categories:

- **synthesize-into-evanflow** — philosophy/content distilled into a custom `evanflow-*` skill. Upstream skill is NOT bundled.
- **install-as-is (recommended)** — keep upstream version unchanged; no equivalent evanflow needed. (Not bundled in this repo — install separately if you want them.)
- **cut** — not recommended for EvanFlow users.
- **rejected entirely** — concept itself is incompatible with EvanFlow's principles.

---

## Superpowers (17 skills)

| Skill | Verdict | Reason |
|---|---|---|
| `using-superpowers` | **cut** | "Must invoke a skill before any response, even 1% chance" rule incompatible with EvanFlow's "no skill tax" principle. |
| `brainstorming` | **synthesize → evanflow-brainstorming** | Process structure good; rigidity (forced spec path, forced visual companion offer, auto-commit) doesn't fit. EvanFlow version drops these. |
| `writing-plans` | **synthesize → evanflow-writing-plans** | Bite-sized tasks good. Forced "REQUIRED SUB-SKILL" header and forced vendor-specific path removed. |
| `executing-plans` | **synthesize → evanflow-executing-plans** | Task-by-task discipline good. Forced sub-skill chains made opt-in. Adds parallelization-check step 0. |
| `test-driven-development` | **synthesize → evanflow-tdd** | RED-GREEN-REFACTOR preserved. "Iron Law: delete code without a failing test" dropped — too strict for prototypes. Mattpocock's vertical-slice framing replaces it. |
| `finishing-a-development-branch` | **rejected entirely** | The agent never auto-finishes in EvanFlow. The user explicitly directs every commit, push, merge, and PR. There is no replacement skill — when the user says "commit", just commit. |
| `systematic-debugging` | **synthesize → evanflow-debug** | Root-cause discipline preserved. Adds embedded grill on the hypothesis. |
| `requesting-code-review` | **synthesize → evanflow-review (combined)** | Combined with `receiving-code-review` since they're two halves of the same cycle. |
| `receiving-code-review` | **synthesize → evanflow-review (combined)** | See above. |
| `writing-skills` | **install-as-is (recommended)** | Used to author EvanFlow skills themselves. Already lean and rigorous. |
| `verification-before-completion` | **install-as-is (recommended)** | Pure rule, zero rigidity. Baked into evanflow-executing-plans by reference. |
| `dispatching-parallel-agents` | **install-as-is (recommended)** | Pattern, not workflow. Used inside evanflow-design-interface and evanflow-coder-overseer. |
| `using-git-worktrees` | **install-as-is (recommended)** | Standalone utility for big isolated work. Not in default loop, not rigid. |
| `subagent-driven-development` | **install-as-is (recommended)** | Escape hatch for huge plans. `evanflow-coder-overseer` is the EvanFlow variant with role separation. |
| `brainstorm` (deprecated) | **cut** | Already deprecated upstream. |
| `execute-plan` (deprecated) | **cut** | Already deprecated upstream. |
| `write-plan` (deprecated) | **cut** | Already deprecated upstream. |

---

## mattpocock/skills (21 skills)

| Skill | Verdict | Reason |
|---|---|---|
| `tdd` | **synthesize → evanflow-tdd** | Primary source for vertical-slice TDD framing. Tests verify behavior through public interfaces, not internals. Now also includes assertion-correctness warning (62% of LLM assertions wrong per HumanEval research). |
| `improve-codebase-architecture` | **synthesize → evanflow-improve-architecture** | Deletion test, deep-modules vocabulary, seams. Adds embedded grill on candidate selection. |
| `design-an-interface` | **synthesize → evanflow-design-interface** | "Design it twice" via parallel sub-agents. Adds embedded grill on the synthesized choice. |
| `ubiquitous-language` | **synthesize → evanflow-glossary** | Drives `CONTEXT.md`. Format and re-invocation behavior preserved. |
| `to-prd` | **synthesize → evanflow-prd** | Synthesis-not-interview pattern preserved. Adds explicit "ask before `gh issue create`" rule. |
| `qa` | **synthesize → evanflow-qa** | Conversational bug-discovery flow preserved. Adds explicit "ask before `gh issue create`" rule. |
| `grill-me` | **synthesize → embedded in planning skills** | Not a separate skill in EvanFlow. Embedded as a labeled "Embedded Grill" section inside evanflow-brainstorming, writing-plans, improve-architecture, design-interface, debug. |
| `caveman` | **install-as-is (recommended)** | Token-compression mode. Too small to evanify. |
| `git-guardrails-claude-code` | **install-as-is (bundled)** | Hook script bundled in `hooks/block-dangerous-git.sh` — the only upstream artifact this repo includes. |
| `setup-pre-commit` | **cut** | Pre-commit setup is project-specific (lint-staged config etc.). Skill not generally needed. |
| `domain-model` | **cut** | Overlaps `ubiquitous-language` for most use cases. |
| `write-a-skill` | **cut** | Use `superpowers:writing-skills` (more rigorous, TDD-on-skills). |
| `request-refactor-plan` | **cut** | Overlaps `evanflow-improve-architecture` + `evanflow-writing-plans`. |
| `to-issues` | **cut** | Overlaps `evanflow-qa` + manual issue creation. |
| `triage-issue` | **cut** | Overlaps `evanflow-qa`. |
| `zoom-out` | **cut** | Tiny utility; redundant with normal exploration. |
| `obsidian-vault` | **cut** | Obsidian-specific. |
| `scaffold-exercises` | **cut** | For teaching exercises. |
| `edit-article` | **cut** | For article editing. |
| `migrate-to-shoehorn` | **cut** | Library-specific (shoehorn TS lib). |
| `github-triage` | **cut** | Niche. |

---

## EvanFlow-Native Skills (Not From Either Vendor)

| Skill | Origin | Why |
|---|---|---|
| `evanflow` (meta) | EvanFlow philosophy | The index. Shared vocabulary + when to invoke each `evanflow-*` skill. |
| `evanflow-go` | User feedback | **Single entry-point orchestrator.** Triggered by phrases like "evanflow this" / "use evanflow". Walks the whole loop end-to-end with checkpoints. Conductor, not autopilot. |
| `evanflow-iterate` | User feedback | Self-review loop after implementation. Re-read diff, fix issues, re-run checks, screenshot UI. Hard cap of 5. Five Failure Modes checklist. |
| `evanflow-coder-overseer` | User feedback | Parallel orchestration variant of subagent-driven-development. Cohesion contract → RED checkpoint → coders (vertical-slice TDD) → per-coder overseers → integration overseer (runs touchpoint tests). |
| `evanflow-compact` | 2025-2026 industry research | Long-session context management. Industry research found ~65% of agent failures trace to context drift, not raw token exhaustion. |

---

## Custom Subagents (`agents/`)

| Subagent | Tools | Purpose |
|---|---|---|
| `evanflow-coder` | Read, Edit, Write, Glob, Grep, Bash, TodoWrite | Implementation subagent for `evanflow-coder-overseer`. Tool restrictions + system prompt prevent git ops, out-of-scope file edits, hallucinated values. |
| `evanflow-overseer` | Read, Grep, Glob | Read-only review subagent. Tools enforce "report findings, never fix" — physically cannot modify code. |

---

## Evidence-Backed Improvements (research-driven additions)

The following were added based on 2025-2026 industry research on agentic coding:

1. **`evanflow-compact`** — context drift = ~65% of enterprise AI failures. Anthropic shipped `compact-2026-01-12` API. Tools like Spring AI, OpenCode have explicit compaction strategies.
2. **"No hallucinated values" hard rule** in `evanflow` meta — action-hallucination is a top-rated agent failure mode.
3. **Assertion-correctness warning** in `evanflow-tdd` and the coder-overseer overseer instructions — research finding (HumanEval, four LLMs): over 62% of LLM-generated test assertions were incorrect.
4. **Five Failure Modes checklist** (hallucinated actions, scope creep, cascading errors, context loss, tool misuse) in `evanflow-iterate` and overseer instructions in `evanflow-coder-overseer` — explicit check pass per category.
5. **Custom subagents** `evanflow-coder` and `evanflow-overseer` — tool restrictions enforce role separation in `evanflow-coder-overseer`, not just discipline.
