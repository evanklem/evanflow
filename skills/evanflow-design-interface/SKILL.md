---
name: evanflow-design-interface
description: Design a module's interface using parallel sub-agents producing radically different designs ("design it twice"). Compare on depth, simplicity, and efficiency. Embedded grill on the synthesized choice. Use when designing a new API, exploring interface options, or deciding the shape of a refactor before writing code.
---

# EvanFlow: Design an Interface


Source principle: "Design It Twice" from John Ousterhout's *A Philosophy of Software Design*. Your first idea is unlikely to be the best. Generate radically different designs, compare, synthesize.

## Vocabulary

See `evanflow` meta-skill. Key terms: **interface**, **depth**, **module**, **adapter**.

## When to Use

- Designing a new API surface (tRPC router, service interface, public function set)
- Refactor changes a public interface — design before implementing
- Stuck on the shape of a module
- The team disagrees on the right interface

## The Flow

### 1. Gather Requirements

- What problem does this module solve?
- Who are the callers? (other modules, external users, tests)
- Key operations
- Constraints (performance, compatibility, existing project patterns from `CONTEXT.md`)
- What should be hidden vs. exposed

### 2. Spawn Parallel Sub-Agents (Design It Twice — actually 3+)

Dispatch 3+ Explore or general-purpose agents simultaneously (single message, multiple Agent tool calls). Each gets a **radically different** constraint:

- **Agent 1:** "Minimize method count — aim for 1–3 methods max."
- **Agent 2:** "Maximize flexibility — support many use cases."
- **Agent 3:** "Optimize for the most common case (specify what that is)."
- **(Optional) Agent 4:** "Take inspiration from <specific paradigm or library>."

Each returns:

1. Interface signature (types, methods, params)
2. Usage example (how the caller actually uses it)
3. What the design hides internally
4. Trade-offs

### 3. Present Designs Sequentially

Show each design separately so the user can absorb each before comparison. No tables yet — let each design stand on its own.

### 4. Compare

After all designs are shown, compare on:

- **Interface simplicity**: fewer methods, simpler params
- **General-purpose vs. specialized**: flexibility vs. focus
- **Implementation efficiency**: does the shape allow efficient internals or force awkward ones?
- **Depth**: small interface hiding significant complexity (good) vs. large interface with thin implementation (bad)
- **Ease of correct use** vs. **ease of misuse**

Discuss in prose. Highlight where designs diverge most.

### 5. Synthesize

Often the best design combines insights from multiple options. Ask:

- "Which design best fits the primary use case?"
- "Any elements from other designs worth incorporating?"

### 6. Embedded Grill on the Synthesis

Before committing to the design:

- "What's the simplest way a caller could misuse this?"
- "What test would force this interface to change unnecessarily? Does that test exist or would we write it?"
- "Is the interface still simple after we incorporate the borrowed elements, or did the synthesis bloat it?"
- "Apply the deletion test to internal helper modules implied by this design."

## Hard Rules

- **Don't let sub-agents converge.** Enforce radical difference. If agents return similar designs, re-spawn with sharper constraints.
- **Don't skip comparison.** The value is in the contrast.
- **Don't implement.** This skill is purely about interface shape. Implementation goes through `evanflow-writing-plans` + `evanflow-tdd`.
- **Don't evaluate based on implementation effort.** Evaluate on interface quality.
- **Never auto-commit.** Even a design doc gets staged, not committed.

## Hand-offs

- Design chosen → `evanflow-writing-plans` (the plan implements the design)
- Design reveals architecture concerns → `evanflow-improve-architecture` first
- New domain terms emerged → `evanflow-glossary` to update `CONTEXT.md`
