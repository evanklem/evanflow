---
name: evanflow-qa
description: Conversational bug discovery → issue draft. Light listening, background exploration, scope assessment. Asks before gh issue create — never auto-files. Use when conducting a QA session, triaging user-reported issues, or filing bugs.
---

# EvanFlow: QA


**Removed from upstream:** automatic `gh issue create`. Always ask first.

## Vocabulary

See `evanflow` meta-skill.

## When to Use

- User describes a bug in their own words
- QA session walking through a feature
- Triaging multiple reports

## The Flow

### 1. Listen Lightly

Let the user describe in their own words. **At most 2-3 short clarifying questions**, focused on:

- What did you expect to happen?
- What actually happened?
- What were the steps?

Don't pre-debug. Don't pre-judge.

### 2. Explore in Background (optional)

Spin up an Agent (Explore type) to read the relevant codebase area. Goal: understand domain language and feature intent — **not to find a fix**. Fixes come later via `evanflow-debug`.

### 3. Assess Scope

Decide: is this one issue, or does it need breakdown into multiple independent concerns that different contributors could tackle simultaneously?

If multiple: each becomes its own issue. Mark blocking relationships honestly (don't serialize when work could parallelize).

### 4. Draft the Issue(s)

**Show the draft to the user. ASK before running `gh issue create`.**

Single-issue template:

```markdown
## What happened
<one-paragraph user-facing description, no file paths>

## What I expected
<one-paragraph>

## Steps to reproduce
1. ...
2. ...

## Additional context
<anything that helps an engineer reproduce or scope>
```

Breakdown template (parent + children):

```markdown
## Parent issue
References: #<parent-id>

## What's wrong
<scoped to this child>

## What I expected
...

## Steps to reproduce
...

## Blocked by
- #<id> (if any)

## Additional context
...
```

### 5. File (with permission)

After user confirms each draft: `gh issue create --title "..." --body "$(cat <<'EOF' ... EOF)"`.

Do NOT batch-file. Confirm each one.

### 6. Iterate

Process each issue independently. The user signals when the QA session is done.

## Hard Rules

- **No file paths or line numbers in issue bodies.** They become stale.
- **Use the project's domain language** (`CONTEXT.md`).
- **Describe behaviors, not code mechanics.**
- **Reproduction steps mandatory.**
- **Concise — readable in 30 seconds.**
- **Many thin issues > few thick issues.**
- **Mark blocking honestly to maximize parallelism.**
- **ALWAYS ask before `gh issue create`.** Never auto-file.
- **Never auto-commit.** This skill doesn't modify code anyway, but if it ever does — ask first.

## Hand-offs

- Issue filed, want to debug it now → `evanflow-debug`
- Issue reveals a feature gap, not a bug → `evanflow-brainstorming` (or `evanflow-prd` if substantial)
