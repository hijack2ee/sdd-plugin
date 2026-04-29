# Conventions

## Paths

- `.specs/CURRENT` — single-line file holding the active feature name. Empty = no active feature.
- `.specs/<feature-name>/` — feature folder. Name is kebab-case, ≤30 chars.
- `.specs/archive/<YYYY-MM>/<feature-name>/` — archived features grouped by archive month.

## Frontmatter

Every spec file starts with YAML frontmatter:

```yaml
---
feature: add-search
size: small
state: implementing
issue: 142
pr: 168
created: 2026-04-29
---
```

Fields:

| Field | Required | Notes |
|---|---|---|
| `feature` | yes | Must match folder name |
| `size` | yes | `bug` \| `small` \| `medium` \| `large` |
| `state` | yes | See [cycle.md](cycle.md) |
| `issue` | optional | GitHub issue number |
| `pr` | optional | GitHub PR number |
| `created` | yes | ISO date |

The CLI updates `state`, `issue`, `pr` for you. `feature` and `created` are write-once.

## Decisions log

Every spec ends with a `## Decisions` section. Append entries during implementation:

```markdown
## Decisions

- Picked fuse.js over substring match — short queries felt too strict (2026-04-16)
- Skipped server-side search; client filter fast enough up to 1k items (2026-04-17)
```

Each entry: one line, dated. This is the part of the spec that survives — the part future readers will actually use.

## Naming

- Feature names: kebab-case, verb-led when natural (`add-search`, `migrate-auth`, `fix-stale-cache`).
- Bug names: same convention; usually `fix-` prefixed.
- Avoid version numbers in names (`search-v2`); use a new feature name instead.

## Issue ↔ spec contract

| Lives in | Belongs there |
|---|---|
| GitHub issue | Pitch, discussion, stakeholder questions |
| `requirements.md` / `SPEC.md` | Scoped, testable acceptance |
| `design.md` | How — tradeoffs, components, data |
| Decisions log | Choices made during implementation |
| PR body | Generated summary of spec + diff |

When issue and spec disagree, **spec wins**. Update the issue body to point to the spec.

## Tasks file

`tasks.md` is optional even at `large` size. Keep it only if:

- It tracks work that won't naturally show up as failing tests, or
- It's a real coordination artifact (multi-person split)

Otherwise, delete it. Stale `tasks.md` is worse than no `tasks.md`.
