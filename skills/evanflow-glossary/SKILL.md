---
name: evanflow-glossary
description: Extract canonical domain terms into CONTEXT.md. Flag ambiguities (same word, different meanings) and synonyms (different words, same meaning). Re-invoking updates the file in place. Use when authoring or updating CONTEXT.md, or when a new domain term emerges in conversation.
---

# EvanFlow: Ubiquitous Language


## Vocabulary

See `evanflow` meta-skill.

## When to Use

- Authoring `CONTEXT.md` for the first time (Phase B of EvanFlow rollout)
- A new domain term emerged in conversation and should be added
- Auditing existing terminology for ambiguity (same word, multiple meanings) or synonyms (different words, same meaning)
- Before any architectural conversation that depends on shared language

## The Flow

### 1. Read Current State

- If `CONTEXT.md` exists: read it. Identify clusters and gaps.
- Read recent code in the relevant area: router file, service file, schema, page. Names in code are the *de facto* terminology.
- Read recent ADRs in `docs/adr/` for terms decided there.

### 2. Extract Terms

Walk the conversation + relevant code. Pull out:

- **Nouns** — entities and value objects in your domain
- **Verbs** — domain operations (e.g., negotiate, queue, withdraw, settle, escalate)
- **Status enums** — explicit lifecycle states (e.g., `OrderStatus`, `MessageStatus`)
- **Relationships** — cardinalities between entities (one-to-many, many-to-many)

### 3. Flag Conflicts

Two questions to ask the user for each conflict:

- **Ambiguity**: "The word `X` is used for both A and B. Which canonical meaning, and what should the other one be renamed to?"
- **Synonyms**: "The codebase uses both `User` and `Account` for the same concept. Which is canonical? The other becomes a deprecated alias."

Propose recommended answers. Don't just dump the conflicts on the user.

### 4. Write CONTEXT.md

Default location: `/CONTEXT.md` at repo root. (Mattpocock convention.)

Format:

```markdown
# <Project> Domain Language

## <Cluster Name> (e.g., "Identity & Accounts")

| Term | Definition (one sentence) | Aliases to avoid |
|---|---|---|
| **User** | Canonical noun for an authenticated account. | Account (legacy), Customer (billing-layer only) |
| **Category** | A primary classification used for matching/filtering. | Type, Tag, Vertical |

## <Next Cluster>

...

## Relationships

- **EntityA** → **EntityB**: many-to-many via a join table.
- **EntityA** → **EntityC**: one-to-many; EntityCs are managed by an automated process.
```

### 5. Re-invoke Behavior

If `CONTEXT.md` already exists:

- Read it
- Add new terms in their existing cluster (or create a new cluster)
- Update evolved definitions
- Refresh the example dialogue if present
- Don't duplicate; merge

## Hard Rules

- **One sentence per definition.** If you need a paragraph, the term is too vague — split it.
- **Domain terms only.** Skip generic programming concepts (function, class, etc.).
- **Be prescriptive.** Pick canonical synonyms; don't list every variant as equally valid.
- **Cardinality in bold.** "User has **many** Orders."
- **Never auto-commit.** Append CONTEXT.md changes to a stage; ask before commit.

## Hand-offs

- New ADR needed (decision behind a term) → write under `docs/adr/`
- Terms reveal architectural friction → `evanflow-improve-architecture`
