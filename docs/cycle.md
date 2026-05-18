# The cycle (v2)

## State machine

```
                ┌──────────────────────┐
                │      drafting        │   sdd-from-figma / sdd-from-text
                │                      │   → sdd-to-issue
                │                      │   → sdd-branch
                │                      │   → sdd-new (draft 3 docs)
                └───────────┬──────────┘
                            │
                ⏸ APPROVAL GATE ⏸   sdd-new --approve
                            │
                            ▼
                ┌──────────────────────┐
                │      approved        │
                └───────────┬──────────┘
                            │
                            ▼
                ┌──────────────────────┐   ┌─────────────────────┐
                │    implementing      │ ⇄ │      revising       │
                │  (task 단위 commit)  │   │  (spec 갱신)        │
                └───────────┬──────────┘   └─────────────────────┘
                            │
                            ▼
                ┌──────────────────────┐
                │     verifying        │   sdd-verify
                │ (lint/type/test)     │   fail → revising 또는 implementing
                └───────────┬──────────┘
                            │ pass
                            ▼
                ┌──────────────────────┐
                │     reviewing        │   sdd-review
                │ (diff ↔ spec)        │
                └───────────┬──────────┘
                            │
                            ▼
                ┌──────────────────────┐
                │     shipping         │   sdd-ship → PR
                └───────────┬──────────┘
                            │ merge (외부)
                            ▼
                ┌──────────────────────┐
                │      shipped         │
                └───────────┬──────────┘
                            │
                            ▼
                ┌──────────────────────┐
                │      archived        │   sdd-archive (worktree·issue 정리)
                └──────────────────────┘
```

## State semantics

| State | 의미 | Exit 조건 |
|---|---|---|
| `drafting` | 진입·issue·branch·spec 초안까지 | 사용자가 spec 검토 후 `sdd-new --approve` |
| `approved` | spec 검토 완료, 코드 시작 가능 | sdd-implement 진입 → `implementing` |
| `implementing` | 코드 작업 진행, tasks.md 체크박스 진행 | 모든 task 체크 또는 사용자가 verifying 요청 |
| `revising` | 구현 중 발견된 사항을 spec에 역반영 | spec 정합 → `implementing` 또는 `verifying` |
| `verifying` | lint/type/test 게이트 | pass → `reviewing`, fail → `implementing`/`revising` |
| `reviewing` | diff ↔ spec 정합성 셀프 리뷰 | 통과 → `shipping` |
| `shipping` | PR 생성, 외부 merge 대기 | merge 확인 후 → `shipped` |
| `shipped` | 머지 완료, 정리 대기 | sdd-archive → `archived` |
| `archived` | `.specs/archive/`로 이동, 완료 | — |

## 언제 revise를 부르나

다음 중 하나가 구현 중에 발생하면 sdd-revise:

- acceptance criterion이 틀렸거나 모호하거나 도달 불가
- 비자명한 결정 (대안 기각, 제약 발견)
- 스코프 변경 (in/out)
- 새 리스크나 의존 등장
- sdd-verify 실패가 단순 버그가 아니라 설계 가정 문제임이 드러남

순수 기계적 변경(rename, 단순 refactor)은 revise 불필요 — 계속 코딩.

## Drift detection

`sdd-implement` 진입 시 `requirements.md + design.md`의 해시를 `manifest.spec_hash`와 비교합니다. 다르면:

1. 경고 출력
2. 사람 확인 또는 `sdd-revise` 실행 요청
3. revise 종료 시 hash 갱신

## Anti-patterns

- approval gate를 `--force`로 무조건 우회. spec 검토 없이 코드 시작은 v2의 핵심 안전장치를 깨뜨림.
- `tasks.md`의 체크박스를 실제 진행과 무관하게 일괄 체크. sdd-implement는 task 단위 commit과 묶이므로 거짓 진행은 PR 머지 시 들통남.
- spec과 코드가 어긋났는데 sdd-revise 없이 sdd-ship 강행. sdd-ship이 차단하지만 `--force`로 풀면 외부에 잘못된 PR body가 노출됨.
- sdd-archive 없이 다음 feature 시작. `.specs/CURRENT`가 두 feature 사이에서 모호해짐.
