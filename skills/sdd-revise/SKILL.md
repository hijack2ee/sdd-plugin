---
name: sdd-revise
description: Update an active spec mid-implementation when code reveals a gap. Use when an acceptance criterion turns out wrong, scope changes, or a non-obvious decision needs recording. Trigger phrases - "revise the spec", "update the spec", "/sdd-revise", "spec gap".
---

# sdd-revise

Keep spec and reality aligned. Use when you learn something during implementation.

## When to use this skill

✅ Use when:
- An acceptance criterion turned out wrong, ambiguous, or unreachable
- A non-obvious decision was made (alternative rejected, constraint discovered)
- Scope changed (in-scope or out-of-scope)
- A new risk or dependency surfaced

❌ Don't use for:
- Pure refactors (rename, extract function) that don't change behavior
- Trivially mechanical changes
- Routine progress (use `sdd-ship` when done)

## Process

1. **Find the feature:**
   - If user names one, use that.
   - Otherwise read `.specs/CURRENT`. If empty, ask user which feature.

2. **Read all `.md` files** in `.specs/<feature>/`.

3. **Set state to `revising`** in frontmatter of each spec file.

4. **Apply the update** based on type of change:

   | Change type | Where it goes |
   |---|---|
   | New decision (rejected alt, discovered constraint) | Append to `## Decisions` log with date |
   | Acceptance criterion changed | Edit the bullet. Strike through `~~old~~` if the change is non-trivial |
   | Acceptance criterion completed | Check the box `[x]` |
   | Scope change | Update `## Scope` (medium/large) |
   | New risk | Append to `## Risks` (medium/large) |
   | Approach change | Update `## Approach` and add a Decision entry |

5. **Decisions log format** (append-only, dated):
   ```
   ## Decisions
   - <one-line decision> (YYYY-MM-DD)
   ```
   Don't rewrite history. Always append.

6. **After the update**, set state back to `implementing` (or to `shipped` if implementation is already done and this revise is just to record decisions).

7. **Report**:
   - What changed (one line per edit)
   - Updated state

## Output format

```
✓ .specs/add-search/SPEC.md
  - acceptance: marked criterion 2 as [x]
  - decisions: appended fuse.js choice
  state: implementing

review the diff and continue coding.
```

## Constraints

- Decisions log is append-only. Never delete or rewrite past entries.
- Don't add boilerplate ("we decided to..."). Each decision line should stand alone, dated.
- If the change is large enough that the spec is mostly wrong, suggest the user create a new spec (`sdd-new`) and archive this one — don't pretend a heavily-revised spec is the same feature.
