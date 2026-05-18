# .codex/prompts/

이 디렉터리의 `.md` 파일은 `skills/<name>/SKILL.md`에서 자동 생성됩니다.
**Source of truth는 `skills/`** — 이 폴더 파일을 직접 편집하지 마세요.

## Rebuild

```bash
scripts/build-codex.sh
```

기존 prompt와 동일하면 skip, 다르면 갱신합니다. 삭제된 skill의 prompt는 자동으로 정리됩니다.

## CI / drift check

```bash
scripts/build-codex.sh --check
```

`.codex/prompts/`가 `skills/`와 어긋나면 exit 1. CI에 등록해서 commit 누락을 방지하세요.

## Codex CLI에서 사용

OpenAI Codex CLI는 prompts를 보통 `~/.codex/prompts/` 또는 프로젝트 `.codex/prompts/`에서 읽습니다 (버전에 따라 다름 — `codex --help` 또는 공식 문서 확인).

전역 사용 예 (symlink로 plugin repo와 sync 유지):

```bash
git clone https://github.com/hijack2ee/sdd-plugin ~/code/sdd-plugin
mkdir -p ~/.codex/prompts
for p in ~/code/sdd-plugin/.codex/prompts/*.md; do
  ln -sf "$p" ~/.codex/prompts/
done
```

이후 Codex CLI에서 `/sdd-from-figma`, `/sdd-new`, `/sdd-implement` 등으로 호출.

## Note: 보조 파일 (templates, constitution)

`skills/sdd-init/templates/config.yaml.tmpl`, `skills/sdd-new/templates/*.tmpl`,
`skills/sdd-init/constitution.md` 같은 번들 파일은 Codex 환경에서 직접 접근하기 어려울 수 있습니다.

해결책 (둘 중 하나):
1. plugin repo 전체를 clone하고, prompt 본문의 "this skill's templates/" 경로를 환경에 맞게 해석
2. 향후 build-codex.sh가 inline injection을 지원할 예정 (v0.3+)

당장은 plugin repo를 clone한 상태에서 codex를 실행하는 게 가장 안전합니다.
