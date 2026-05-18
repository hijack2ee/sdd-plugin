
# sdd-revise

Keep spec and reality aligned. Use when implementation surfaces something the spec doesn't cover.

## When to use

✅ Use when:
- An acceptance criterion turned out wrong, ambiguous, or unreachable
- A non-obvious decision was made (alternative rejected, constraint discovered)
- Scope changed (in or out)
- A new risk or dependency surfaced
- sdd-verify failure revealed a design gap (not just a bug)
- Drift warning from sdd-implement

❌ Don't use for:
- Pure refactors (rename, extract) that don't change behavior
- Trivially mechanical changes
- Routine progress reporting (just `[x]` the task and commit)
- "사양은 그대로지만 task만 추가" — task 추가는 그냥 tasks.md에 한 줄 추가 + commit. revise 불필요.

## Inputs

- **Feature name** — if omitted, read `.specs/CURRENT`.
- **Change description** — 사용자가 무엇을 바꾸려는지. 짧으면 추정해도 OK.

## Process

1. **Find feature** (인자 또는 CURRENT).

2. **Read manifest.yaml + 3개 spec 문서.**

3. **Record previous status** (변경 후 복원하기 위해). `manifest.status` → `revising`.

4. **Apply the update** based on type of change:

   | Change type | Where it goes |
   |---|---|
   | New decision (대안 기각, 발견된 제약) | `design.md ## Decisions`에 한 줄 + 날짜 append |
   | AC 변경 | `requirements.md`의 해당 bullet 수정. 중요한 변경은 `~~old~~` 취소선 후 새 문구 |
   | AC 완료 | `requirements.md`에서 `[x]` |
   | Scope 변경 | `requirements.md ## Goals` / `## Non-goals` 갱신 |
   | New risk | `design.md ## Risks` append |
   | Approach 변경 | `design.md ## Architecture`/`## Overview` 갱신 + Decisions에 한 줄 |
   | New task | `tasks.md`에 `- [ ] T<N+1> — ...` append |
   | Task 변경 | tasks.md의 해당 bullet 수정 |
   | Blocker 추가 | `tasks.md ## Blockers`에 append + manifest.blockers에 객체 추가 |

5. **Decisions log format** (append-only, dated):
   ```markdown
   ## Decisions
   - YYYY-MM-DD <한 줄 결정>
   ```
   과거 항목 절대 삭제·재작성 금지.

6. **Change log update**:
   - requirements.md 또는 design.md 본문이 바뀌었으면 `## Change log`에 한 줄 추가:
     ```
     - YYYY-MM-DD <무엇을 바꿨나>
     ```

7. **Recompute spec_hash** if requirements.md 또는 design.md 변경됨:
   - `sha256(requirements.md + design.md)` → manifest.spec_hash

8. **Recompute progress** if tasks.md 변경됨:
   - 총/완료 task 수 → manifest.progress

9. **Restore status**:
   - 이전 status가 `implementing`이었으면 → `implementing`으로 복원
   - 이전 status가 `verifying` (verify 실패 후 revise) → `implementing`으로 강등 (verify 다시 돌려야 함)
   - 이전 status가 `reviewing`/`shipping` → `implementing`으로 강등
   - 이전 status가 `approved` (구현 전 변경) → `approved` 유지하되 `approved: false`로 되돌리고 사용자에게 재승인 요청. 큰 변경(예: AC 추가/삭제)일 때만.

10. **Update manifest**:
    - `last_skill: sdd-revise`
    - `updated_at: <today>`

11. **Report**:
    - 무엇이 어디서 어떻게 바뀌었나 (한 줄씩)
    - spec_hash 변경 여부
    - 복원된 status

## Output format

```
✓ revised: add-search

changes:
  - requirements.md: AC3 reworded ("highlighted" → "underlined")
  - design.md: Decisions에 "fuse.js 채택" 1줄 append
  - tasks.md: T9 "underline 스타일링" 추가
  - manifest.spec_hash: 9f2c... → 8b41...
  - manifest.progress: 5/8 → 5/9

status: implementing → revising → implementing

continue. /sdd-implement로 이어서 작업하거나 /sdd-verify로 게이트 확인.
```

## When the revision is too big

spec이 거의 다 바뀐다면 → 사용자에게 권유: "현재 feature를 archive하고 새 feature로 시작하는 게 더 깨끗합니다 (`/sdd-archive` → `/sdd-from-*` 또는 `/sdd-new`)."

## Constraints

- Decisions log는 append-only.
- 한 줄짜리 decision은 자체완결적이어야 함 ("우리는 결정했다"는 군더더기 금지).
- requirements.md/design.md를 손대면 반드시 spec_hash 재계산.
- 큰 AC 변경은 approval 재요청 트리거. (작은 단어 수정 같은 건 그대로 통과.)
- 코드 작성 금지.

## Difference from sdd-new --approve

| | sdd-new --approve | sdd-revise |
|---|---|---|
| 언제 | spec 초안 검토 후 한 번 | 구현 중 spec 변경 시 매번 |
| 효과 | approval gate 통과, spec_hash 기록 | spec 갱신, spec_hash 재계산 |
| status | drafting → approved | (현재) → revising → (복원) |
