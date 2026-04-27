---
name: evanflow-go
description: Single entry-point orchestrator for the entire EvanFlow loop. The user says "let's evanflow this", "use evanflow", "evanflow this idea", "run this through evanflow", "implement with evanflow", or any similar phrasing — and you walk the full loop (brainstorm → plan → execute → tdd → iterate → STOP) end-to-end, announcing each step, respecting checkpoints, and stopping where the user retains control. Trigger keywords: "evanflow", "let's evanflow", "use evanflow", "evanflow this".
---

# EvanFlow: Go (Entry-Point Orchestrator)

Single entry point for the EvanFlow workflow. The user gives you an idea or task and asks to "evanflow it" — you take responsibility for walking the whole loop end-to-end, picking the right sub-skill at each step, and respecting checkpoints where the user must stay in control.

You are the conductor; the other `evanflow-*` skills are the orchestra.

## Vocabulary

See `evanflow` meta-skill for the shared vocabulary (deep modules, deletion test, vertical slice, grill, mockup quick-mode).

## When to Use

Trigger phrases (or anything semantically equivalent):
- "let's evanflow this"
- "use evanflow"
- "evanflow this idea"
- "run this through evanflow"
- "implement with evanflow"
- "let's [do X] using evanflow"

**SKIP when:**
- The user is asking a factual question (no skill needed at all)
- The user wants quick mockups only (the brainstorming skill's mockup quick-mode handles this directly — no full loop needed)
- The user explicitly invoked a specific sub-skill by name (`evanflow-debug`, etc.) — let them control granularly
- The work is a one-line fix or trivial change — full loop is overkill

## The Walk

### Phase 0 — Restate and Confirm Scope (one sentence)

Confirm you've understood the idea in your own words, in one sentence. Examples:
> "Got it — you want to add an `archived` flag to messages so cancelled ones drop off the dashboard."

Then ask one calibration question if scope isn't obvious:
> "Quick scope check: is this a small targeted change or a feature with multiple components?"

If the user signals quick/small → consider whether a full evanflow loop is overkill. Offer a shortcut: "This sounds small — want me to skip brainstorming/planning and just TDD it directly? Or run the full loop anyway?"

### Phase 1 — Brainstorm (always, unless user opts out)

**Announce:** "Step 1: brainstorming via `evanflow-brainstorming`."

Invoke `evanflow-brainstorming`:
- Quick context check (skim relevant files; don't exhaustively explore)
- Scope check (decompose if multi-subsystem)
- Clarifying questions one at a time, multiple-choice when possible
- Propose 2–3 approaches with your recommendation as option (a)
- Embedded grill on the chosen approach
- Present the design in sections; get explicit approval

**Mockup quick-mode bypass:** if the user originally said "show me mockups" rather than "implement," skip the full loop and produce mockups directly (HTML files, Figma frames, ASCII layouts — whatever the project uses). No spec, no plan, no TDD ceremony.

**Checkpoint:** before continuing, the user must explicitly approve the design. Not a tacit yes — actual confirmation.

### Phase 2 — Plan (if non-trivial)

**Announce:** "Step 2: writing the plan via `evanflow-writing-plans`."

If scope is small (one file, one behavior change), skip to Phase 3 with a verbal plan ("I'll write a failing test for X, then minimal impl"). Otherwise:

Invoke `evanflow-writing-plans`:
- File structure first (name files + responsibilities, deletion test on each)
- Embedded grill on the structure
- Bite-sized tasks
- **Step 2.5: parallelization check.** If the plan has 3+ independent units sharing a contract, offer `evanflow-coder-overseer` to the user as the execution path instead of sequential `executing-plans`. Lay out signals on both sides. User picks.

If the user picks coder-overseer, structure the plan with a per-coder section + cohesion contract upfront.

**Checkpoint:** before continuing, the user must approve the plan.

### Phase 3 — Execute (sequential or parallel)

**Announce based on user's pick:**
- Sequential: "Step 3: executing the plan via `evanflow-executing-plans`."
- Parallel: "Step 3: executing in parallel via `evanflow-coder-overseer`."

**Sequential path** — invoke `evanflow-executing-plans`:
- Step 0: parallelization re-check (one more chance to switch paths)
- Critical review of plan
- Set up TaskCreate items
- Task-by-task; each task uses `evanflow-tdd` for any production code
- Inline verification (typecheck, lint, test for affected workspaces)
- Stop and ask on blockers

**Parallel path** — invoke `evanflow-coder-overseer`:
- Author cohesion contract (with named tests + integration tests at touchpoints)
- Decompose into coder tasks (max 5)
- Phase A: spawn coders for RED checkpoint (failing tests only)
- Verify all REDs are clean
- Phase B: spawn coders for vertical-slice GREEN
- Spawn per-coder overseers (use `subagent_type: evanflow-overseer` if available)
- Spawn integration overseer (runs touchpoint tests)
- Reconcile findings (max 3 rounds)

**Inside both paths**, all production code goes through `evanflow-tdd`: vertical-slice, behavior through public interface, watch each test fail before writing impl, assertion correctness check.

### Phase 4 — Iterate (always, on success)

**Announce:** "Step 4: self-review loop via `evanflow-iterate`."

Invoke `evanflow-iterate`:
- Run the project's quality checks (typecheck, lint, test — exact commands per CLAUDE.md)
- Re-read the diff (dead code, naming, deletion test, magic strings, error handling, type safety, security, test coverage, assertion correctness, scope creep, comments)
- Five Failure Modes pass (hallucinated actions, scope creep, cascading errors, context loss, tool misuse)
- For UI changes: chromium screenshot via `chromium --headless --screenshot=...`, then read the PNG
- Fix what's found, restart loop
- Hard cap of 5 iterations

### Phase 5 — STOP

**Announce:** "Implementation complete. Stopping here per EvanFlow's no-auto-finish rule."

Report:
- What was built (file list, one-line each)
- What behaviors were added/changed
- What verifications passed
- Any deferred items (with reason)
- Anything the user should review before deciding next steps

**Do NOT** stage files, commit, push, merge, or open a PR. **Wait for user direction.**

---

## Cross-Cutting: Context Compaction

Watch for drift symptoms throughout (re-asking established questions, contradicting earlier decisions, restating constraints already set). At any clean phase boundary (after design approval, after plan approval, after execution success), if the session feels heavy, **proactively offer**:

> "We just finished [phase X]. Context is getting heavy — want me to invoke `evanflow-compact` to summarize anchors and prep for `/clear` before the next phase?"

Don't force it. Let the user decide.

## Hard Rules (inherited from `evanflow` meta + this skill's specifics)

- **Never auto-commit, never auto-stage, never auto-finish.** Phase 5 is `STOP`. The user controls integration.
- **Never invent values.** File paths, env vars, IDs, function names, library APIs — if unsure, STOP and ask. Action-hallucination is the top failure mode.
- **Respect checkpoints.** After brainstorming and after planning, get explicit user approval before continuing. Not a tacit yes.
- **Announce each phase.** "Step N: [skill name] for [purpose]." This keeps the user oriented and able to interrupt cleanly.
- **Don't mix up paths.** If sequential was picked, don't switch to parallel mid-flight. If parallel, don't fall back to sequential silently. Surface the proposed switch and ask.
- **Iterate has a hard cap.** 5 iterations. If still finding issues at iteration 5, the original plan was wrong — stop and ask.

## Hand-offs

This skill IS the entry point. It hands off TO other evanflow skills, not the other way around. The only "hand-off" out of evanflow-go is **STOP** at Phase 5, returning control to the user.

Special-purpose skills can be invoked mid-flow when relevant:
- New domain term emerged → invoke `evanflow-glossary` to update `CONTEXT.md`, then continue
- Design surfaces architecture concerns → invoke `evanflow-improve-architecture` first, then resume
- Interface shape is the hard part → `evanflow-design-interface` before plan
- Bug discovered mid-execution → `evanflow-debug`
- Substantial-feature scope reveals itself → upgrade brainstorming → `evanflow-prd` → writing-plans

These don't break the flow — they're sub-tools used inside the appropriate phase.

## Why This Exists

Without an entry-point orchestrator, the user has to know which `evanflow-*` skill to invoke at each step. That defeats the cohesion property. With `evanflow-go`, the user says "evanflow this" once and the right sub-skill fires at the right time, with the right checkpoints preserved.

The skill is **conductor, not autopilot.** Checkpoints are real (brainstorm approval, plan approval, iterate hand-back). The user always has the option to interrupt, switch paths, or take manual control.
