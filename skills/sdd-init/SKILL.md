---
name: sdd-init
description: Bootstrap a repo to use Simplified Spec-Driven Development. Creates .specs/ scaffolding and tailors a project CLAUDE.md to the detected stack. Use once per repo on day one. Trigger phrases - "set up SDD", "initialize SDD", "/sdd-init".
---

# sdd-init

One-shot setup. Run once per repo.

## Process

1. **Confirm working dir is a repo root.** Look for `.git/`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`. If ambiguous, ask the user before writing.

2. **If `.specs/` already exists**, exit early with a one-line note. Do not overwrite.

3. **Create scaffolding:**
   - `.specs/archive/` (directory)
   - `.specs/CURRENT` (empty file)

4. **Generate `CLAUDE.md`:**
   - Read this skill's bundled `constitution.md` (relative to this SKILL.md).
   - Detect project stack from manifest files (e.g. `package.json` → "TypeScript/Node", `pyproject.toml` → "Python", etc.).
   - At the bottom of the constitution, under `## Project-specific rules`, add 1–3 short bullets reflecting the detected stack (test runner, build command, lint command). Skip if the stack can't be cleanly detected — leave the section empty.
   - If `<repo>/CLAUDE.md` does not exist: write the new content there.
   - If it exists: do **not** overwrite. Append a short `## SDD Methodology` section with a pointer line ("This repo uses Simplified SDD; see `.specs/`. Active feature in `.specs/CURRENT`.") if not already present.

5. **Report:** one-line summary of what was created.

## Output format

```
✓ initialized .specs/ at <path>
✓ created CLAUDE.md (detected: TypeScript/Node)
```

## Constraints

- Never overwrite an existing `CLAUDE.md`.
- Never write outside the current working directory tree.
- Don't run `git init`. Assume the repo is already initialized.
