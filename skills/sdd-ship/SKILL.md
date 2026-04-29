---
name: sdd-ship
description: Finalize a feature for merge. Verify spec matches what shipped, check off acceptance criteria, draft PR body, optionally open the PR. Use right before opening a PR. Trigger phrases - "ship feature", "open PR", "/sdd-ship", "ready to merge".
---

# sdd-ship

Make sure spec and code agree, then turn the spec into a PR.

## Process

1. **Find the feature:**
   - If user names one, use that.
   - Otherwise read `.specs/CURRENT`.

2. **Read all spec files** in `.specs/<feature>/`.

3. **Read the diff** against the base branch:
   ```
   git diff $(git merge-base HEAD main)...HEAD --name-only
   ```
   (Use `master` if `main` doesn't exist. Detect default branch with `git symbolic-ref refs/remotes/origin/HEAD` if needed.)

4. **Verify spec ↔ code alignment.** This is the core value of this skill — don't skip it:

   - For each acceptance criterion:
     - If it's clearly implemented in the diff, check the box `[x]`.
     - If unsure, leave unchecked and flag it to the user.
   - For each significant change in the diff:
     - Is it reflected somewhere in the spec (Components, Approach, Decisions)?
     - If not, **stop and tell the user**: the spec is out of date. Suggest running `sdd-revise` first. Don't proceed to PR.
   - Confirm `## Decisions` log captures any non-trivial choices visible in the diff.

5. **If alignment passes**, set frontmatter `state: shipped`.

6. **Draft PR body**:

   ```markdown
   ## Spec

   See `.specs/<feature>/` for the full spec.

   <Closes #<issue-num> if frontmatter has issue number>

   ## Intent

   <pull from spec ## Intent section>

   ## Acceptance

   <pull from spec ## Acceptance section, with check marks>

   ## Decisions

   <pull from spec ## Decisions section if non-empty>

   ---

   <small footer linking to spec files>
   ```

7. **Open the PR** (only if user confirms):
   - Title: feature name in title case, or first H1 of the spec
   - Body: drafted body above
   - Command: `gh pr create --title "..." --body-file -` (pipe drafted body)
   - On success, parse the PR URL for the number, update `pr:` in frontmatter.

8. **Report**:
   - Alignment check result
   - PR URL (if opened) or drafted body (if user wants to review first)

## Output format

```
✓ alignment check passed
✓ acceptance: 4/4 implemented
✓ state → shipped

PR draft ready. open now? [y/n]
```

## When alignment fails

```
✗ alignment check found gaps:
  - design.md does not mention components/notes/Highlight.tsx (in diff)
  - decisions log is empty but you switched from substring to fuzzy match

run sdd-revise first to update the spec, then re-run sdd-ship.
```

## Constraints

- Never open the PR without user confirmation.
- Never check off an acceptance criterion if you're not confident it's implemented — leave it unchecked and flag it.
- If `gh` CLI is unavailable, draft the body and tell the user to paste it into a manual PR.
