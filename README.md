# sdd-plugin

Simplified Spec-Driven Development for Claude Code. A lightweight, cyclic alternative to spec-kit, distributed as a Claude Code plugin.

## Philosophy

1. **Tier by size.** Bug fixes don't earn three files. Most features don't either.
2. **Cyclic, not waterfall.** Specs evolve as implementation reveals reality.
3. **Living docs.** The spec at merge time matches the code that shipped.
4. **Agent-native.** No CLI to install. The agent that writes code also writes specs.

## Install

```bash
# from any Claude Code session
/plugin install <git-url>
```

Or for local development:

```bash
git clone <this-repo> ~/.claude/plugins/sdd
```

## Skills

Once installed, these skills become available in any repo:

| Skill | When to use |
|---|---|
| `sdd-init` | Once per repo. Bootstraps `.specs/` and tailors a project `CLAUDE.md` |
| `sdd-new` | Starting any feature, bug, or refactor. Interviews you, infers size, drafts content |
| `sdd-revise` | Mid-implementation, when code reveals a spec gap |
| `sdd-ship` | Right before opening a PR. Verifies spec ↔ code match, drafts PR body |
| `sdd-archive` | After merge. Moves spec into dated archive |

## Sizes

| Size | When | Files |
|------|------|-------|
| `bug` | Defect fix, < 1 day | `BUG.md` |
| `small` | Self-contained, < 1 week | `SPEC.md` (intent / acceptance / sketch) |
| `medium` | Multi-file, design choices | `requirements.md` + `design.md` |
| `large` | Cross-cutting, multi-week | adds `tasks.md` |

Default to one tier smaller than your gut.

## Cycle

```
draft → designing → implementing ⇄ revising → shipped → archived
```

See [docs/cycle.md](docs/cycle.md) and [docs/conventions.md](docs/conventions.md).

## Layout in a target repo

```
.specs/
├── CURRENT                # active feature pointer
├── <feature>/
│   └── (one of: BUG.md | SPEC.md | requirements.md+design.md[+tasks.md])
└── archive/
    └── 2026-04/
        └── <feature>/
```

## Plugin layout

```
sdd-plugin/
├── .claude-plugin/plugin.json
├── README.md
├── docs/
│   ├── cycle.md
│   └── conventions.md
├── skills/
│   ├── sdd-init/         (bundles constitution.md)
│   ├── sdd-new/          (bundles templates/)
│   ├── sdd-revise/
│   ├── sdd-ship/
│   └── sdd-archive/
└── examples/
```

## License

MIT (or your choice).
