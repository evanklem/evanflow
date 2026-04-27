---
name: evanflow-prd
description: Synthesize a PRD (Product Requirements Document) for a big new feature. Synthesis (not interview) — uses existing project context and explicit ADRs. Asks before gh issue create. Use when scoping a substantial new feature in PRD shape (e.g., before a sprint).
---

# EvanFlow: PRD


## Vocabulary

See `evanflow` meta-skill.

## When to Use

- Substantial new feature requiring stakeholder alignment
- Pre-sprint scoping
- A spec exists in conversation but needs structured form for the team

**SKIP when:** the work is small enough for `evanflow-brainstorming` → `evanflow-writing-plans` directly.

## The Flow

### 1. Read Context (don't interview)

The skill name is "to-prd" not "interview-to-prd" for a reason. **Synthesize from what's already known**:

- `CLAUDE.md` for project conventions
- `CONTEXT.md` for domain language
- `docs/adr/` for prior architectural decisions
- Recent commits and `docs/stakeholder/*.md` for in-flight initiatives
- The conversation up to this point

Only ask the user for things you genuinely cannot derive.

### 2. Identify Major Modules

Sketch the modules to build/modify, emphasizing **deep modules** (small interface, complex internals). Apply the deletion test to each — does this module earn its existence?

### 3. Validate Architecture

Confirm with the user:

- The module list (correct, exhaustive, no gaps)
- Which components require test coverage (you can't test everything)
- Which existing patterns to follow vs. diverge from

### 4. Write the PRD

Default location: `docs/specs/YYYY-MM-DD-<feature>.md`. Use the user's preferred path if they have one.

Structure:

```markdown
# [Feature Name] PRD

## Problem

One paragraph: what's broken or missing in the current product, and who feels the pain.

## Solution

One paragraph: the shape of the answer, named in domain language.

## User stories

- As a <role>, I can <action> so that <outcome>.
- (List 5-15)

## Architecture

Module list with one-line responsibility per module. Reference existing files where relevant. No code paths.

## Testing strategy

What behaviors must be covered. Integration vs. unit. Real services vs. test doubles.

## Scope

In:
- ...

Out:
- ...

## Open questions

Things needing decision before the plan can be written.
```

### 5. Optional: Create GitHub Issue

If the user wants the PRD as a GitHub issue, **ASK before running `gh issue create`**. Never auto-file.

## Hard Rules

- **Synthesize, don't interrogate.** Ask only for genuinely unknown things.
- **Domain language from `CONTEXT.md`.** Use canonical terms.
- **External behavior over implementation.** Testing strategy describes *what* to verify, not *how*.
- **Asks before `gh issue create`.** No auto-file.
- **Never auto-commit.** PRD doc gets staged; user confirms before commit.

## Hand-offs

- PRD approved, ready for plan → `evanflow-writing-plans`. If the PRD's module list shows 3+ independent components sharing a contract, the plan should be structured for `evanflow-coder-overseer`.
- New domain terms emerged → `evanflow-glossary` to update `CONTEXT.md`
- PRD reveals architecture concerns → `evanflow-improve-architecture` first
- PRD's interface design needs more thought → `evanflow-design-interface` before plan
