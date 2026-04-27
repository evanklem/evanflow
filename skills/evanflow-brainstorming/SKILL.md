---
name: evanflow-brainstorming
description: Clarify intent, propose 2-3 approaches, embedded grill to stress-test the chosen path. Use before any creative work — new features, components, behavior changes, design questions. Mockup-only requests use mockup quick-mode (no spec/plan ceremony).
---

# EvanFlow: Brainstorming



## Vocabulary

See `evanflow` meta-skill. Key terms used here: **deep modules**, **deletion test**, **mockup quick-mode**, **grill**.

## When to Use

- "Help me think through X"
- "I want to build Y"
- New feature scoping
- Design questions where intent is unclear
- Before any creative work that will produce code

**SKIP this skill when:** the user is asking a factual question, requesting a quick mockup, or doing exploratory reading. EvanFlow has no skill tax — answer directly.

## Mockup Quick-Mode

If the user says "show me mockups", "give me visual options", "let's see designs", or anything similar **and is NOT asking to implement** — skip everything below. Produce mockups directly in whatever form the project uses:

- HTML files (often easiest — write self-contained pages and tell the user where to open them, e.g., `open mockup-1.html` or via a local HTTP server)
- Figma frames (if the project uses Figma)
- ASCII layouts (for terminal UIs)
- Whatever the project's CLAUDE.md documents as the design-iteration medium

No spec doc. No plan. No git operations. Just iterate visually until the user picks a direction.

## The Flow

1. **Quick context check.** Skim relevant files, recent commits, and any referenced docs. Do NOT exhaustively explore — just enough to ground the conversation.
2. **Scope check.** If the request describes multiple independent subsystems, flag it and propose decomposition before going further. Don't refine details on something that needs to be split.
3. **Ask clarifying questions one at a time.** Multiple-choice when possible (use AskUserQuestion). Focus on purpose, constraints, success criteria.
4. **Propose 2–3 approaches** with trade-offs and your recommendation as option (a). Lead with "here's what I'd do and why."
5. **Embedded Grill** (see below) — stress-test the chosen approach before committing.
6. **Present the design** in sections sized to their complexity. Get explicit approval after each section.
7. **Decide**: spec doc, straight to plan, or just go.

## Embedded Grill

Once an approach is chosen, ask 3–5 sharp questions targeting:

- **Hidden constraints**: "What breaks if a user does X?"
- **Reversibility**: "If we ship this and it's wrong, what's the rollback?"
- **Boundaries**: "What's explicitly NOT in scope?"
- **Existing patterns**: "Is there code in the project that already does something similar? Should this conform or diverge?"
- **Domain language**: "Are we using the right terms from `CONTEXT.md`?"

For each question, propose a recommended answer. The user accepts, refines, or rejects. Don't grill on every single design — only when the choice has irreversibility, security, or domain-modeling implications.

## Hard Rules

- **Never auto-commit.** Confirm in the current turn before any git op.
- **No forced spec path.** If a spec doc is appropriate, ask the user where to put it. Default suggestion: `docs/specs/YYYY-MM-DD-<topic>.md`. Don't write to any vendor-specific path unless user requests.
- **No forced visual companion offer.** Skip the browser-companion offer entirely; mockup quick-mode handles visual work directly.
- **No skill tax.** If the user is just chatting or asking a factual question, exit this skill — don't force the flow.

## Hand-offs

- Spec written → `evanflow-writing-plans` (if non-trivial)
- **Substantial new feature** (sprint-sized, multi-stakeholder) → `evanflow-prd` instead of writing-plans
- Plan exists → `evanflow-executing-plans` (which itself offers `evanflow-coder-overseer` if the plan has 3+ parallelizable units)
- Just go → start with `evanflow-tdd` for the first behavior
- Domain term emerged → `evanflow-glossary` to update `CONTEXT.md`
- Interface shape is the hard part of the design → `evanflow-design-interface` before writing-plans
