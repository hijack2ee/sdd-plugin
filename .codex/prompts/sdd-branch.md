
# sdd-branch

issue 번호와 feature name으로 worktree를 만든다. naming convention을 강제하고 bootstrap을 실행한다.

## Inputs

- **Feature name** — if omitted, read `.specs/CURRENT`.
- **--branch-only** — worktree 대신 일반 branch (`git checkout -b`). 기본은 worktree.
- **--type <prefix>** — branch prefix를 명시 (feat/fix/docs/...). 없으면 manifest.source.kind 또는 추론.
- **--base <branch>** — base branch override. 기본은 `.specs/config.yaml`의 `github.base_branch`.

## Preconditions

1. `.specs/<feature>/manifest.yaml` 존재.
2. `manifest.issue != null` (branch name에 필요).
3. Working tree clean (uncommitted changes 없음).
4. `git` 사용 가능, repo 내부.

## Process

1. **Find feature** (인자 또는 CURRENT).

2. **Read manifest + `.specs/config.yaml`.**

3. **Resolve type (branch prefix):**
   - `--type` 인자 우선
   - 없으면 manifest.source.kind 매핑:
     - `bug` (sdd-from-text의 kind hint) → `fix`
     - 그 외 → `feat`
   - `config.github.allowed_branch_prefixes`에 없는 prefix면 거부.

4. **Compose branch name:** `<type>/<issue#>-<feature>`
   - 예: `feat/142-add-search`, `fix/156-stale-cache`

5. **Sync base branch:**
   - base 결정 (`--base` 인자 → config → 기본 `main`)
   - `git fetch origin`
   - `git pull origin <base>` (현재 위치가 base인 경우만; 아니면 fetch만)

6. **Idempotency check:**
   - 같은 branch가 이미 존재?
     - 같은 worktree path도 존재 → "이미 setup됨, `cd <path>`만 하세요" 안내 후 종료.
     - branch만 있고 worktree 없음 → 사용자에게 옵션 (checkout / 다른 이름).

7. **Create:**

   **Worktree mode (기본):**
   - path 결정:
     - `config.worktree.base_path` 있으면 그 아래
     - 없으면 `<repo-parent>/<repo-name>-<issue#>-<feature>/`
   - 명령: `git worktree add <path> -b <branch> <base>`

   **Branch mode (`--branch-only`):**
   - `git checkout -b <branch> <base>`

8. **Run bootstrap** (worktree mode에서만, 그리고 config.bootstrap.enabled이고 script 존재 시):
   - `bash <repo>/.specs/bootstrap.sh <new-worktree-path>`
   - exit code 0 아니면 경고하되 계속 진행 (사용자가 수동 처리).

9. **Update manifest:**
   - `branch`: branch name
   - `base_branch`: 실제 사용된 base
   - `worktree`: worktree 경로 (branch mode면 null)
   - `last_skill: sdd-branch`
   - `updated_at: <today>`

10. **Report:**
    ```
    ✓ pulled main (up to date)
    ✓ worktree: ../app-142-add-search/
    ✓ branch:   feat/142-add-search
    ✓ bootstrap: .specs/bootstrap.sh exited 0

    manifest: branch + worktree 기록됨

    next:
      cd ../app-142-add-search/
      /sdd-new   (spec 본격 작성)
    ```

## Output format (branch mode)

```
✓ pulled main
✓ branch: feat/142-add-search (created from main)

manifest: branch 기록됨

next: /sdd-new
```

## Output format (idempotent reuse)

```
✓ 이미 setup됨:
  worktree: ../app-142-add-search/
  branch:   feat/142-add-search

cd ../app-142-add-search/ 후 작업 계속하세요.
```

## Output format (rejected — invalid prefix)

```
✗ branch prefix '<type>'는 허용되지 않습니다.

allowed: feat, fix, docs, style, refactor, test, chore
(.specs/config.yaml의 github.allowed_branch_prefixes에서 변경 가능)

--type <prefix>로 다시 시도하거나 config을 수정하세요.
```

## Constraints

- branch name format `<type>/<issue#>-<slug>` 엄격 강제.
- 기존 branch/worktree를 덮어쓰지 말 것.
- bootstrap 실패는 skill 실패가 아님 (경고만 — 수동 처리 가능).
- worktree 경로가 이미 다른 용도로 사용 중이면 (예: 다른 branch checkout) 거부.
- `git pull`은 base branch에서만. 다른 branch에서 강제로 pull 금지.

## When to use

✅ Use:
- /sdd-to-issue 직후
- 여러 feature를 병렬로 작업하고 싶을 때 (각 feature 별 worktree)

❌ Don't use:
- issue가 없는 경우 → `/sdd-to-issue` 먼저
- 이미 branch/worktree에서 작업 중인 경우 (idempotent하게 안전하지만 보통 불필요)
