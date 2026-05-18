
# sdd-from-figma

진입점: Figma URL에서 feature 초안을 만든다.

## Inputs

- **Figma URL** — `figma.com/design/<fileKey>/<fileName>?node-id=<nodeId>` 형식
- (optional) **Feature name** — 사용자가 직접 지정 가능. 없으면 figma context에서 추론.

## Preconditions

- `.specs/` 디렉터리 존재 (없으면 `/sdd-init` 안내).
- Figma MCP 서버 연결됨 (`mcp__plugin_figma_figma__*` 도구 사용 가능).

## Process

1. **Parse the URL:**
   - `figma.com/design/:fileKey/:fileName?node-id=:nodeId` → `fileKey`, `nodeId` 추출
   - `nodeId`의 `-`를 `:`로 치환 (예: `14988-326243` → `14988:326243`)
   - branch URL (`/branch/<branchKey>/`) 처리

2. **Read Figma context:**
   - `mcp__plugin_figma_figma__get_design_context(file_key, node_id)` — 디자인 메타, 컴포넌트, 텍스트
   - `mcp__plugin_figma_figma__get_screenshot(file_key, node_id)` — 시각 컨텍스트
   - 필요시 `get_metadata`, `get_variable_defs`

3. **Infer feature name:**
   - figma 노드/페이지 이름을 kebab-case로 변환
   - 사용자에게 한 줄 확인: "feature name으로 `<inferred>` 어떠세요? 다른 이름 원하시면 알려주세요."
   - kebab-case, ≤30 chars 검증

4. **Check folder collision:**
   - `.specs/<feature>/`가 이미 존재하면 한 줄 안내 + 사용자 결정 (재사용 / 다른 이름).

5. **Extract requirements draft from design context:**
   - **What's on the screen?** — 주요 UI 컴포넌트, 텍스트, 상호작용
   - **What can the user do?** — 버튼/입력의 동작 추정
   - **Data shown** — 표시되는 데이터의 형태/출처 (추정)
   - **States** — empty/loading/error 상태가 figma에 있다면 캡처
   - 이를 기반으로 user stories와 AC 초안 생성

6. **Create `.specs/<feature>/` 폴더.**

7. **Write `manifest.yaml`** (template에서 복사 후 채움):
   - `feature`, `created`, `updated_at` (오늘)
   - `status: drafting`
   - `last_skill: sdd-from-figma`
   - `source.kind: figma`
   - `source.figma.file_key`, `source.figma.node_id`

8. **Write `requirements.md`** (template에서 복사 후 채움):
   - `## Background`: figma URL 링크 + 한 단락 요약 ("이 디자인은 X 화면을 다룬다...")
   - `## Goals`: figma에서 추론 가능한 1–2개
   - `## User stories`: 1–3개 추정
   - `## Acceptance criteria`: 2–4개. 불확실한 건 `[?]`
   - `## Open questions`: figma만 봐서는 답이 안 나오는 질문들 명시

9. **design.md, tasks.md는 만들지 않는다.** sdd-new가 채움.

10. **Update `.specs/CURRENT`** → feature name.

11. **Hand off**:
    ```
    ✓ .specs/<feature>/ scaffolded from figma
      - manifest.yaml (source: figma)
      - requirements.md (3 AC, 2 marked [?])

    figma URL: https://www.figma.com/design/.../?node-id=14988-326243

    next: /sdd-to-issue   (gh issue 생성)
         /sdd-branch     (worktree)
         /sdd-new         (design.md + tasks.md 채우고 spec 마무리)
    ```

## Auto-chain note

이 skill은 다음 단계를 자동으로 호출하지 않는다. 사용자가 명시적으로 `/sdd-to-issue` 등을 호출해야 한다. (각 단계가 사용자 확인을 받을 가치가 있기 때문.)

## Output format (URL parse fail)

```
✗ Figma URL 파싱 실패

기대 형식:
  https://www.figma.com/design/<fileKey>/<fileName>?node-id=<nodeId>
  https://www.figma.com/design/<fileKey>/branch/<branchKey>/<fileName>?node-id=<nodeId>

다시 입력해주세요.
```

## Output format (collision)

```
⚠ .specs/<feature>/가 이미 존재합니다.

옵션:
  a) 이 폴더에 figma 정보만 추가 (manifest 갱신)
  b) 다른 feature name 사용

어느 쪽으로 진행할까요?
```

## Constraints

- design.md / tasks.md는 만들지 말 것 (sdd-new가 담당).
- Figma에 의존하는 정보(예: 색상 토큰)는 design.md에 옮기지 말고 sdd-new에서 처리.
- 불확실한 AC는 솔직히 `[?]`로. 추측해서 confident하게 쓰지 말 것.
- gh issue 생성하지 말 것 (sdd-to-issue 책임).

## When to use

✅ Use:
- Figma 디자인이 있고 그걸 구현해야 할 때
- 디자인이 있되 백엔드 변경도 필요한 경우도 OK (백엔드는 sdd-new에서 추가)

❌ Don't use:
- Figma URL이 없는 경우 → `/sdd-from-text`
- 이미 진행 중인 feature를 수정하는 경우 → `/sdd-revise`
