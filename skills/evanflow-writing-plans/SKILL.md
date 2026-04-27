---
name: evanflow-writing-plans
description: Turn a spec or requirements into a bite-sized implementation plan. File-structure-first (deep modules), embedded grill to stress-test, no forced sub-skill chains. Use when you have a spec or clear requirements and are ready to plan execution.
---

# EvanFlow: Writing Plans



## Vocabulary

See `evanflow` meta-skill. Key terms: **deep modules**, **interface**, **vertical slice**, **deletion test**.

## When to Use

- A spec or clear requirements exist
- Multi-step task that benefits from upfront decomposition
- About to touch ≥3 files

**SKIP when:** single-file change, typo fix, one-line config tweak. Just do it.

## The Flow

### 1. Scope Check

If the spec covers multiple independent subsystems, suggest splitting into separate plans. Each plan should produce working, testable software on its own.

### 2. File Structure First

Before any tasks, name the files that will be created or modified, with a one-line responsibility for each. This locks in decomposition decisions.

Example (adapt the paths to your project's structure):

```
<backend>/routers/foo.ts          — API router; thin, delegates to service
<backend>/services/foo.ts         — business logic; pure where possible
<backend>/services/foo.test.ts    — vertical-slice tests
<frontend>/pages/foo.tsx          — UI; consumes the API
```

Apply the **deletion test**: if a file would just shuffle complexity to its callers, fold it into the caller.

### 2.5. Parallelization Check (offer coder-overseer if applicable)

After the file structure is sketched, ask: **does this plan have 3+ truly independent units that share a common interface contract?**

If YES — offer `evanflow-coder-overseer` to the user as the execution path:

> "This plan has [N] independent units sharing [contract]. We could execute it sequentially via `evanflow-executing-plans`, or in parallel via `evanflow-coder-overseer` (one coder per unit + per-coder overseer + integration overseer + executable contract via integration tests). Parallel is faster for big plans and adds independent QA, but only works if the units are truly independent. Which?"

Signals that favor coder-overseer:
- 3+ files/modules that don't import each other
- A clear shared interface contract (types, naming, invariants)
- Integration touchpoints that can be expressed as named integration tests
- Plan would otherwise be tedious to execute serially

Signals that favor sequential `executing-plans`:
- Tasks have hidden dependencies (one's output feeds the next)
- Fewer than 3 units
- No shared contract surface — units don't need to interoperate
- Risk-averse work (auth, payments, migrations) where a single careful pass beats parallelism

If the user picks coder-overseer, structure the plan with a per-coder section and the cohesion contract upfront. If sequential, continue to step 3 normally.

### 3. Embedded Grill

Stress-test the structure before writing tasks:

- "Where does this go wrong if the user does X?"
- "What happens if this fails halfway? What's the recovery?"
- "Is there an existing service in the project that already does part of this?"
- "Does the file structure follow project conventions documented in CLAUDE.md or visible in similar existing files?"
- "Are we introducing or changing domain terms? Update `CONTEXT.md` first?"

### 4. Bite-Sized Tasks

Each task is one focused unit (~15-30 min of work). Within each task, list bite-sized steps (~2-5 min each):

```markdown
### Task 1: [Component Name]

**Files:** Create `path/to/foo.ts`, modify `path/to/bar.ts:123-145`, test `path/to/foo.test.ts`

- [ ] Write the failing test (one behavior — see evanflow-tdd)
- [ ] Run test, confirm it fails for the right reason
- [ ] Write minimal implementation
- [ ] Run test, confirm it passes
- [ ] Run the project's quality checks (typecheck / lint / test) — exact commands are project-specific; see CLAUDE.md or the project's README
```

After all tasks complete, the executor hands off to `evanflow-iterate` for self-review, then **stops and reports**. The plan does NOT include staging or committing — the user controls those.

### 5. Plan Header (lighter than upstream)

```markdown
# [Feature Name] Plan

**Goal:** [one sentence]
**Architecture:** [2-3 sentences]
**Files:** [list from step 2]

---
```

**No "REQUIRED SUB-SKILL" header.** Sub-skills are suggestions documented inline at hand-off points, not mandates baked into the plan format.

### 6. Save the Plan

Default location: `docs/plans/YYYY-MM-DD-<topic>.md`. If the user has a different preference, honor it. Don't write to any vendor-specific path unless explicitly asked.

## Hard Rules

- **Never include staging or commit steps in the plan.** Plans end at "verified, await user direction." The user decides when to stage, commit, push, merge.
- **No forced sub-skill chain.** No "must use using-git-worktrees" or "must use subagent-driven-development" header.
- **Plans live where the user wants.** Default `docs/plans/` only if no preference stated.
- **TDD by default.** Every code task is structured as test-first. Exceptions (configs, schemas, prototypes) are flagged inline.

## Hand-offs

- Plan written → `evanflow-executing-plans`
- Need to design an API surface first → `evanflow-design-interface`
- Architecture concerns surfaced → `evanflow-improve-architecture` first, then back here
