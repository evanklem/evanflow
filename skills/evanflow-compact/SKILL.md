---
name: evanflow-compact
description: Manage long-session context to prevent drift and degradation. Strategies for proactive summarization, branch isolation, and /clear decisions. Invoke when context feels heavy, when accuracy starts slipping, or proactively after a major phase boundary. Addresses the #1 cause of agent failure (context drift, ~65% of enterprise AI failures per 2025 industry research).
---

# EvanFlow: Compact


**Why this exists:** Context drift kills agents before context limits do. Industry research found ~65% of enterprise AI failures in 2025 traced to context drift or memory loss in multi-step reasoning, NOT raw token exhaustion. The agent's ability to reason degrades as context fills with stale, redundant, or contradictory information — long before the hard token limit.

## Vocabulary

See `evanflow` meta-skill. Specific to this skill:

- **Drift** — agent reasoning degrades as context fills with stale/contradictory/low-signal content. Manifests as: slower responses, more clarifying questions about already-established facts, forgetting recent decisions, inconsistent application of rules.
- **Anchor** — a high-signal artifact (CONTEXT.md, ADR, current plan, current diff) that survives compaction.
- **Compaction** — replacing a long stretch of conversation with a shorter summary that preserves the anchors plus key decisions.
- **Branch isolation** — moving a side-quest into a separate session so the main session stays focused.

## When to Use

Trigger this skill when ANY of these are true:

- A major phase boundary just completed (e.g., Phase A done, about to start Phase B). **Proactive compaction** at clean boundaries is much higher quality than reactive compaction mid-flow.
- The session has accumulated 30+ turns of dense back-and-forth.
- You notice **drift symptoms**: agent re-asking already-answered questions, contradicting earlier decisions, restating context the user already established, slower or vaguer responses.
- Context display warns of high utilization (rough threshold: ~70%+).
- About to fork into an unrelated side-quest that could be its own session.

**SKIP when:** the session is short, focused, and progressing without drift symptoms. Compaction has cost (loses fidelity); only invoke when the cost of NOT compacting is higher.

## The Strategies (pick one based on situation)

### Strategy 1 — Proactive Summarize-and-Continue (preferred at clean boundaries)

When a major phase just finished cleanly:

1. Identify anchors: what files, decisions, and open questions must survive? List them explicitly.
2. Author a compaction summary in the conversation as a markdown block titled `## Phase Summary (compaction anchor)`. Include:
   - What was decided
   - What was built (file list + one-line each)
   - What's verified
   - What's deferred / open for next phase
   - Pointers to the persistent artifacts (memory files, CONTEXT.md sections, ADRs, plan file)
3. Tell the user: "I'm at a clean boundary. Want me to compact context here? You can `/clear` and re-orient from this summary + the saved memory."
4. If user says yes → they `/clear`, then start the next phase fresh with the summary in front of them.

### Strategy 2 — Save Anchors to Memory, Then `/clear`

When the session is heavy and the next move is unclear:

1. Audit what's been learned that ISN'T already in memory or files. Anything important?
2. Save those things to memory (`~/.claude/projects/<project>/memory/*.md`) as appropriate types (user / feedback / project / reference).
3. Save any in-progress thinking to a plan file or a scratch doc.
4. Tell the user: "Important state is now persisted in memory + `<files>`. Recommend `/clear` and re-engage fresh."

### Strategy 3 — Branch Isolation

When a side-quest emerges that's unrelated to the main thread:

1. Don't pull it into this session. Tell the user: "This is a separate concern from `<main thread>`. Recommend handling it in a fresh session — your context will stay clean and the side-quest gets full attention."
2. If the user wants to do it now anyway, save the main-thread state per Strategy 2 first, then proceed.

### Strategy 4 — Reactive Mid-Flow Summarization

When drift symptoms appear and you can't reach a clean boundary:

1. Stop the current task.
2. Audit what's been established that's still relevant. Discard the rest mentally.
3. Author an explicit "current state" block in the conversation summarizing only the live concerns.
4. Continue from there, referencing the new summary as the truth.

This is less effective than proactive compaction — use only when needed.

## Drift Symptoms Checklist

Watch for these. Each is a signal to consider compaction:

- [ ] Agent re-asks a question the user already answered
- [ ] Agent restates the user's instructions back ("just to confirm, you want X" when X has been confirmed multiple times)
- [ ] Agent contradicts its own earlier decision without acknowledging the change
- [ ] Agent forgets a constraint that was set in the same session (e.g., "don't auto-commit" being violated)
- [ ] Agent's responses become noticeably slower or vaguer
- [ ] Agent struggles to find files it referenced minutes ago
- [ ] Tool calls become less efficient (more reads of the same file, more redundant checks)

If 2+ symptoms in the last few turns, invoke this skill.

## Hard Rules

- **Never compact without an explicit checkpoint.** Always write down what's being preserved before any `/clear` or summary swap. Lost context that was assumed-saved is the worst failure mode.
- **Anchors first, then compaction.** Save to memory / files BEFORE asking the user to `/clear`.
- **User initiates `/clear`.** Like commits, this is a user-controlled action. The skill recommends; the user does.
- **Compaction is lossy by design.** Be explicit with the user about what's being summarized away. They might catch something you'd drop that they want kept.
- **Never auto-commit, never auto-stage.** Same rule as everywhere else.

## Hand-offs

- After Strategy 1 or 2, before `/clear` → the user runs `/clear`, then re-engages from the saved anchor + memory
- Drift symptoms persist after compaction → there may be a deeper architectural issue with how state is being managed; consider `evanflow-improve-architecture`
- A new feature/change is about to start with fresh context → resume `evanflow-brainstorming` or `evanflow-writing-plans` as appropriate
