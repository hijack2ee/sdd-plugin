
# sdd-verify

implementation 직후 lint/type-check/test를 게이트로 돌린다. 결과는 `manifest.ci`에 기록되어 `sdd-ship`이 검사한다.

## Inputs

- **Feature name** — if omitted, read `.specs/CURRENT`.
- **--commands "<cmd1>;<cmd2>"** — config을 무시하고 직접 명령 지정 (디버깅용).

## Preconditions

1. `.specs/<feature>/manifest.yaml` 존재.
2. **Working tree clean** — uncommitted changes가 있으면 거부 (verify는 commit된 상태를 검증). 사용자에게 "변경분을 commit하거나 stash 후 재시도" 안내.
3. `.specs/config.yaml`의 `verify.commands`가 비어 있지 않음 (비어 있으면 자동 pass + 한 줄 경고).

## Process

1. **Find feature** (인자 또는 CURRENT).

2. **Read manifest + .specs/config.yaml.**

3. **Bump status**: `manifest.status: verifying`, `last_skill: sdd-verify`, `updated_at: <today>`.

4. **Resolve commands:**
   - `--commands` 인자 우선
   - 없으면 `config.verify.commands` 사용
   - 빈 배열이면: `ci.status: pass`로 즉시 통과 + 경고 ("verify commands가 없어 자동 통과 — config를 확인하세요").

5. **Execute commands in order:**
   - 각 명령을 working directory 루트에서 실행
   - stdout/stderr는 표시 (사용자가 실패 원인 즉시 볼 수 있게)
   - 하나라도 exit code != 0이면 **즉시 중단** (이후 명령 skip)
   - 각 명령의 결과 (성공/실패, duration, exit code) 수집

6. **Record result in manifest.ci:**
   ```yaml
   ci:
     status: pass | fail
     last_run: 2026-05-18T10:23:00Z
     commit: <HEAD SHA>
     duration_seconds: 47
     commands:
       - { cmd: "npm run lint",      status: pass, exit: 0, duration: 8 }
       - { cmd: "npm run typecheck", status: pass, exit: 0, duration: 12 }
       - { cmd: "npm test",          status: fail, exit: 1, duration: 27 }
   ```

7. **If fail**: append a blocker to `manifest.blockers`:
   ```yaml
   blockers:
     - task: T?       # 가능하면 실패 출력에서 추론, 안 되면 null
       kind: verify_failure
       detail: "<실패한 명령 + 핵심 에러 한 줄>"
       added_at: <today>
   ```

8. **If pass**: blockers에서 `kind: verify_failure` 항목 제거 (해결됨).

9. **Bump status:**
   - pass → `manifest.status: reviewing` (다음은 sdd-review 권장)
   - fail → `manifest.status: implementing` (다시 코딩 또는 revise)

10. **Report:**

## Output format (pass)

```
✓ verify: pass (47s, commit a1b2c3d)

  ✓ npm run lint        (8s)
  ✓ npm run typecheck   (12s)
  ✓ npm test            (27s)  43 passed

manifest.ci: pass
status: implementing → verifying → reviewing

next: /sdd-review   (권장)   또는 /sdd-ship
```

## Output format (fail)

```
✗ verify: fail (27s, commit a1b2c3d)

  ✓ npm run lint        (8s)
  ✓ npm run typecheck   (12s)
  ✗ npm test            (7s)  exit 1

  실패 요약:
    auth.test.ts:42 — expected 200, got 401
    auth.test.ts:58 — TypeError: cannot read 'token' of undefined

manifest.ci: fail
manifest.blockers: +1 (verify_failure)
status: verifying → implementing

next:
  - 단순 버그면: 수정 → commit → /sdd-verify 재실행
  - 설계 가정 문제면: /sdd-revise → /sdd-implement → /sdd-verify
```

## Output format (dirty working tree)

```
✗ /sdd-verify 거부됨

uncommitted changes:
  M src/auth.ts
  ?? src/new-file.ts

verify는 commit된 상태를 검증합니다.
다음 중 하나로 진행하세요:
  - git commit (변경분 확정)
  - git stash (임시 보관)
```

## Constraints

- 명령을 병렬 실행하지 말 것 (순서가 의미 있음 — lint 실패 시 test까지 갈 필요 없음).
- 각 명령 출력은 그대로 사용자에게 표시 (verify 도구가 해석을 가로채지 않음).
- 실패 시에도 manifest는 항상 갱신 (recovery 정보).
- 한 번 pass면 commit이 추가되기 전까지 다시 돌릴 필요 없음 (`ci.commit`이 SHA와 일치하면 sdd-ship이 통과시킴).
- `--commands` override는 디버깅용. 자주 사용한다면 config.yaml을 수정하는 게 맞다.

## When to use

✅ Use:
- /sdd-implement에서 task 다 끝낸 후
- spec drift 의심될 때 sanity check
- PR 만들기 전 마지막 확인

❌ Don't use:
- 코드를 안 짜고 verify만 돌리는 건 무의미 (이전 verify 결과가 manifest에 있다면 그걸 봐)
- WIP 상태 (working tree dirty)에서 — 거부됨
