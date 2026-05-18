
# sdd-init

One-shot setup. Run once per repo.

## Process

1. **Confirm working dir is a repo root.** Look for `.git/`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`. If ambiguous, ask the user before writing.

2. **If `.specs/` already exists**, exit early with a one-line note. Do not overwrite.

3. **Create scaffolding:**
   - `.specs/archive/` (directory)
   - `.specs/CURRENT` (empty file — active feature pointer)
   - `.specs/config.yaml` — copy from this skill's `templates/config.yaml.tmpl`. Substitute nothing; the user edits this file directly.

4. **Detect project stack** from manifest files:
   - `package.json` → "TypeScript/Node"
   - `pyproject.toml` → "Python"
   - `go.mod` → "Go"
   - `Cargo.toml` → "Rust"
   - 등.

5. **Adjust `config.yaml` verify commands** based on the detected stack (best-effort):
   - TypeScript/Node: keep `npm run lint`, `npm run typecheck`, `npm test` (or detect `pnpm`/`yarn`/`bun` from lockfile).
   - Python: `ruff check .`, `mypy .`, `pytest -q`.
   - Go: `go vet ./...`, `go build ./...`, `go test ./...`.
   - Rust: `cargo clippy --all-targets -- -D warnings`, `cargo build`, `cargo test`.
   - 스택 감지 실패 시 기본 (Node) 그대로 두고 사용자에게 수동 편집 안내.

6. **Generate `CLAUDE.md`:**
   - Read this skill's bundled `constitution.md` (relative to this SKILL.md).
   - 하단 `## Project-specific rules`에 감지된 스택 기반 1–3 bullet 추가 (테스트 러너, 빌드 명령, lint 명령). 감지 실패 시 빈 채로.
   - `<repo>/CLAUDE.md`가 없으면: 새로 작성.
   - 있으면: **덮어쓰지 말 것.** 짧은 `## SDD Methodology` 섹션만 append (`This repo uses SDD v2; see .specs/ and plugin docs.`).

7. **Report:** 한 줄 요약.

## Output format

```
✓ .specs/ initialized at <path>
✓ .specs/config.yaml (verify commands: npm run lint, npm run typecheck, npm test)
✓ CLAUDE.md created (detected: TypeScript/Node)
```

## Constraints

- Never overwrite an existing `CLAUDE.md`.
- Never write outside the current working directory tree.
- Don't run `git init`. Assume the repo is already initialized.
- `.specs/config.yaml`은 한 번만 생성. 이미 있으면 건드리지 말 것.

## When to use

✅ Use:
- New repo, never had SDD before
- Existing repo, wants to adopt SDD v2

❌ Don't use:
- 이미 `.specs/`가 있는 repo (덮어쓰지 않음)
- 기존 sdd v1에서 마이그레이션이 필요한 경우 (별도 마이그레이션 가이드 참조 — 추후 추가 예정)
