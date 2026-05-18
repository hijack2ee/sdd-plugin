# Flow (v2): figma → PR

사용자 관점에서 어떤 skill을 언제 부르는지.

## 표준 시나리오 — Figma 진입

```
1. /sdd-from-figma <figma-url>
   → requirements draft 생성, .specs/<feature>/ scaffold 시작

2. /sdd-to-issue
   → gh issue 생성 (크기 추정 → epic/task/sub-task, assignee 지정)
   → epic이면 sub-task issue들도 동시 생성 + parent link

3. /sdd-branch
   → <type>/<issue#>-<slug> 형식으로 worktree 생성
   → .specs/bootstrap.sh 실행 (deps/env)

4. /sdd-new
   → .specs/<feature>/ 안에 requirements/design/tasks.md + manifest.yaml 완성
   → status: drafting
   → "검토 후 /sdd-new --approve 해주세요" 안내

5. (사용자가 spec 검토)

6. /sdd-new --approve
   → status: approved, manifest.spec_hash 기록

7. /sdd-implement
   → drift 체크 (spec_hash 비교) → status: implementing
   → tasks.md 미체크 1개 선택 → 작업 → 체크 → commit
   → 반복

8. /sdd-verify
   → lint/type/test 실행, 결과 manifest.ci에 기록
   → pass면 status: reviewing
   → fail이면 blockers 기록 → /sdd-implement 또는 /sdd-revise로 복귀

9. /sdd-review
   → diff ↔ requirements/design 정합성 검사
   → 누락/이탈 발견 시 /sdd-revise 권장

10. /sdd-ship
    → verify pass 확인 → PR 본문 생성 (intent + 체크된 task 목록 + Closes #N)
    → 사용자 확인 후 gh pr create
    → status: shipping

11. (외부에서 PR merge)

12. /sdd-archive
    → merge 확인 → issue close
    → worktree 제거, .specs/<feature> → .specs/archive/<YYYY-MM>/<feature>
    → status: archived
    → (선택) retro.md 한 줄 작성
```

## 대체 진입 — 텍스트/버그

Figma URL이 없는 경우:

```
1. /sdd-from-text "<요구사항 또는 버그 설명>"
   (이후 동일하게 sdd-to-issue → sdd-branch → sdd-new → ...)
```

## 진행 중 spec 갱신

코딩 중 발견된 변경:

```
/sdd-revise "<무엇이 어떻게 바뀌었나>"
→ requirements/design/tasks 중 해당 섹션 갱신
→ design.md ## Decisions 또는 requirements.md ## Change log에 한 줄 추가
→ manifest.spec_hash 갱신
→ status: revising → implementing
```

## verify 실패 시 루프

```
/sdd-verify → fail
  ↓
manifest.blockers에 실패 내용 기록
  ↓
원인이 단순 버그면: /sdd-implement (계속)
원인이 설계 가정 문제면: /sdd-revise → /sdd-implement → /sdd-verify
```

## 세션 재진입

오래 비웠다가 돌아왔을 때:

```
/sdd-implement
→ .specs/CURRENT에서 활성 feature 자동 감지
→ manifest.last_skill, status로 어디까지 했는지 표시
→ 남은 task와 blockers 안내
```

## 두 feature 병렬

worktree로 격리:

```
feature A: /sdd-branch → ../app-142-add-search/
feature B: /sdd-branch → ../app-156-fix-cache/

각 worktree의 .specs/CURRENT가 독립적으로 관리됨
```

같은 파일을 두 feature가 건드리면 머지 시점에 충돌 — 평소처럼 git이 알려줍니다.

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| `sdd-implement` "status가 drafting이라 거부" | approval gate 미통과 | `/sdd-new --approve` |
| `sdd-implement` "spec_hash mismatch" | requirements/design가 외부에서 수정됨 | `/sdd-revise`로 변경 확정 |
| `sdd-ship` "ci.status != pass" | verify 미실행 또는 실패 | `/sdd-verify` 먼저 |
| `sdd-to-issue` "duplicate issue found" | 이미 비슷한 제목의 open issue 존재 | 기존 issue 재사용 또는 `--force` |
| `sdd-branch` "worktree exists" | 이미 같은 issue로 worktree 생성됨 | 그 worktree로 `cd` |
