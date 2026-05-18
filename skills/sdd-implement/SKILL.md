---
name: sdd-implement
description: Begin or resume implementation of an approved feature. Reads manifest, verifies approval gate and spec drift, surfaces unchecked acceptance criteria and tasks, and hands off to coding mode. Does NOT create branches (use sdd-branch). Trigger phrases - "start implementing", "/sdd-implement", "resume feature X", "let's code".
---

# sdd-implement

Set up the runway from spec to code. **Does not write production code** — it prepares context, then hands off.

## Inputs

- **Feature name** — if omitted, read `.specs/CURRENT`. If still empty, ask user.

## Preconditions

1. `.specs/<feature>/manifest.yaml` exists.
2. `manifest.approved == true` (else: refuse with anchor message — see below).
3. `manifest.branch`가 현재 git branch와 일치 (worktree 모드면 worktree 경로도 확인). 다르면 경고하고 사용자 결정 대기.
4. Repo working tree에 uncommitted changes 없음 (있으면 경고, 사용자 ack 후 진행).

## Process

1. **Find feature** (인자 또는 `.specs/CURRENT`).

2. **Read manifest.yaml.** 다음 분기:

   | manifest 상태 | 동작 |
   |---|---|
   | `approved: false` | **거부**. 한 줄 안내: "approval gate 미통과. `/sdd-new --approve` 먼저." |
   | `status: shipped` 또는 `archived` | **거부**. "이미 종료된 feature입니다." |
   | `status: implementing`이고 같은 branch | 재진입 — 정상 진행 |
   | `status: approved` | 첫 진입 — 정상 진행 |
   | 그 외 (revising, verifying, ...) | 한 줄 안내 후 진행 (사용자가 의도한 것일 수 있음) |

3. **Drift check:**
   - `requirements.md + design.md` 내용을 concat → sha256 계산
   - `manifest.spec_hash`와 비교
   - 다르면 **경고**:
     ```
     ⚠ spec drift detected
     manifest.spec_hash: 9f2c...
     current hash:       d41a...
     /sdd-revise로 변경 사항을 정리하거나, 그대로 진행하려면 ack 해주세요.
     ```
   - 사용자 ack 없이는 자동 진행하지 말 것.

4. **Read all spec files** in `.specs/<feature>/`. They are the source of truth.

5. **Parse tasks.md:**
   - 미체크 task 목록 (`- [ ] T<N> — ...`)
   - 체크된 task 수, 총 task 수
   - `## Blockers` 섹션 (있으면 표시)
   - `manifest.progress.total_tasks` / `done` 갱신

6. **Parse requirements.md `## Acceptance criteria`:**
   - 미체크 AC 목록
   - `[?]` 표시된 AC가 있으면 "확인 필요" 경고 → `/sdd-revise` 권장

7. **Suggest a tracer bullet** (첫 진입일 때만):
   - 미체크 task 중 가장 작은 end-to-end slice 선택
   - 관련 파일 2–3개 제시 (design.md `## Affected modules`에서)
   - 한 줄로 *왜* 그것이 적절한지

8. **Bump manifest**:
   - `status: implementing`
   - `last_skill: sdd-implement`
   - `updated_at: <today>`

9. **Hand off**:
   - 현재 git 컨텍스트 (branch, worktree path) 출력
   - 남은 task와 tracer 표시
   - **명시적 안내**: "각 task 완료 시 `tasks.md`의 체크박스를 `[x]`로 바꾸고 per-task commit 하세요. 막히면 `/sdd-revise`, 끝나면 `/sdd-verify`."

## Per-task commit convention

`manifest.commit_policy == per-task`인 경우 (기본):

```
<type>(<scope>): T<N> <task title> (refs #<issue>)
```

- `<type>`: feat/fix/docs/style/refactor/test/chore (manifest.branch의 prefix와 일치 권장)
- `<scope>`: 영향 모듈명 (optional)
- 예: `feat(search): T3 SearchBar 컴포넌트 추가 (refs #142)`

## Output format (첫 진입)

```
✓ feature: add-search
✓ branch: feat/142-add-search (clean)
✓ status: approved → implementing
✓ spec_hash: matches

unchecked acceptance criteria:
  - [ ] AC1 — Search input above the notes list, focused by `/`
  - [ ] AC2 — Results filter on each keystroke (debounced 100ms)
  - [?] AC3 — Matches highlighted in the rendered list  ← 불확실, /sdd-revise로 확정 권장

tasks (3/8 done):
  remaining:
  - [ ] T4 — SearchBar 컴포넌트 추가 [refs: AC1, design#SearchBar]
  - [ ] T5 — Debounce hook [refs: AC2, design#Debounce]
  - [ ] T6 — 통합 테스트 [refs: AC1, AC2]
  ...

tracer bullet:
  pick: T4 — SearchBar 컴포넌트 추가
  files: components/notes/SearchBar.tsx, pages/notes/index.tsx
  why: smallest slice that proves keystroke → handler wiring

ready to code. 각 task 완료 시 [x] 체크 + commit. 막히면 /sdd-revise, 끝나면 /sdd-verify.
```

## Output format (재진입)

```
✓ feature: add-search (resuming)
✓ branch: feat/142-add-search
✓ status: implementing
✓ spec_hash: matches
✓ last_skill: sdd-implement (yesterday)

progress: 5/8 tasks done

remaining:
  - [ ] T6 — 통합 테스트
  - [ ] T7 — empty state UI
  - [ ] T8 — README 갱신

blockers: (none)

continue. 끝나면 /sdd-verify.
```

## Output format (refused)

```
✗ /sdd-implement 거부됨

  feature:  add-search
  reason:   approval gate 미통과 (manifest.approved == false)

다음 단계: /sdd-new --approve
```

## Constraints

- **Production code를 작성하지 말 것.** 이 skill은 runway만.
- approval gate(`approved: true`)와 spec_hash drift는 강한 가드. 사용자 ack 없이 우회하지 말 것.
- branch/worktree 생성은 sdd-branch 책임. 이 skill에서 만들지 말 것.
- uncommitted changes가 있으면 한 번 경고. 무조건 거부하진 말 것 (의도된 WIP일 수 있음).
- `[?]` 항목은 tracer bullet으로 절대 고르지 말 것.

## When to use

✅ Use:
- /sdd-new --approve 직후
- 휴식 후 작업 재개 (재진입)
- /sdd-revise 직후 다시 코딩 시작
- /sdd-verify 실패 후 수정 작업 진입

❌ Don't use:
- branch가 없거나 잘못된 경우 → `/sdd-branch`
- approval 안 받은 경우 → `/sdd-new --approve`
- spec이 바뀌어야 하는 경우 → `/sdd-revise`
