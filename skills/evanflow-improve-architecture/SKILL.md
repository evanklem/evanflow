---
name: evanflow-improve-architecture
description: Identify refactoring opportunities by surfacing architectural friction. Apply the deletion test, deep-modules vocabulary, and seams analysis. Each opportunity becomes its own evanflow-writing-plans cycle. Use when reviewing code for refactoring, when a file has grown too large, or when architecture concerns surface during feature work.
---

# EvanFlow: Improve Architecture


## Vocabulary

See `evanflow` meta-skill. Key terms: **module**, **interface**, **depth**, **seam**, **adapter**, **deletion test**.

## When to Use

- "This file is too big" / "this is hard to follow"
- A feature plan reveals friction the existing structure can't accommodate cleanly
- Periodic architectural review (Phase D of EvanFlow rollout)
- After tests reveal a module has the wrong shape

**SKIP when:** the user is doing a small, well-scoped change. Don't try to refactor adjacent code.

## The Flow

### 1. Read Context First

- `CONTEXT.md` (if it exists) — for canonical domain language
- `docs/adr/` — for prior architectural decisions you must respect
- The target file(s) and their direct callers

### 2. Identify Candidates

Walk the codebase noting friction:

- A concept that bounces across many modules to be understood
- An interface that rivals its implementation in complexity
- Files that have grown unwieldy (>400 lines is a smell, >800 is a klaxon)
- Conditional logic that branches by concept (suggests two adapters in a missing seam)

### 3. Apply the Deletion Test

For each candidate module: "If I deleted this, where would the complexity go?"

- **Vanishes** → the module is bloat; delete it
- **Concentrates across N callers** → the module earns its existence; preserve and possibly deepen it
- **Moves to one place** → the module is a thin pass-through; consider folding it

### 4. Embedded Grill — Candidate Selection

Before proposing changes, stress-test:

- "Which candidate has the highest leverage (improves most caller code)?"
- "Which candidate is safest to change (smallest blast radius)?"
- "Are there ADRs that constrain the design we're considering?"
- "Does the proposed deepening match domain language in `CONTEXT.md`, or are we inventing new terms?"
- "If we change this seam, will it require touching tests that currently bypass the interface? (If yes, the test design is also wrong.)"

### 5. Present Opportunities

For each, name:

- **File(s)** affected
- **Current shape** (what's wrong)
- **Proposed shape** (small interface, complex internals)
- **Benefits** (in domain language from `CONTEXT.md`)
- **Cost** (estimated PRs, blast radius)

Prioritize. Recommend ONE to tackle next.

### 6. Hand Off Per Opportunity

**Each opportunity becomes its own `evanflow-writing-plans` cycle.** Do not bundle multiple refactors into one plan — that's a horizontal-slice failure.

If the opportunity changes a public interface, route through `evanflow-design-interface` first.

## Hard Rules

- **Read `CONTEXT.md` and `docs/adr/` before proposing changes.** Domain language and prior decisions must inform the design.
- **Deletion test first.** Don't add abstractions just because they feel cleaner.
- **One refactor per plan.** Bundling refactors hides their individual value and inflates risk.
- **Two adapters before a seam.** Don't introduce variation points hypothetically — wait until two real implementations exist.
- **Never auto-commit.** Refactor PRs are easy to slip past review when batched; keep them small and explicit.

## Hand-offs

- Opportunity selected → `evanflow-design-interface` (if interface changes) or `evanflow-writing-plans` (otherwise)
- New domain term emerged during discussion → `evanflow-glossary` to update `CONTEXT.md`
- Decision behind the design merits an ADR → write under `docs/adr/`
