# sdd-plugin (v2)

Spec-Driven Development for Claude Code + OpenAI Codex.
Figma-to-PR flow with mandatory requirements/design/tasks docs, approval gate, and verify gate. Cyclic, LLM-agnostic.

## Why

| Pain | What SDD v2 does |
|---|---|
| Figma → 요구사항 → 코드까지 매번 사람이 옮겨야 함 | `sdd-from-figma`로 한 번에 scaffold |
| 같은 일을 두 LLM에서 다르게 하게 됨 | `skills/`가 SoT, `scripts/build-codex.sh`로 Codex 자동 동기화 |
| spec과 코드가 어긋남 | manifest의 `spec_hash` drift 감지, sdd-revise로 즉시 정리 |
| 검증 없이 머지됨 | `sdd-verify` 게이트 — pass 없이는 `sdd-ship` 거부 |
| 머지 후 정리 누락 | `sdd-archive`가 issue close + worktree 제거 + archive 폴더 이동 |

## Install

### Claude Code

```bash
git clone https://github.com/hijack2ee/sdd-plugin ~/code/sdd-plugin
mkdir -p ~/.claude/skills
for s in ~/code/sdd-plugin/skills/*/; do
  ln -sf "$s" ~/.claude/skills/
done
```

Claude Code를 재시작하면 12개 `/sdd-*` skill이 활성화됩니다.

### OpenAI Codex CLI

```bash
mkdir -p ~/.codex/prompts
for p in ~/code/sdd-plugin/.codex/prompts/*.md; do
  ln -sf "$p" ~/.codex/prompts/
done
```

자세한 사항은 [`.codex/README.md`](./.codex/README.md).

### Per-repo init

작업할 repo에서 한 번 실행:

```
/sdd-init
```

`.specs/` 디렉터리와 `CLAUDE.md`/`AGENTS.md`가 생성됩니다.

## Skills (12)

### 진입

| Skill | When |
|---|---|
| `sdd-from-figma` | Figma URL에서 시작. design context → manifest + requirements draft |
| `sdd-from-text` | bug report·feature 설명에서 시작. text → manifest + requirements draft |

### 자동화

| Skill | When |
|---|---|
| `sdd-to-issue` | manifest 기반 `gh issue create`. 중복 탐지, label/assignee 추정 |
| `sdd-branch` | `<type>/<issue#>-<slug>` worktree. base pull + `.specs/bootstrap.sh` 실행 |

### 코어 루프

| Skill | When |
|---|---|
| `sdd-new` | requirements/design/tasks.md + manifest 작성. `--approve`로 approval gate 통과 |
| `sdd-implement` | 코드 시작·재진입. drift 체크, 남은 task와 tracer bullet 안내 |
| `sdd-revise` | 진행 중 spec 갱신. spec_hash 재계산, status 복원 |
| `sdd-verify` | lint/type/test 게이트. 결과를 manifest.ci에 기록 |
| `sdd-review` | diff ↔ spec 정합성 보고 (거부 X) |
| `sdd-ship` | verify pass 확인 → PR body 자동 생성 → `gh pr create` |

### 정리

| Skill | When |
|---|---|
| `sdd-archive` | PR merge 후. issue close, worktree/branch 제거, `.specs/archive/<YYYY-MM>/`로 이동 |
| `sdd-init` | repo 첫 설정. `.specs/`, `config.yaml`, `CLAUDE.md` 생성 |

## Flow

```
/sdd-from-figma <url>  또는  /sdd-from-text "<설명>"
       ↓
/sdd-to-issue       gh issue 생성
       ↓
/sdd-branch         worktree + bootstrap
       ↓
/sdd-new            requirements/design/tasks 작성
       ↓
(사람 검토)
       ↓
/sdd-new --approve  approval gate 통과
       ↓
/sdd-implement  ⇄  /sdd-revise   (task 단위 commit)
       ↓
/sdd-verify         lint/type/test 게이트
       ↓
/sdd-review         spec ↔ code 정합성
       ↓
/sdd-ship           PR 생성
       ↓
(PR merge)
       ↓
/sdd-archive        정리
```

전체 state machine과 트러블슈팅은 [`docs/cycle.md`](./docs/cycle.md), [`docs/flow.md`](./docs/flow.md).

## Layout in a target repo

```
.specs/
├── CURRENT                       # 활성 feature 이름
├── config.yaml                   # 프로젝트 sdd 설정 (verify 명령, 등)
├── bootstrap.sh                  # (옵션) sdd-branch가 worktree 생성 후 실행
├── <feature>/                    # 진행 중
│   ├── manifest.yaml             # 메타데이터 SoT
│   ├── requirements.md
│   ├── design.md
│   └── tasks.md
└── archive/<YYYY-MM>/<feature>/  # sdd-archive가 이동
    └── ... + retro.md
```

상세 컨벤션은 [`docs/conventions.md`](./docs/conventions.md).

## Plugin layout

```
sdd-plugin/
├── .claude-plugin/plugin.json
├── .codex/
│   ├── README.md
│   └── prompts/                  # build-codex.sh가 생성 (skills SoT)
├── docs/
│   ├── conventions.md            # paths, manifest, branch naming, commit policy
│   ├── cycle.md                  # state machine, drift detection
│   └── flow.md                   # 사용자 시나리오, 트러블슈팅
├── scripts/
│   └── build-codex.sh            # skills/ → .codex/prompts/ (--check for CI)
└── skills/                       # SoT
    ├── sdd-init/        (bundles constitution.md + templates/config.yaml.tmpl)
    ├── sdd-new/         (bundles templates/{requirements,design,tasks,manifest}.tmpl)
    ├── sdd-from-figma/
    ├── sdd-from-text/
    ├── sdd-to-issue/
    ├── sdd-branch/
    ├── sdd-implement/
    ├── sdd-revise/
    ├── sdd-verify/
    ├── sdd-review/
    ├── sdd-ship/
    └── sdd-archive/
```

## CI suggestion

```yaml
# .github/workflows/codex-drift.yml
on: [pull_request]
jobs:
  check-codex:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: scripts/build-codex.sh --check
```

## Migrating from v1

v1 (tier 기반: bug/small/medium/large)에서 v2로:
- 기존 spec은 `.specs/archive/`에 그대로 두기 (v1 frontmatter 호환 안 됨)
- 신규 feature부터 v2 flow 사용
- 자세한 가이드는 추후 추가 예정

## License

MIT.
