
# sdd-from-text

진입점: 텍스트 설명에서 feature 초안을 만든다. Figma가 없을 때.

## Inputs

- **Description** — paste된 텍스트. bug report, feature request, slack thread, issue body 등 무엇이든.
- (optional) **Feature name** — 사용자가 직접 지정 가능. 없으면 추론.
- (optional) **Kind hint** — "bug" / "feature" / "refactor" 등. branch type 선택에 영향.

## Preconditions

- `.specs/` 디렉터리 존재 (없으면 `/sdd-init` 안내).

## Process

1. **Parse the description:**
   - 문제 진술 vs 요청된 행동 분리
   - bug report 패턴 ("X 했을 때 Y 됨" → 재현/기대/실제) 인식
   - feature request 패턴 ("X 하고 싶다") 인식

2. **Infer feature name:**
   - 핵심 명사·동사로 kebab-case 이름 추출 (예: "stale cache 문제" → `fix-stale-cache`)
   - 사용자에게 한 줄 확인.

3. **Infer kind** (사용자가 안 줬으면):
   - 동사: fix → bug, add → feature, refactor → refactor
   - branch prefix 결정에 사용 (sdd-branch가 참고)

4. **Check folder collision** (sdd-from-figma와 동일 처리).

5. **Extract requirements draft:**
   - bug 패턴이면:
     - `## Background`: 재현 시나리오 + 기대/실제 동작
     - `## Goals`: "버그 X 수정"
     - `## Acceptance criteria`: "Y 조건에서 X가 발생하지 않는다" 형태로 1–3개
   - feature 패턴이면:
     - `## Background`: 원래 텍스트 요약
     - `## Goals`: 사용자가 얻을 가치
     - `## User stories`: 1–3개
     - `## Acceptance criteria`: 2–4개. 불확실한 건 `[?]`

6. **Create `.specs/<feature>/` 폴더.**

7. **Write `manifest.yaml`:**
   - `feature`, `created`, `updated_at`
   - `status: drafting`
   - `last_skill: sdd-from-text`
   - `source.kind: text`
   - `source.text`: 원본 텍스트 (최대 2000자, 길면 truncate)

8. **Write `requirements.md`** (위 추출 결과로).

9. **design.md, tasks.md는 만들지 않는다.** sdd-new가 채움.

10. **Update `.specs/CURRENT`.**

11. **Hand off:**
    ```
    ✓ .specs/<feature>/ scaffolded from text
      - manifest.yaml (source: text, kind: bug/feature/...)
      - requirements.md (2 AC, 1 marked [?])

    inferred:
      name: fix-stale-cache
      kind: bug   ← branch는 fix/<#>-fix-stale-cache 가 됨

    next: /sdd-to-issue   (gh issue 생성)
         /sdd-branch     (worktree)
         /sdd-new         (design.md + tasks.md 채우고 spec 마무리)
    ```

## Output format (text too short)

```
⚠ 입력 텍스트가 너무 짧아 추론이 어렵습니다.

다음 중 하나를 알려주세요:
- 더 자세한 설명
- 직접 feature name
- 핵심 acceptance criterion 1개
```

## Constraints

- design.md / tasks.md는 만들지 말 것.
- 추론한 AC가 원본 텍스트에 명시되지 않은 부분이면 반드시 `[?]`.
- 원본 텍스트는 manifest.source.text에 보존 (감사 추적용).
- gh issue 생성하지 말 것.

## When to use

✅ Use:
- bug report, slack 스레드, 회의 노트에서 출발
- figma 없이 백엔드/CLI/data 작업 시작
- 기존 GitHub issue body를 그대로 paste해서 시작

❌ Don't use:
- Figma URL이 있다면 → `/sdd-from-figma` (더 풍부한 컨텍스트)
- 이미 .specs/<feature>/가 있다면 → `/sdd-new` 또는 `/sdd-revise`
