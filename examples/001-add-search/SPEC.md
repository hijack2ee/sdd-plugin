---
feature: add-search
size: small
state: shipped
issue: 42
pr: 51
created: 2026-04-15
---

# Add full-text search to the notes view

## Intent
Users with > 50 notes can't find old entries quickly. Add an inline search box that filters the list as they type. Goal: zero clicks from the notes view to start searching.

## Acceptance
- [x] Search input above the notes list, focused by `/` keystroke
- [x] Results filter on each keystroke (debounced 100ms)
- [x] Empty query restores the full list
- [x] Matches highlighted in the rendered list
- [x] No perceptible UI lag on lists up to 1000 notes

## Sketch
- `components/notes/SearchBar.tsx` — input + keybind handler
- `hooks/useFilteredNotes.ts` — debounced filter
- `lib/search.ts` — fuzzy match (fuse.js)
- Wired into `pages/notes/index.tsx`

## Decisions
- Picked fuse.js over substring match — short queries felt too strict in user testing (2026-04-16)
- Skipped server-side search; client filter holds up to 1k items, which covers >99% of accounts (2026-04-17)
- Highlighting moved into `NoteListItem` rather than a wrapper; needed access to the title/body split (2026-04-18)
