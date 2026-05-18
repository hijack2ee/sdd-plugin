---
name: sdd-new
description: Draft a feature's three spec docs (requirements/design/tasks) and initialize manifest.yaml. Use after sdd-from-figma/sdd-from-text/sdd-to-issue/sdd-branch, or as a standalone entry point. Supports --approve mode to pass the approval gate. Trigger phrases - "spec the feature", "draft the spec", "/sdd-new", "/sdd-new --approve".
---

# sdd-new

Draft (or refine) the three spec docs for a feature, manage manifest, and gate the approval step.

## Two modes

| Mode | Trigger | What it does |
|---|---|---|
| Draft (default) | `/sdd-new` | Creates/updates `requirements.md`, `design.md`, `tasks.md`, `manifest.yaml`. Sets `status: drafting`, `approved: false`. |
| Approve | `/sdd-new --approve` | Computes `spec_hash`, sets `approved: true`, `approved_at: <today>`, `status: approved`. Doesn't change spec contents. |

## Inputs (gather what's missing in ≤2 questions)

- **Feature name** — kebab-case, ≤30 chars. If `.specs/CURRENT` is set and feature folder exists, use that.
- **Intent** — 1–2 sentences. If `manifest.source` was filled by sdd-from-figma/sdd-from-text, use that as starting context and don't re-ask.

## Preconditions

- `.specs/` exists. If not, run `sdd-init` and stop.
- `<repo>` is the working directory (or worktree path).

## Process — Draft mode

1. **Find/create feature folder:**
   - If user gave a name: use `.specs/<name>/`. Create if missing.
   - Else read `.specs/CURRENT`. If empty, ask for name.

2. **Read existing manifest** if present (sdd-from-* may have seeded it). Merge new info into it.

3. **Copy templates** from this skill's `templates/` directory (relative to this SKILL.md):
   - `requirements.md.tmpl` → `.specs/<name>/requirements.md` (if missing)
   - `design.md.tmpl` → `.specs/<name>/design.md` (if missing)
   - `tasks.md.tmpl` → `.specs/<name>/tasks.md` (if missing)
   - `manifest.yaml.tmpl` → `.specs/<name>/manifest.yaml` (if missing — sdd-from-* usually creates it)

4. **Substitute placeholders**: `<feature-name>` → name, `<date>` → today's ISO date.

5. **Draft real content** (이게 CLI보다 나은 이유):
   - `requirements.md`:
     - `## Background`: 사용자 인풋 + (있다면) figma context로 1–2단락
     - `## Goals` / `## Non-goals`: 1–3개씩
     - `## User stories`: 1–3개
     - `## Acceptance criteria`: 2–4개. 불확실한 건 `[?]` 표시. 사용자가 검토하며 다듬게 둘 것.
   - `design.md`:
     - `## Overview`: 1단락
     - `## Architecture`: 가능하면 텍스트 다이어그램 한 컷
     - `## Affected modules / files`: 추정 파일 목록
     - `## Alternatives considered`: 1–2개 (없으면 빈 table)
     - `## Decisions`: 빈 채로 (구현 중 누적)
   - `tasks.md`:
     - `## Tasks`: requirements/design을 보고 5–15개 task 도출. 각 task에 `[refs: ACx, design#<섹션>]` 필수.
     - **테스트 task를 항상 1개 이상 포함** (구현 task와 분리).

6. **Update manifest.yaml**:
   - `feature`, `created` (없으면 오늘), `updated_at`: 오늘
   - `status: drafting`, `last_skill: sdd-new`
   - `approved: false`
   - `progress.total_tasks`: tasks.md 파싱 결과
   - `source.kind`: 기존 값 유지 (sdd-from-*가 채운 것)

7. **Update `.specs/CURRENT`** → 이 feature.

8. **Report**:
   - 생성/갱신된 파일 목록
   - drafted된 acceptance criteria 수, task 수 (불확실 `[?]` 표시 수도)
   - **명시적 안내**: "검토 후 `/sdd-new --approve`로 다음 단계로 진행하거나, `/sdd-revise`로 수정하세요."

## Process — Approve mode (`--approve`)

1. **Find feature** (CURRENT 또는 인자).

2. **Read manifest.** `status`가 `drafting`이 아니면:
   - `approved` → 이미 통과, 한 줄 안내하고 stop.
   - 그 외 → 거부 (현재 status를 알려주고 사람에게 결정 맡김).

3. **Validate spec docs**:
   - requirements.md에 acceptance criteria ≥ 1개 있는지 (없으면 거부)
   - tasks.md에 task ≥ 1개 있는지 (없으면 거부)
   - `[?]` 항목 있으면 경고하되 사용자가 ack하면 통과

4. **Compute spec_hash**:
   - `sha256(requirements.md + design.md)` (파일 내용을 그대로 concat 후 해시)
   - manifest에 기록

5. **Update manifest**:
   - `status: approved`
   - `approved: true`, `approved_at: <today>`
   - `spec_hash: <hash>`
   - `last_skill: sdd-new`
   - `updated_at: <today>`

6. **Report**:
   - "✓ approved. /sdd-implement로 진행하세요."

## Output format (draft)

```
✓ .specs/add-search/ scaffolded
  - requirements.md (3 AC, 1 marked [?])
  - design.md (overview + 1 alternative)
  - tasks.md (8 tasks, 1 test task)
  - manifest.yaml (status: drafting)

active feature: add-search

검토 후 /sdd-new --approve 로 게이트 통과, /sdd-revise 로 수정 가능합니다.
```

## Output format (approve)

```
✓ approved: add-search
  spec_hash: sha256:9f2c...
  status: drafting → approved

다음: /sdd-implement
```

## Constraints

- 첫 draft에서 acceptance criteria 4개 이상은 금지 (사용자가 다듬을 여지).
- 불확실한 건 `[?]`로 솔직히 표시.
- 코드를 작성하지 말 것. 이 skill은 spec까지만.
- gh issue는 만들지 않음 (sdd-to-issue 책임).
- branch는 만들지 않음 (sdd-branch 책임).

## When to use

✅ Use:
- sdd-from-figma/sdd-from-text/sdd-branch 이후 spec 본격 작성할 때
- 진입 skill 없이 사용자가 직접 feature를 명세하고 싶을 때
- spec 검토 후 approval gate를 통과시킬 때 (`--approve`)

❌ Don't use:
- 진행 중 spec 변경 → `sdd-revise`
- 코드 시작 → `sdd-implement`
