---
name: evanflow-tdd
description: Vertical-slice TDD for any production code. One test → one impl → repeat. Tests verify behavior through public interfaces, not internals. Use when implementing any feature, bugfix, or behavior change.
---

# EvanFlow: TDD




## Vocabulary

See `evanflow` meta-skill. Key terms: **vertical slice**, **behavior through public interface**, **deep module**.

## Core Principle

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't break unless behavior changes.

**Good test:** "user can perform action X within their weekly rate limit" — describes capability.

**Bad test:** "calls `createX()` with status `'QUEUED'` then queues a job" — describes mechanics. Renames break it.

## Anti-Pattern: Horizontal Slices

**DO NOT** write all tests first then all implementation. That produces tests of *imagined* behavior, not *actual* behavior. They become insensitive to real changes.

**DO** vertical slices: one test → one implementation → repeat. Each test responds to what you learned from the previous cycle.

## When to Use

- Any production code change (new feature, bug fix, behavior change, refactor with behavior implications)
- All new code in your backend's routers and services
- All new code in your frontend that has testable logic (not pure-presentation components)

## When to Skip (with explicit user approval)

- Throwaway prototypes
- Generated code (e.g., `database.types.ts`)
- Configuration files
- Pure-presentation React components with no logic

## The Flow

### 1. Embedded Grill — "What to Test"

Before writing any test, confirm with the user:

- "Which behaviors matter most? We can't test everything."
- "What's the public interface — what will callers actually use?"
- "Are there opportunities to make this a deep module (small interface, complex internals)?"
- "Where do tests need to integrate with real services (DB, payment provider, email provider) vs. where can we test in isolation?"

**Default to integration-style tests against real services** (real DB, real queue, real cache) where feasible. Mocked dependencies frequently mask divergence between test and production behavior. Document any project-specific exception in your CLAUDE.md.

### 2. Tracer Bullet

Write ONE test for ONE behavior end-to-end. Prove the path works.

```
RED:   Write test → run → confirm it fails for the RIGHT reason
GREEN: Write minimal code → run → confirm it passes
```

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass the current test
- Don't anticipate future tests
- Tests focus on observable behavior, not internals

### 4. Refactor

After all tests pass:

- Look for duplication
- Look for **deepening opportunities**: small interface hiding complex implementation (deletion test applies)
- Run tests after each refactor step
- **Never refactor while RED.** Get to GREEN first.

## Per-Cycle Checklist

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive an internal refactor (rename, restructure)
[ ] Code is minimal for this test
[ ] No speculative features added
[ ] Test fails for the right reason before code is written
[ ] ASSERTION IS CORRECT — see warning below
```

## ⚠️ Assertion-Correctness Warning

**Industry research (HumanEval evaluation across four LLMs) found that over 62% of LLM-generated test assertions were incorrect.** This is the single most likely failure mode in LLM-driven TDD: the test passes, but it's testing the wrong thing.

Before writing any test assertion, verify:

- **Does this assertion match what the user actually wants?** Don't assert on behavior you imagined — assert on behavior the spec/contract names.
- **Is this the assertion's most-precise form?** "result is truthy" is weaker than "result equals 42". Loose assertions catch wrong things and miss right things.
- **Would this assertion still pass if the code was subtly wrong?** Mentally introduce a one-character bug — does the assertion catch it? If not, the assertion is too weak.
- **Are you asserting on the right field?** A common failure: asserting `response.status` when the meaningful field is `response.body.error`.
- **For computed values: did you compute the expected value correctly?** Don't trust your own arithmetic — verify by hand or another path.

When in doubt about what to assert, **STOP and ask the user** rather than guess. An asserted-on-the-wrong-thing test is worse than no test — it provides false confidence.

## Hard Rules

- **Vertical slices only.** Never write all tests first.
- **Test behavior, not internals.** If a rename breaks a test but behavior didn't change, the test was wrong.
- **Watch the test fail.** If you didn't see RED, you don't know it tests the right thing.
- **Never auto-commit.** TDD cycle is RED-GREEN-REFACTOR, not RED-GREEN-REFACTOR-COMMIT.
- **Default to real services for integration tests.** Mocked databases routinely diverge from production behavior — prefer a test DB unless your project documents a specific exception.

## Hand-offs

- Tests + impl complete for the task → return to `evanflow-executing-plans` to mark task done
- Discovered the interface is wrong → `evanflow-design-interface` to redesign
- Discovered deeper architectural issue → `evanflow-improve-architecture`
