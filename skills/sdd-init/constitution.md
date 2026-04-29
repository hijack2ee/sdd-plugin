# Project conventions

This repo uses Simplified SDD. Active feature: see `.specs/CURRENT`.

## Working a feature

1. Read `.specs/CURRENT` to find the active feature folder.
2. Read every `.md` file in `.specs/<feature>/`. They are the source of truth.
3. Implement against the acceptance criteria (in `requirements.md`, or `SPEC.md` for small features).
4. If implementation reveals a gap, **update the spec first**, then continue.
5. Append non-obvious choices to the `## Decisions` log at the bottom of `design.md` (or `SPEC.md`).
6. Before marking `shipped`, ensure the spec matches what actually shipped.

## Spec sizes

- `bug` — symptom / root cause / fix (`BUG.md`)
- `small` — single `SPEC.md`: intent, acceptance, sketch
- `medium` — `requirements.md` + `design.md`
- `large` — adds `tasks.md`

## Frontmatter (every spec file)

```yaml
---
feature: <name>
size: bug | small | medium | large
state: draft | designing | implementing | revising | shipped
issue: <number>
pr: <number>
created: YYYY-MM-DD
---
```

## Cycle states

`draft → designing → implementing ⇄ revising → shipped → archived`

Move via `sdd state <name> <new-state>`. Don't hand-edit unless you know what you're doing.

## Project-specific rules

(Add stack, style, do/don't here. Keep this section short — under one screen.)
