---
name: sdd-implement
description: Begin implementing an active feature. Creates a git branch (or worktree), bumps state to implementing, surfaces unchecked acceptance criteria, and suggests the smallest end-to-end slice to code first. Use right after sdd-new, or to re-enter implementation after a break. Trigger phrases - "start implementing", "begin coding feature X", "/sdd-implement", "let's code".
---

# sdd-implement

Hand off cleanly from spec to code.

## Inputs

- **Feature name** — if not provided, read from `.specs/CURRENT`. If still empty, ask user.
- **Mode** — `branch` (default) or `worktree`. User can pass `--worktree` to opt in.

## Process

1. **Find the feature:**
   - If user named one, use it.
   - Otherwise read `.specs/CURRENT`.
   - If still empty, ask user which feature.

2. **Read all spec files** in `.specs/<feature>/`. They are your context for the implementation phase. Don't skip this — re-reading the spec at the start of coding is the point.

3. **Pre-flight checks:**
   - Repo has no uncommitted changes (warn user if it does, ask before proceeding).
   - Spec has at least one acceptance criterion. If it doesn't, suggest running `sdd-revise` first to add some.

4. **Set up git context:**

   - **Branch mode (default):**
     - Detect base branch: try `main`, fall back to `master`, fall back to `git symbolic-ref refs/remotes/origin/HEAD`.
     - If branch `feat/<feature>` already exists:
       - If it's currently checked out: skip with a one-line note.
       - Otherwise: warn — ask user whether to checkout existing or pick a different name.
     - Otherwise: `git checkout -b feat/<feature> <base-branch>`.

   - **Worktree mode** (`--worktree`):
     - Detect repo root: `git rev-parse --show-toplevel`.
     - Compute worktree path: `<repo-parent>/<repo-name>-<feature>/`.
     - If path exists, warn — never overwrite.
     - `git worktree add <path> -b feat/<feature>`.
     - Tell the user the new path; remind them to `cd` there before continuing.

5. **Bump frontmatter state to `implementing`** in every `.md` file in `.specs/<feature>/`.

6. **Surface acceptance criteria:**
   - Parse `## Acceptance` (small/bug) or `## Acceptance criteria` (medium/large).
   - List **unchecked** items `- [ ]`.
   - Flag uncertain items (`[?]`) — ask the user to confirm or revise before they become coding targets.

7. **Suggest a tracer bullet:**
   - Pick the smallest acceptance criterion that exercises the change end-to-end (input → output).
   - Suggest 2–3 files where the implementation starts. Use the spec's `## Sketch` (small) or `## Components` (medium/large) section as a hint.
   - Explain in one line *why* it's the right tracer — usually "smallest slice that proves the wiring."

8. **Hand off:**
   - Confirm git context (branch name, or worktree path).
   - Display the tracer-bullet pick.
   - Return control. The agent's normal coding mode takes over from here. **Do not write production code in this skill** — only set up the runway.

## Output format (branch mode)

```
✓ feat/add-search created (from main)
✓ state → implementing

unchecked acceptance criteria:
  - [ ] Search input above the notes list, focused by `/` keystroke
  - [ ] Results filter on each keystroke (debounced 100ms)
  - [ ] Empty query restores the full list
  - [?] Matches highlighted in the rendered list   ← uncertain, confirm before coding

tracer bullet:
  pick: "Search input above the notes list, focused by `/` keystroke"
  files: components/notes/SearchBar.tsx, pages/notes/index.tsx
  why: smallest end-to-end slice — input + key handler only, no filtering yet

ready to code. write the tracer bullet first, then iterate.
```

## Output format (worktree mode)

```
✓ worktree: ../my-app-add-search/
✓ branch: feat/add-search
✓ state → implementing

cd ../my-app-add-search/ before continuing.

(unchecked acceptance + tracer bullet as above)
```

## Constraints

- Do not write production code. This skill only sets up context.
- Do not switch branches if uncommitted changes exist — warn first.
- Do not overwrite an existing worktree path.
- If state is already `implementing` and the branch/worktree exists, skip setup with a one-line note. Don't re-do work.
- If the spec has zero acceptance criteria, suggest `sdd-revise` to add some before continuing.

## When to use

✅ Use:
- Right after `sdd-new`, when the spec is ready and you want to start coding
- After a long break, to re-establish full context (re-reads spec, surfaces remaining work)
- After `sdd-revise` if the revision was substantial enough to warrant re-entering

❌ Don't use:
- For trivial in-place edits that don't warrant a feature branch
- When you're already deep in implementation and just need to record a decision — use `sdd-revise`
