---
name: evanflow-review
description: Code review — both giving and receiving feedback. Verifying observed behavior over performative agreement. Use when reviewing a PR, requesting review on completed work, or processing review feedback you received.
---

# EvanFlow: Review


## Vocabulary

See `evanflow` meta-skill.

## When to Use

- Completed work, want a review pass before integration
- Reviewing someone else's PR
- Received review feedback and need to process it (especially if you disagree)

## Two Halves

### A. Requesting Review (giving work to be reviewed)

#### 1. Self-review first

Before asking anyone to look:

- Run the project's quality checks (`tsc`, `lint`, `test`)
- Re-read the diff with fresh eyes
- Check the diff matches the spec/plan — no scope creep
- Look for: leftover console.logs, commented-out code, unused imports, secrets accidentally committed
- Apply the deletion test to new modules: do they earn their existence?

#### 2. Frame the review request

State explicitly:

- **Goal**: what behavior changed
- **Approach**: why this approach (link to spec/plan)
- **Risk areas**: where you most want a critical eye
- **Verification done**: what you tested locally; what's untested
- **Open questions**: things you're unsure about

A reviewer can't help you find what you didn't flag.

### B. Receiving Review

#### 1. Read all feedback first

Don't start fixing the first comment until you've read every comment. Patterns matter — three comments on similar code might mean a structural issue, not three separate fixes.

#### 2. Embedded Grill — Challenge feedback you disagree with

For any feedback that feels wrong:

- "Is the reviewer working from a wrong assumption? What context might they be missing?"
- "Does the project's CLAUDE.md or `docs/adr/` already address this?"
- "Would the suggested change make a different test pass that currently doesn't exist?"
- "Is this a stylistic preference or a correctness issue?"

If after grilling you still disagree, **respond with reasoning, not capitulation.** Performative agreement that ships bad code is worse than respectful disagreement.

#### 3. Group changes

Batch similar feedback into single edits. Don't make 17 separate one-line changes.

#### 4. Verify after each batch

Run the quality checks. Don't push a "review fixes" commit that breaks the build.

## Hard Rules

- **Verify before claiming a fix is done.** Run the test that the reviewer flagged.
- **Don't capitulate to feedback you can't justify.** If you can't articulate WHY the change is right, don't make it.
- **Don't agree-and-defer.** "Good catch, will fix later" with no follow-up is debt.
- **Never auto-commit, never auto-stage, never auto-finish.** When review fixes are done, report what was done and STOP. The user decides when to commit.

## Hand-offs

- Review accepted, changes complete → **report what was done and STOP. Await user direction.**
- Review surfaced a deeper issue → `evanflow-improve-architecture` or `evanflow-debug`
- Review surfaced wrong assumptions about intent → `evanflow-brainstorming` to realign
