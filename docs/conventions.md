# Conventions (v2)

## Paths

```
.specs/
├── CURRENT                       # 단일 라인. 활성 feature 이름. 빈 줄 = 활성 없음
├── config.yaml                   # 프로젝트별 sdd 설정 (verify 명령, bootstrap, assignee 등)
├── <feature>/                    # 진행 중 feature
│   ├── manifest.yaml             # 메타데이터 SoT
│   ├── requirements.md
│   ├── design.md
│   └── tasks.md
└── archive/<YYYY-MM>/<feature>/  # sdd-archive가 옮김
    ├── manifest.yaml
    ├── requirements.md
    ├── design.md
    ├── tasks.md
    └── retro.md                  # 선택적 한 줄 회고
```

`.specs/bootstrap.sh` (옵션) — `sdd-branch`가 worktree 생성 후 자동 실행. deps install, env 복사 등.

## Feature naming

- kebab-case, 최대 30자
- 동사 우선 (`add-search`, `migrate-auth`, `fix-stale-cache`)
- 버전 번호 금지 (`search-v2` 대신 새 feature 이름 사용)

## Branch naming

`<type>/<issue#>-<slug>` 강제.

- type: `feat` | `fix` | `docs` | `style` | `refactor` | `test` | `chore`
- issue#: GitHub issue 번호
- slug: feature name (kebab-case)

예: `feat/142-add-search`, `fix/156-stale-cache`

## Metadata: manifest.yaml

모든 메타데이터는 `manifest.yaml`에 둡니다. spec 문서(.md)는 frontmatter 없이 순수 markdown입니다.

핵심 필드 (전체 스키마는 `skills/sdd-new/templates/manifest.yaml.tmpl`):

| 필드 | 의미 |
|---|---|
| `feature` | kebab-case 이름. 폴더명과 일치. write-once |
| `status` | `drafting → approved → implementing → verifying → reviewing → shipping → shipped → archived` |
| `last_skill` | 마지막 호출 skill (재진입성) |
| `source.kind` | 진입 소스 (`figma` / `text` / `issue`) |
| `issue`, `parent_issue`, `pr` | GitHub 연동 |
| `branch`, `worktree`, `base_branch` | git 컨텍스트 |
| `approved` | sdd-implement가 시작하려면 `true`여야 함 |
| `spec_hash` | requirements + design 해시. drift 감지용 |
| `progress` | tasks.md 파싱 결과 |
| `ci`, `verify` | sdd-verify가 채움 |
| `blockers` | 막힌 항목 누적 |
| `commit_policy` | `per-task` (기본) / `squash` |

## Spec docs

세 문서 모두 모든 feature에 작성합니다 (tier 없음).

### requirements.md

- `## Background` — 왜 지금 필요한가
- `## Goals` / `## Non-goals`
- `## User stories`
- `## Acceptance criteria` — 체크박스. sdd-ship 정합성 검증의 기준
- `## Dependencies / constraints`
- `## Open questions` — `[?]` 항목 정리
- `## Change log` — append-only

### design.md

- `## Overview`
- `## Architecture`
- `## Affected modules / files`
- `## Data flow / contracts`
- `## Alternatives considered`
- `## Risks`
- `## Decisions` — append-only, 한 줄 + 날짜
- `## Change log`

### tasks.md

- `## Progress` — 총/완료/남음 (sdd-implement가 갱신)
- `## Tasks` — `- [ ] T<N> — <title> [refs: AC<N>, design#<section>]`
- `## Blockers`
- `## Notes`

## Decisions log

`design.md`의 `## Decisions` 섹션은 **append-only**. 한 줄 + 날짜.

```markdown
## Decisions
- 2026-04-16 fuse.js 채택. 짧은 쿼리에 substring이 너무 엄격해서
- 2026-04-17 서버 검색 보류. 1k 이내에선 클라이언트 필터로 충분
```

과거 항목 삭제/수정 금지. 변경하려면 새 줄에 보정.

## Issue ↔ spec 관계

| 위치 | 책임 |
|---|---|
| GitHub issue | pitch, 외부 토론, 이해관계자 질문 |
| `requirements.md` | scoped, 검증 가능한 수용 기준 |
| `design.md` | 어떻게 — trade-off, 컴포넌트, 데이터 |
| `## Decisions` | 구현 중 내린 선택 |
| PR body | spec 요약 + diff (sdd-ship이 자동 생성) |

불일치 시 **spec wins**. sdd-to-issue가 issue body 첫 줄을 spec 폴더 링크로 자동 갱신합니다.

## Commit policy

기본은 **per-task**:

```
<type>(<scope>): T<N> <task title> (refs #<issue>)
```

예: `feat(search): T3 SearchBar 컴포넌트 추가 (refs #142)`

`manifest.commit_policy: squash`로 바꾸면 sdd-ship이 PR 머지 시 squash 메시지를 권장합니다.

## Idempotency 규약 (모든 skill 공통)

- 진입: manifest 읽고 `status`가 예상치와 다르면 거부 (`--force`로 우회)
- 종료: `last_skill`, `updated_at` 갱신
- 외부 부작용(issue, worktree, PR)은 "있으면 재사용, 없으면 생성"
- destructive 액션은 `--dry-run` 기본 지원
