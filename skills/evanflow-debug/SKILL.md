---
name: evanflow-debug
description: Root-cause discipline for bugs, test failures, and unexpected behavior. Embedded grill on the hypothesis before writing fix code. Use when encountering any bug, failing test, or behavior that doesn't match expectation.
---

# EvanFlow: Debug


## Vocabulary

See `evanflow` meta-skill.

## When to Use

- Test failing
- User reports unexpected behavior
- Production error
- Code does the wrong thing under specific conditions
- Anything where the immediate symptom isn't the root cause

**SKIP when:** the cause is obvious and the fix is one line. Don't ceremonialize trivial bugs.

## The Flow

### 1. Reproduce

- Get the exact reproduction: input, environment, steps
- Reproduce locally if possible. If you can't reproduce, the bug is unverified — say so before proceeding.

### 2. Form a Hypothesis

State the hypothesis explicitly:

> "I think the bug is in <file>:<line> because when X happens, Y is supposed to happen but instead Z does."

A vague "probably the validation" is not a hypothesis.

### 3. Embedded Grill — Challenge the Hypothesis

Before writing any fix, ask:

- **Symptom vs. cause**: "Is this where the bug *manifests*, or where it *originates*? Trace one step further upstream."
- **Coverage**: "What other code paths share this root cause? Will the fix here leave those paths broken?"
- **Reversibility**: "Does the fix have the same blast radius as the bug, or wider?"
- **Test gap**: "Why didn't a test catch this? Is the test missing, wrong, or misaligned with real behavior?"
- **Domain check**: "Is the bug actually behaving correctly per spec, and the spec is wrong?"

### 4. Verify the Hypothesis Before Fixing

Add an instrument (log, breakpoint, test assertion) that proves the hypothesis right or wrong. **Watch the instrument fire.** If it doesn't, the hypothesis is wrong — go back to step 2.

### 5. Write a Failing Test First

The test should fail because the bug exists. This is a vertical-slice TDD application — see `evanflow-tdd`.

### 6. Fix at the Root

Fix where the root cause originates, not where the symptom appears. If the fix is far from the symptom, leave a comment explaining the WHY (this is one of the few cases where a code comment earns its keep).

### 7. Verify the Test Passes

Run the test. Run the broader suite. Confirm no regressions.

## Hard Rules

- **No fix without a failing test that demonstrates the bug.** (Same TDD principle as evanflow-tdd.)
- **Fix the root, not the symptom.** Symptom-fixes are how bugs metastasize.
- **Never auto-commit.** A fix gets staged; user confirms before commit.
- **If you can't reproduce, say so.** Don't fix invisible bugs.

## Hand-offs

- Fix complete, tests pass → if mid-plan, return to `evanflow-executing-plans`. If standalone debug, **report what was fixed and STOP**. The user decides whether to commit or take further action.
- Discovered an architectural issue → `evanflow-improve-architecture`
- Discovered the spec is wrong → `evanflow-brainstorming` to align on intended behavior
