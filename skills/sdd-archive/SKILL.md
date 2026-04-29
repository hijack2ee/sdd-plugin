---
name: sdd-archive
description: Move a shipped feature spec to the dated archive after PR merge. Optionally write a one-line retro. Trigger phrases - "archive feature", "/sdd-archive", "PR merged".
---

# sdd-archive

Cleanup step after merge. Moves the spec out of the active dir into a dated archive folder.

## Process

1. **Find the feature:**
   - If user names one, use that.
   - Otherwise read `.specs/CURRENT`.

2. **Check state.** Read frontmatter `state:`.
   - If `shipped`: proceed.
   - Otherwise: warn user (state is X), ask before archiving.

3. **Compute archive path:**
   - `.specs/archive/<YYYY-MM>/`
   - Use the current month, not the spec's `created` month.

4. **Move directory:**
   - `.specs/<feature>/` → `.specs/archive/<YYYY-MM>/<feature>/`
   - Use `git mv` if the repo is a git repo (preserves history). Otherwise plain `mv`.

5. **Update frontmatter** of all `.md` files in the moved folder: `state: archived`.

6. **Clear `.specs/CURRENT`** if it pointed to this feature.

7. **Optional retro** (ask user, don't force):
   - "Want to add a one-line retro to the Decisions log?"
   - If yes, append to `## Decisions`: `- (retro) <one line>: <YYYY-MM-DD>`.

8. **Report**:

```
✓ archived: .specs/archive/2026-04/add-search/
✓ state → archived
✓ CURRENT cleared
```

## Constraints

- Never archive a feature still in `draft`, `designing`, `implementing`, or `revising` without explicit user confirmation. Those usually indicate work-in-progress.
- Use `git mv` when in a git repo so history follows the file.
- Don't rewrite past Decisions entries. Retro line is appended, not inserted.
