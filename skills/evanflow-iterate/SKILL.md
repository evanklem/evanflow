---
name: evanflow-iterate
description: Iterative self-review loop after implementing a plan. Re-read changed code with fresh eyes, fix issues found, re-run quality checks, repeat until clean. For UI work, includes visual verification (view the rendered page). Use after evanflow-executing-plans completes; on success, report and stop — the user decides what's next.
---

# EvanFlow: Iterate


## Vocabulary

See `evanflow` meta-skill. Key terms: **deep modules**, **deletion test**, **vertical slice**.

## When to Use

- After `evanflow-executing-plans` finishes all tasks
- After any non-trivial implementation
- When asked to "polish this" / "review this" / "make sure it's clean"

**SKIP when:** the change is one line or trivially correct.

## The Loop

Repeat until **stopping condition** met:

### 1. Run All Quality Checks

Run the project's quality checks — exact commands are project-specific (see CLAUDE.md or the project's README). Typical examples across stacks:

```bash
# typecheck — one of:
tsc --noEmit          # TypeScript
pnpm typecheck        # if scripted
cargo check           # Rust
go vet ./...          # Go

# lint — one of:
pnpm lint
eslint .
cargo clippy
ruff check .

# test — one of:
pnpm test
pytest
cargo test
go test ./...
```

If any check fails: fix and restart the loop. Don't proceed to step 2 with broken checks.

### 2. Re-Read the Diff With Fresh Eyes

```bash
git diff             # working-tree changes
git diff HEAD~N..HEAD  # if reviewing a series of past commits
```

For each changed file, look critically for:

- **Dead code** — leftover console.logs, commented-out blocks, unused imports/vars
- **Naming** — does the name match what the code does? (Ubiquitous language matters; see `evanflow-glossary`.)
- **Deletion test** — does each new module earn its existence? Could removing it improve the code?
- **Magic strings/numbers** — should be enums or constants per CLAUDE.md
- **Error handling** — boundary inputs validated? External calls wrapped? Loading/error/empty states in UI?
- **Type safety** — any `any`, `as`, `@ts-ignore`? Justified?
- **Security** — `authenticatedProcedure` where needed? Resource ownership re-derived from `ctx.user`? Per CLAUDE.md.
- **Test coverage** — does the new behavior have a test? Does the test verify behavior, not internals?
- **Test assertion correctness** — research shows 62% of LLM-generated assertions are wrong. For each assertion, would a one-character bug in the implementation still let it pass? If yes, the assertion is too weak.
- **Scope creep** — anything in the diff that wasn't in the plan?
- **Comments** — only WHY notes that explain non-obvious constraints. Delete WHAT comments.

Fix what you find. Then restart from step 1.

### 2.5. Five Failure Modes Check

Industry research identifies five predictable failure modes in agentic coding. After step 2's diff review, do an explicit pass against each:

- **(a) Hallucinated actions** — did the implementation invent file paths, env vars, IDs, function names, library APIs, or other external values that aren't authoritatively confirmed? (Example: a `process.env.STRIPE_SECRET_KEY` reference when the actual var name is `STRIPE_SK`.)
- **(b) Scope creep** — does the diff touch files or behaviors not in the plan? Bundled refactors or stylistic changes that should be separate PRs?
- **(c) Cascading errors** — was a failure suppressed/caught/wrapped in a way that hides root cause from callers? Are there silent fallbacks that mask bugs (try/catch returning empty arrays, default values that paper over missing data)?
- **(d) Context loss** — does the diff contradict earlier decisions in the session, the plan, CLAUDE.md, or `CONTEXT.md`? Names, conventions, invariants?
- **(e) Tool misuse** — used the wrong tool (e.g., Bash for file reads, MCP server when CLI was simpler), or used a tool with wrong parameters (e.g., grep without proper escaping, Edit without reading first)?

For each mode flagged, fix and restart from step 1.

### 3. (UI work only) Visual Verification

If the diff touches frontend page or component files and the change has visible output:

**Default approach (no Playwright needed):**

```bash
# Make sure your dev server is running first (e.g., pnpm dev, npm run dev, etc.)
chromium --headless --no-sandbox \
  --screenshot=/tmp/iter-$(date +%s).png \
  --window-size=1440,900 \
  http://localhost:<port>/<route>
```

(If your project doesn't have `chromium`, substitute `google-chrome --headless` or `chrome --headless` with the same flags.)

Then read the screenshot:

```
Read /tmp/iter-*.png
```

Check against:
- Any brainstorm mockup or design comp the project maintains
- The project's design system (colors, spacing, typography, component patterns documented in CLAUDE.md)
- Responsive behavior — also screenshot at `--window-size=390,844` (mobile)

**If you need interaction** (click, fill, observe modal): use Playwright MCP. If MCP fails with "chrome not found", configure it to use your installed Chromium binary by adding `"--executable-path", "/path/to/chromium"` to args in the Playwright `.mcp.json`. Don't fight the MCP — fix it once, then use it.

### 4. Stopping Condition

Stop the loop when **all** are true:

- All quality checks pass
- Re-read the diff and find no new issues you'd want to fix
- (UI) Screenshot matches expectation, OR you've confirmed with the user

**Hard cap: 5 iterations.** If you're still finding issues at iteration 5, the original plan was wrong — stop and ask the user. Don't iterate forever.

## Hard Rules

- **Don't iterate just to iterate.** If everything is clean on the first pass, stop. Don't invent issues.
- **Fix root causes, not symptoms.** A linter warning that you suppress instead of fix is debt.
- **Never auto-commit, never auto-stage, never auto-finish.** Iteration produces a clean working tree. After convergence, **report what was done and stop**. The user decides whether to commit, refactor further, or change direction.
- **Never iterate past the user.** If the user says "good enough," stop. Their judgment beats the loop.
- **Visual verification requires a running dev server.** If the dev server isn't up, ask the user to start it (don't try to start it yourself unless the project has a documented "start dev" skill).

## Hand-offs

- Loop converged, all clean → **report what was done and STOP. Await user direction.** No auto-finish, no staging, no commit.
- Loop hit cap with issues remaining → back to `evanflow-writing-plans` (plan was wrong)
- Found architectural issues → `evanflow-improve-architecture`
- Found a bug → `evanflow-debug`
