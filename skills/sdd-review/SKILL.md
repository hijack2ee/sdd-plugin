---
name: sdd-review
description: Self-review the diff against the spec — checks if changed files appear in design, if acceptance criteria are reflected in code, and surfaces gaps. Recommends sdd-revise where spec is out of sync. Trigger phrases - "/sdd-review", "review my changes", "check spec alignment", "self review".
---

# sdd-review

diff와 spec의 정합성을 점검한다. **거부하지 않고** 발견 사항을 보고만 — 사용자가 sdd-revise 또는 sdd-ship으로 진행 결정.

## Inputs

- **Feature name** — if omitted, read `.specs/CURRENT`.

## Preconditions

1. `.specs/<feature>/manifest.yaml` 존재.
2. `manifest.branch`가 현재 git branch와 일치 (다르면 경고 + 사용자 ack).
3. base branch와 비교할 commit이 ≥ 1개 존재.

## Process

1. **Find feature** (인자 또는 CURRENT).

2. **Read manifest + 3개 spec.**

3. **Bump status**: `manifest.status: reviewing`, `last_skill: sdd-review`, `updated_at: <today>`.

4. **Collect diff data:**
   ```bash
   git diff <base>...HEAD --name-only           # 변경 파일
   git diff <base>...HEAD --stat                # 라인 수
   git log <base>..HEAD --oneline               # commit history
   ```

5. **Cross-check against design.md `## Affected modules`:**
   - **In code, not in spec** (변경 파일 ↛ design): 누락 가능성. spec이 out of date.
   - **In spec, not in code** (design에 적힌 파일 ↛ 변경): 작업 잔존 또는 스코프 변경.
   - **Match**: 정상.

6. **Cross-check commits against tasks.md:**
   - per-task commit 컨벤션 (`T<N>` in commit message)이면 T 번호 매칭.
   - 체크된 task인데 매칭 commit 없음 → 의심
   - commit은 있는데 task 미체크 → 잊고 미체크

7. **Cross-check acceptance criteria against code:**
   - 각 AC에 대해 grep 또는 휴리스틱으로 코드 흔적 찾기:
     - AC 키워드 → 파일/함수 이름에 등장하는지
     - test 파일에 해당 시나리오 있는지
   - 코드 흔적 없는 AC는 "미구현 의심"으로 표시. (확실히 단정 짓지 말 것.)

8. **Cross-check new dependencies / API calls against design:**
   - `package.json`, `requirements.txt`, `go.mod` 등에 새 의존성 추가됐는가?
   - design.md에 언급 있는가? 없으면 누락.
   - 새 외부 HTTP/서비스 호출이 코드에 추가됐는가? design에 데이터 흐름 반영됐는가?

9. **Cross-check decisions:**
   - `git log`의 commit 메시지에서 "switched to", "instead of", "rejected" 류 단서 → decisions log에 없으면 보강 권장.

10. **Categorize findings:**
    | Category | 의미 | 권장 action |
    |---|---|---|
    | `spec-missing` | 코드에 있는데 spec에 없음 | `/sdd-revise`로 design.md/decisions 보강 |
    | `code-missing` | spec에 있는데 코드에 없음 | task 잔존 또는 스코프 변경 → revise/implement |
    | `decision-undocumented` | 코드 단서 있는 비자명 결정이 decisions에 없음 | revise로 decisions 한 줄 추가 |
    | `ac-unverified` | AC가 코드 흔적이 약함 | 직접 확인, 부족하면 테스트 추가 (task) |

11. **Do NOT modify spec.** 이 skill은 보고만. 수정은 사용자 또는 sdd-revise가.

12. **Report:**

## Output format

```
✓ /sdd-review: add-search

base: main (5 commits ahead, 12 files changed, +482 -73)

────────────────────────────────────────
spec-missing (2):
  - src/utils/highlight.ts — design.md ## Affected modules에 없음
  - package.json: +fuse.js — design.md에 fuse 언급 없음

decision-undocumented (1):
  - commit fcd8c6e "switched from substring to fuse.js" — design.md ## Decisions에 없음

ac-unverified (1):
  - AC3 "Matches highlighted in the rendered list" — Highlight.tsx에 흔적 약함, 테스트 없음

code-missing (0):
  (clean)
────────────────────────────────────────

권장:
  1) /sdd-revise — fuse.js 추가 + decision 1줄 추가 + highlight.ts를 design ## Affected modules에 추가
  2) AC3 검증할 test 한 개 추가
  3) 그 후 /sdd-verify → /sdd-ship
```

## Output format (clean)

```
✓ /sdd-review: add-search

base: main (5 commits ahead, 8 files changed, +312 -45)

────────────────────────────────────────
all clean — spec ↔ code in sync
  ✓ 모든 변경 파일이 design ## Affected modules에 등록됨
  ✓ 모든 체크된 task가 commit과 매칭됨
  ✓ AC 모두 코드 흔적 확인됨
  ✓ 새 의존성 없음
────────────────────────────────────────

next: /sdd-ship
```

## Heuristics — keep them honest

- AC 키워드 매칭은 약한 신호. `ac-unverified`를 단정짓지 말 것. "흔적 약함"으로 표현.
- per-task commit이 강제되지 않은 repo (`commit_policy: squash`)에선 task ↔ commit 매핑 생략 가능.
- design.md `## Affected modules`가 와일드카드(`src/utils/*`)면 매칭 시 prefix 매칭 허용.

## Constraints

- spec/manifest를 수정하지 말 것. 보고만.
- 거부하지 말 것. 사용자가 어떤 결과를 보고도 sdd-ship으로 진행할지 결정.
- 발견 사항이 0이면 즉시 sdd-ship 권장.
- 코드를 작성하지 말 것.

## When to use

✅ Use:
- /sdd-verify pass 후, /sdd-ship 전
- 큰 변경을 한 후 spec과의 정합성 확신이 필요할 때
- 휴식 후 작업 복귀 시 "어디까지 했지" 점검용

❌ Don't use:
- 코드를 안 짜고 review만 (무의미)
- spec 자체를 다시 쓰는 경우 → `/sdd-revise`
