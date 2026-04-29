---
name: sdd-new
description: Create a new feature spec by interviewing the user, picking a size tier, and drafting real content into the right templates. Use whenever starting a new feature, bug fix, or refactor. Trigger phrases - "new feature", "spec a feature", "/sdd-new", "start working on X".
---

# sdd-new

Scaffold and draft a new feature spec at `.specs/<name>/`.

## Inputs (gather what's missing in ≤2 questions)

- **Feature name** — kebab-case, ≤30 chars (e.g. `add-search`, `fix-stale-cache`)
- **Intent** — 1–2 sentences on what and why
- **Size hint** — `bug` | `small` | `medium` | `large` (optional; you may infer)

If user gave one sentence with intent and a name, that's enough to start. Only ask for missing essentials. **Do not ask more than two questions** before scaffolding — the spec is a draft, the user will refine it.

## Size selection

If the user didn't specify, infer:

- **bug** — defect, regression, hot fix
- **small** — self-contained, 1–3 files, < 1 week
- **medium** — multi-file, has design choices to make
- **large** — cross-cutting, multi-week, needs explicit task breakdown

**Default one tier smaller than your gut says.** Tell the user the inferred size — they can override.

## Process

1. **Preconditions:**
   - `.specs/` exists. If not, suggest running `sdd-init` and stop.
   - `.specs/<name>/` does not exist. If it does, ask before continuing.

2. **Create folder** `.specs/<name>/`.

3. **Copy template(s)** from this skill's `templates/` directory (relative to this SKILL.md):
   - `bug` → `templates/bug.md` → `.specs/<name>/BUG.md`
   - `small` → `templates/small.md` → `.specs/<name>/SPEC.md`
   - `medium` → `medium-requirements.md` + `medium-design.md` → `requirements.md` + `design.md`
   - `large` → `large-requirements.md` + `large-design.md` + `large-tasks.md` → same names

4. **Substitute placeholders** in copied files: `<feature-name>` → name, `<date>` → today's ISO date.

5. **Draft real content** (this is what makes the skill better than a CLI):
   - Fill `## Intent` from the user's description (don't leave the placeholder text).
   - Draft 2–3 acceptance criteria as your best guess, marked `[?]` if uncertain. The user will refine.
   - For medium/large, take a first pass at `## Approach` and `## Components`.
   - Leave `## Decisions` empty (it grows during implementation).

6. **Set frontmatter:** `state: draft`, `created: <today>`.

7. **Update `.specs/CURRENT`** to point to the new feature.

8. **Optional: GitHub issue.** If `gh` CLI is available and the repo has a remote, ask the user "create a GitHub issue?" If yes:
   - Run `gh issue create --title "<name>" --body "Spec: \`.specs/<name>/\`"`
   - Parse the returned URL for the issue number.
   - Update `issue:` in frontmatter of all spec files.

9. **Report** to the user:
   - Path created and files inside
   - Inferred size (if you inferred it)
   - One-line summary of what's drafted
   - **Explicit ask**: "Review the draft and tell me what to revise."

## Output format

```
✓ .specs/add-search/ (small, draft)
  - SPEC.md

drafted:
  intent: "Users can't find old notes — add inline search"
  acceptance: 3 criteria (1 marked [?])

active feature is now: add-search

review the draft and tell me what to revise.
```

## Constraints

- Don't fill more than 3 acceptance criteria on first pass — leave room for the user.
- Mark uncertain items with `[?]` rather than guessing confidently.
- Don't write any code yet. This skill stops at the spec.
