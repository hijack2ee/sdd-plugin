# The cycle

```
                    ┌───────────────────┐
                    │       draft       │   sdd new
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │     designing     │   (medium/large only)
                    └─────────┬─────────┘
                              │
                              ▼
        ┌───────────────────────────────────────────┐
        │              implementing                 │   ◀──┐
        └─────────────────────┬─────────────────────┘      │
                              │                            │
                              ▼                            │
                    ┌───────────────────┐                  │
                    │      revising     │  ────────────────┘
                    │  (spec updated    │   (loop until acceptance met)
                    │   from reality)   │
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │      shipped      │   sdd pr → merged
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │     archived      │   sdd archive
                    └───────────────────┘
```

## State semantics

| State | Meaning | Exit condition |
|---|---|---|
| `draft` | Spec scaffolded, intent captured | Acceptance criteria written |
| `designing` | Tradeoffs being worked out | Approach + key components decided |
| `implementing` | Code being written | All acceptance criteria pass, or a gap surfaces |
| `revising` | Spec being updated from implementation reality | Spec accurate; back to implementing or shipped |
| `shipped` | Merged to main | — |
| `archived` | Moved out of active dir | — |

## When to revise (vs just keep coding)

Revise the spec when one of these happens during implementation:

- An acceptance criterion turns out to be wrong, ambiguous, or unreachable
- A non-obvious decision is made (alternative was rejected, constraint discovered)
- Scope changes (in or out)
- New risk or dependency uncovered

If the change is purely mechanical (rename a function, refactor for clarity), keep coding — no revise needed.

## Skipping states

- **Bug fixes**: usually `draft → implementing → shipped`. Skip `designing`. `BUG.md` already separates root cause from fix.
- **Small features**: often skip `designing` if `SPEC.md`'s sketch is enough.
- **Tracer bullet first**: write the spec, drop straight to `implementing` for a thin end-to-end slice, then `revising` once you know more.

## Anti-patterns

- Filling out templates, then never reopening the file. Specs that don't change during implementation are usually wrong specs.
- Promoting size after starting (small → large mid-flight). Either split the feature, or accept that the small spec stays brief and decisions log carries the weight.
- Letting `tasks.md` rot. If you stop checking items off, delete the file — it's signaling more than it's helping.
