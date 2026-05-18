# sdd-plugin — Agent guide (Codex)

이 plugin은 Spec-Driven Development v2 workflow를 OpenAI Codex CLI에서 사용할 수 있게 합니다.

## 어떤 repo에서 동작하나

`.specs/` 디렉터리와 `.specs/config.yaml`이 있는 repo. 없으면 먼저 `/sdd-init`을 실행하세요.

활성 feature 이름은 `.specs/CURRENT`에 있고, 메타데이터는 `.specs/<feature>/manifest.yaml`에 있습니다. spec 문서(.md)는 frontmatter를 쓰지 않습니다.

## 12개 skill (모두 `/sdd-*` slash command)

| 단계 | Skill | 한 줄 |
|---|---|---|
| 진입 | `/sdd-from-figma <url>` | Figma URL → feature scaffold |
| 진입 | `/sdd-from-text` | text/bug → feature scaffold |
| 자동화 | `/sdd-to-issue` | gh issue 생성, 중복 탐지 |
| 자동화 | `/sdd-branch` | `<type>/<#>-<slug>` worktree + bootstrap |
| 작성 | `/sdd-new` | requirements/design/tasks 작성. `--approve`로 게이트 통과 |
| 코딩 | `/sdd-implement` | drift 체크, 남은 task surface, tracer 제안 |
| 갱신 | `/sdd-revise` | 진행 중 spec 변경, spec_hash 재계산 |
| 검증 | `/sdd-verify` | lint/type/test, 결과를 manifest.ci에 기록 |
| 리뷰 | `/sdd-review` | diff ↔ spec 정합성 보고 |
| 출시 | `/sdd-ship` | verify pass 확인 → PR body 자동 생성 |
| 정리 | `/sdd-archive` | issue close, worktree/branch 제거, archive |
| 초기 | `/sdd-init` | repo 첫 설정 |

## 흐름

```
/sdd-from-figma → /sdd-to-issue → /sdd-branch → /sdd-new
  → (검토) → /sdd-new --approve
  → /sdd-implement ⇄ /sdd-revise
  → /sdd-verify → /sdd-review → /sdd-ship
  → (merge) → /sdd-archive
```

자세한 state machine은 plugin 저장소의 `docs/cycle.md`, 시나리오는 `docs/flow.md`를 참조하세요.

## 핵심 규약

- **frontmatter 없음.** 모든 메타는 manifest.yaml.
- **3개 doc 강제.** size tier 없음.
- **branch naming 강제**: `<type>/<issue#>-<slug>` (type ∈ feat|fix|docs|style|refactor|test|chore).
- **per-task commit** 기본: `<type>(<scope>): T<N> <title> (refs #<issue>)`.
- **approval gate**: `/sdd-implement`는 `manifest.approved == true`가 아니면 거부.
- **verify gate**: `/sdd-ship`은 `manifest.ci.status == pass` && SHA 일치가 아니면 거부.
- **spec drift**: `requirements + design`의 해시가 `manifest.spec_hash`와 다르면 `/sdd-implement` 진입 시 경고.

## Decisions log

구현 중 비자명한 선택은 `design.md ## Decisions`에 한 줄 + 날짜로 append. 과거 항목 절대 삭제·수정 금지.

## Codex에서 주의할 점

`skills/sdd-init/constitution.md`, `skills/sdd-init/templates/config.yaml.tmpl`, `skills/sdd-new/templates/*.tmpl` 같은 보조 파일은 Codex 환경에서 직접 접근하기 어려울 수 있습니다. plugin repo를 clone한 상태에서 codex를 실행하면 prompt 본문이 가리키는 상대 경로로 접근 가능합니다.
