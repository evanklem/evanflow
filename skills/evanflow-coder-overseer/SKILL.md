---
name: evanflow-coder-overseer
description: Orchestrate parallel implementation with coder/overseer pairs. Coders implement decomposed tasks using evanflow-tdd; overseers review each coder's output for bugs, gaps, errors, AND cohesion violations against a shared contract. A final integration overseer checks cross-coder cohesion. Use for plans with 3+ truly independent tasks that share an interface contract.
---

# EvanFlow: Coder-Overseer Orchestration


## Vocabulary

See `evanflow` meta-skill for shared terms. New roles introduced here:

- **Orchestrator** — the main Claude session running this skill. Authors the contract, decomposes work, spawns subagents, reconciles findings, reports to the user.
- **Coder** — subagent dispatched to implement one decomposed unit. Uses `evanflow-tdd`. Writes tests first. Outputs code + tests + brief summary.
- **Overseer** — subagent dispatched to review ONE coder's output. Looks for bugs, gaps, errors, and contract violations. **Reports findings; does NOT fix them.**
- **Cohesion contract** — the shared interfaces, types, invariants, and naming that must hold across ALL coder outputs. A short doc, authored by the orchestrator before any agent spawns.
- **Integration overseer** — a final subagent that reviews the *combined* output across all coders, catching inter-task cohesion drift that single-coder overseers can't see (boundary type mismatches, naming inconsistency, missed invariants).

## When to Use

- Plan has **3+ truly independent tasks** that can run in parallel
- Tasks share a contract (interfaces, types, naming) where divergence is a bug
- Work benefits from independent review (complex routers, multi-file refactors, new modules with cross-cutting concerns)

**SKIP when:**
- Plan has tightly sequential dependencies → use `evanflow-executing-plans` instead
- Tasks are trivial (orchestration overhead > benefit)
- A single agent can hold the whole thing in context comfortably

## The Flow

### 1. Author the Cohesion Contract (with Test Specifications)

Before spawning anyone, the orchestrator writes a contract at `.claude/orchestration/<topic>-contract.md` (or any path the user prefers). Contents:

- **Shared types and interfaces** — with full file paths and signatures
- **Naming conventions** for new symbols (e.g., "router files are `<resource>.ts`, services are `<resource>-service.ts`")
- **Invariants** that must hold (e.g., "all routes use the authenticated middleware", "all services return `Result<T, Error>`", "all DB writes go through the canonical write helper documented in CLAUDE.md")
- **Cross-references** to `CONTEXT.md` and relevant ADRs
- **Integration touchpoints** — where coder outputs must connect (e.g., "router A imports type X from package B; service C calls function D from service E")
- **Behavior specifications per coder** — for EACH coder, list 3–7 testable behaviors with: a test name, a one-line description of the assertion, and the public interface used to verify it. Example:
  ```
  ### Coder 2: rate-limit service (example)

  - test: returns full cap when no usage recorded
    assert: `getRemainingThisWeek(userId)` returns `{ remaining: 25, resetsAt: null }` for a fresh user
    surface: services/rate-limit.ts (public)

  - test: counts ACTIVE and PENDING rows but excludes CANCELLED/FAILED
    assert: after seeding rows of varied statuses, `getRemainingThisWeek` returns the correct count
    surface: services/rate-limit.ts (public)
  ```
- **Integration tests at touchpoints** — for every place where one coder's output is consumed by another, name an integration test that proves the connection works end-to-end. Both coders must satisfy it. **Integration tests become the executable contract** — they prevent interface drift the way prose specifications can't.

The contract is the **single source of truth** for everyone downstream. If it's wrong or ambiguous, fix it BEFORE spawning agents — patching the contract mid-orchestration causes drift.

### 2. Decompose into Coder Tasks

Each coder task is a self-contained brief. Includes:

- **One unit of work** — one file, or one logical module
- **Files to create/modify** with exact paths
- **Required behaviors to test** (behavior, not mechanics — see `evanflow-tdd`)
- **Reference to the contract** with explicit "must conform to" pointers
- **Explicit out-of-scope list** so the coder doesn't expand

**Max 5 coders in parallel.** More than that is unmanageable to review.

### 3. Spawn Coders — RED Checkpoint First

Coder dispatch happens in **two phases** to enforce TDD at the orchestration level.

**Phase A — RED checkpoint.** Single message, multiple `Agent` calls. **Prefer `subagent_type: evanflow-coder` if available** (tool-restricted to prevent git ops and other dangerous actions); else `general-purpose`. Each coder gets:

- The self-contained brief from step 2
- Path to the contract
- Path to the plan
- Instructions:
  > "Phase A: write ONLY the first failing test for your first behavior (per the contract's test list for your section). Run it. Confirm it fails for the right reason — not a setup error, not an import error, not a missing dependency. Report back: test file path, test name, the exact failure message, and confirmation that the failure matches expected behavior. Do NOT write any implementation yet. Do NOT touch any production source file other than minimal scaffolding (e.g., empty function stubs that exist only so the import resolves)."

After all coders return Phase A reports, **the orchestrator verifies every test is RED**:

- Run the project's test command for affected workspaces
- Confirm each coder's named test appears in the failure list
- Confirm the failure reason matches what the coder reported
- Catch: tests passing accidentally (assertion is too weak), tests failing for wrong reason (setup bug), tests not actually running (wrong filename pattern)

If any test isn't cleanly RED, send that coder back with the specific issue. Do NOT proceed to Phase B until all RED reports check out.

**Phase B — vertical-slice GREEN.** Re-message each coder:

- Instructions:
  > "RED checkpoint confirmed. Phase B: vertical-slice TDD per `.claude/skills/evanflow-tdd/SKILL.md`. One test → minimal impl → confirm GREEN → next test → repeat. Cover ALL behaviors named in the contract for your section. **Watch each test fail before writing the implementation that makes it pass.** Conform to the contract exactly — if a test name in the contract is unclear or wrong, stop and report back instead of guessing. Do NOT modify files outside your task scope. Do NOT commit, stage, or run any git op. When done, report: files changed, every test name + status, integration tests touched (if any), anything deferred."

Coders run Phase B in parallel.

### 4. Spawn Overseers — One Per Coder

After each coder reports done, spawn its overseer. **Prefer `subagent_type: evanflow-overseer`** (the bundled read-only subagent — its tool restrictions enforce "report findings, never fix"). If a specialized code-reviewer subagent is available in your environment, that also works. Else `general-purpose`.

Each overseer gets:
- The coder's diff (orchestrator runs `git diff <files>` and passes it inline)
- The coder's original brief
- The contract
- The coder's Phase A and Phase B reports
- Instructions:
  > "Review the diff for:
  >   (a) **bugs** — wrong logic, off-by-ones, race conditions, missing error handling
  >   (b) **gaps** — behaviors in the contract that aren't tested or aren't implemented
  >   (c) **errors** — type unsafety, missing validation at boundaries, wrong domain language
  >   (d) **cohesion violations** — anything that diverges from the contract
  >   (e) **TDD compliance** — was each test written before the code that makes it pass? (Check Phase A report for RED, then Phase B order.) Are tests behavior-through-public-interface, or do they reach into internals? Would the tests survive a refactor that doesn't change behavior?
  >   (f) **ASSERTION CORRECTNESS** — research shows 62% of LLM-generated test assertions are wrong. For each assertion: would a one-character bug in the implementation still let it pass? If yes, the assertion is too weak. Is the assertion on the right field? Is the expected value computed correctly?
  >   (g) **Five Failure Modes** — explicit pass against each:
  >       - **Hallucinated actions** — invented paths, env vars, IDs, function names, library APIs not in the contract or codebase?
  >       - **Scope creep** — files or behaviors touched outside the brief?
  >       - **Cascading errors** — silent fallbacks, swallowed exceptions, suppressed failures that hide root cause?
  >       - **Context loss** — contradicts the contract, CONTEXT.md, ADRs, or established conventions?
  >       - **Tool misuse** — wrong tool for the job, or right tool with wrong params?
  > Report findings as a numbered list, each tagged severity (blocker / important / nit) and location (file:line). Do NOT propose fixes. Do NOT modify files. Do NOT commit, stage, or run git ops.
  >
  > If using the `evanflow-overseer` subagent type, your tool restrictions (read-only) enforce this — you literally cannot fix, only report."

Prefer `subagent_type: evanflow-overseer` (tool-restricted to enforce read-only review). Else any specialized code-reviewer subagent your environment provides, or `general-purpose`.

Overseers run in parallel — single message, multiple `Agent` calls.

### 5. Spawn the Integration Overseer

After all coder/overseer pairs return, spawn ONE final overseer (use `evanflow-overseer` again, or any specialized code-reviewer subagent your environment provides). Inputs:

- The combined diff across all coders (orchestrator runs `git diff` against the working tree)
- The contract
- All individual overseer reports inline
- Instructions:
  > "You're checking cohesion across multiple coders' outputs. Look for:
  >   (a) **type mismatches at boundaries** — one coder produces type X, another expects type X'
  >   (b) **naming drift** — resource called `Foo` in one file, `Foos` in another, `foo_id` vs `fooId` inconsistencies
  >   (c) **invariants applied inconsistently** — e.g., one router uses `authenticatedProcedure`, another forgot
  >   (d) **integration points that don't connect** — coder A exports something coder B doesn't import, or shapes don't match
  >   (e) **integration tests at touchpoints** — for every touchpoint named in the contract, verify a passing integration test exists. Run it. Confirm it actually exercises the connection (not a stub or a mock). The integration test IS the executable contract; if it doesn't exist or doesn't verify, the cohesion guarantee is unproven.
  > Report findings tagged by severity and affected files. Do NOT fix."

### 6. Reconcile

Orchestrator collects every overseer finding:

- **Group by severity:** blocker → important → nit
- **Decide per finding:**
  - Send back to specific coder for revision (preserves coder ownership; recommended for important/blocker that touch one coder's work)
  - Fix in main session (when the issue spans multiple coders or is a contract update)
  - Drop / accept (for nits the user wouldn't care about)
  - Escalate to user (when the right answer isn't clear)

For revisions: spawn that coder again with: original brief + the finding + their existing diff + "fix only this finding; don't expand scope." Re-run that coder's overseer afterward.

**Hard cap: 3 reconciliation rounds.** If still issues at round 3, the original decomposition or the contract was wrong — stop, report state, ask the user.

### 7. Stop and Report

When all overseers report clean (or remaining findings explicitly accepted):

- Run project-wide quality checks (`tsc`, `lint`, `test:run` for affected workspaces)
- **Report what was done across all tasks. STOP.** No staging, no commit, no integration step. The user decides every step from here.

A good final report:
- One line per coder: "Coder N — `<files>` — <one-line summary>"
- Test count delta
- Quality check results
- Any deferred findings (with reason for accepting)

## Hard Rules

- **Contract first, with test specifications.** No coder spawned before the contract is written, including per-coder behavior lists with test names AND named integration tests at every touchpoint.
- **RED checkpoint before any implementation.** Phase A (failing test) precedes Phase B (impl). Orchestrator verifies all tests are cleanly RED before authorizing GREEN. Catches setup bugs and accidentally-passing tests before they cost a full coder cycle.
- **Coders use `evanflow-tdd`** in Phase B. Vertical slices: one test → impl → next. Watch each test fail before writing the impl that passes it.
- **Integration tests at touchpoints are mandatory.** Where coder A's output is consumed by coder B, a passing integration test must exist that exercises the connection. The test is the executable contract.
- **Overseers report, never fix.** Separation of roles is the point. If overseers fix, you lose the QA signal.
- **Max 5 coders in parallel.** Beyond that, the integration overseer can't hold the whole picture.
- **Max 3 reconciliation rounds.** If you can't converge in 3, the decomposition was wrong.
- **No coder talks to another coder.** All coordination flows through the contract + orchestrator. This prevents emergent miscommunication.
- **Never auto-commit, never auto-stage.** Same hard rule as everywhere else in EvanFlow.

## Hand-offs

- Plan has 3+ parallelizable tasks → THIS skill (replaces `evanflow-executing-plans` for that subset)
- Tasks turn out to have hidden dependencies mid-execution → abort, switch to `evanflow-executing-plans` (sequential)
- Findings reveal an architectural issue → `evanflow-improve-architecture`
- All clean → **STOP. Report. Await user direction.**

## Why "Coders" and "Overseers" (vs. one combined role)

The split exists because **you can't trust a coder to be its own reviewer.** A coder optimizes for "make my task pass." An overseer optimizes for "find what's wrong." Different incentives produce different attention. Combining them means review-during-implementation, which catches less.

The integration overseer exists because **per-task overseers can't see the whole.** Each one has a narrow window — the contract + one diff. Boundary mismatches between two diffs are invisible from inside either. The integration overseer's job is the cross-section view.

## Why TDD-on-Orchestration (RED Checkpoint + Integration Tests)

**The cohesion contract is prose. Integration tests are executable.** Prose contracts drift the moment two people read them differently. A failing integration test cannot drift — either it passes, or someone's wrong. Forcing integration tests at every touchpoint converts cohesion from a hope into a guarantee.

**The RED checkpoint catches the cheapest class of failures cheaply.** A test that imports the wrong file, a test that asserts on the wrong field, a test that doesn't actually run — all of these are invisible while you're writing implementation. Catching them before any coder writes real code saves the entire coder + overseer cycle.

**Vertical slices per coder prevent imagined-behavior tests.** If a coder writes 7 tests up front and then 7 implementations, the tests describe what the coder *thought* the system would do, not what it *does*. One test → one impl → next test forces the tests to track what the code actually does.
