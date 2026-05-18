# Project conventions (SDD v2)

This repo uses Spec-Driven Development. Active feature: `.specs/CURRENT`.

## Flow

```
진입:    /sdd-from-figma <url>   또는   /sdd-from-text "<요구사항>"
        ↓
        /sdd-to-issue              gh issue 생성 (epic/task/sub-task)
        ↓
        /sdd-branch                worktree + bootstrap
        ↓
        /sdd-new                   requirements/design/tasks.md 작성
        ↓
        (사람 검토)
        ↓
        /sdd-new --approve         approval gate 통과
        ↓
        /sdd-implement   ⇄  /sdd-revise   (task 단위 commit)
        ↓
        /sdd-verify                lint/type/test 게이트
        ↓
        /sdd-review                diff ↔ spec 정합성
        ↓
        /sdd-ship                  PR 생성
        ↓
        (PR merge)
        ↓
        /sdd-archive               worktree·issue 정리
```

전체 state machine: plugin `docs/cycle.md`. 사용자 시나리오·트러블슈팅: `docs/flow.md`.

## Spec docs (모든 feature에 3개 작성)

- `requirements.md` — background, goals, acceptance criteria (체크박스)
- `design.md` — architecture, alternatives, decisions log (append-only)
- `tasks.md` — task 체크박스, 각 task는 AC/design 섹션 참조

## Metadata

모든 메타데이터는 `.specs/<feature>/manifest.yaml`에 둡니다. spec `.md` 파일에는 frontmatter가 없습니다.

핵심 필드: `feature`, `status`, `issue`, `branch`, `approved`, `spec_hash`, `progress`, `ci`. 전체 스키마는 plugin `docs/conventions.md`.

## States

`drafting → approved → implementing ⇄ revising → verifying → reviewing → shipping → shipped → archived`

skill들이 `status`를 바꿉니다. manifest를 직접 손으로 편집하는 건 피하세요.

## Decisions log

구현 중 비자명한 선택을 `design.md ## Decisions`에 append-only로 기록 (한 줄 + 날짜). 과거 항목 삭제·수정 금지.

## Project-specific rules

(스택, 스타일, do/don't를 여기에. 한 화면을 넘기지 마세요.)
