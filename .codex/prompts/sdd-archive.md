
# sdd-archive

머지 후 정리. spec을 `.specs/archive/<YYYY-MM>/`로 옮기고 git/issue 부산물을 정리.

## Inputs

- **Feature name** — if omitted, read `.specs/CURRENT`.

## Preconditions

1. `.specs/<feature>/manifest.yaml` exists.
2. `manifest.pr != null` (PR이 한 번이라도 만들어졌어야 함).
3. PR이 실제로 merge됨: `gh pr view <pr> --json state -q .state == "MERGED"`.
   - 다르면 경고하고 사용자 결정 요청.

## Process

1. **Find feature** (인자 또는 CURRENT).

2. **Read manifest.**

3. **Check PR merge state:**
   ```bash
   gh pr view <manifest.pr> --json state,mergedAt -q '{state, mergedAt}'
   ```
   - state가 `MERGED`가 아니면: 경고 + 사용자 ack 요청.
   - state가 `CLOSED` (merge 없이 close)면: 별도 경고 — 보통 archive하면 안 됨.

4. **Close issue** (있으면):
   ```bash
   gh issue close <manifest.issue> --comment "Shipped in #<manifest.pr>"
   ```
   - parent_issue가 있는 sub-task면 parent는 건드리지 말 것.
   - 이미 closed면 skip.

5. **Worktree cleanup** (있는 경우):
   - `manifest.worktree != null`:
     - 사용자에게 확인 후 `git worktree remove <path>` 실행.
     - destructive하니 한 번 묻는다 (`--force`로 자동 진행 가능).

6. **Branch cleanup**:
   - merge됐으므로 local branch 삭제 안전: `git branch -d <manifest.branch>`
   - remote는 보통 GitHub의 "delete branch on merge" 설정으로 처리. 명시적으로 안 지움.

7. **Archive directory**:
   - 현재 월 기준 path: `.specs/archive/<YYYY-MM>/<feature>/`
   - `git mv .specs/<feature>/ .specs/archive/<YYYY-MM>/<feature>/`
     (git repo 아니면 `mv`)
   - 폴더가 이미 archive에 같은 이름으로 존재하면 (드물지만): suffix `-<short-sha>` 추가.

8. **Update manifest** (옮긴 후):
   - `status: archived`
   - `archived_at: <today>` (manifest 스키마에 없으면 추가)
   - `last_skill: sdd-archive`
   - `updated_at: <today>`

9. **Clear `.specs/CURRENT`** if pointed to this feature.

10. **Retro prompt** (선택):
    - 사용자에게: "한 줄 retro를 `retro.md`에 남기시겠어요? (skip 가능)"
    - yes면 `.specs/archive/<YYYY-MM>/<feature>/retro.md` 생성:
      ```markdown
      # Retro — <feature>

      > Shipped: <PR merge date>
      > Archived: <today>

      <한 줄 회고>
      ```
    - 또는 `design.md ## Decisions`에 `(retro) <한 줄>: <date>` append 형태도 가능 (사용자 선택).

11. **Report**:

```
✓ PR #168 merged at 2026-05-18T10:23Z
✓ closed issue #142
✓ removed worktree: ../app-142-add-search/
✓ deleted local branch: feat/142-add-search
✓ archived: .specs/archive/2026-05/add-search/
✓ manifest: status → archived
✓ CURRENT cleared

(선택) 한 줄 retro를 남기시겠어요? [y/n]
```

## Output format (PR not merged)

```
⚠ PR #168 state: OPEN (not merged yet)

archive를 진행하려면 ack 필요. 일반적으로 merge 후 archive합니다.
계속하시겠어요? [y/n]
```

## Output format (PR closed without merge)

```
⚠ PR #168 was CLOSED without merging.

이 feature를 archive하면 spec이 .specs/archive/로 옮겨집니다.
포기한 작업이라면 진행, 아니라면 PR을 reopen하거나 새 PR을 만드세요.
계속하시겠어요? [y/n]
```

## Constraints

- PR 상태가 MERGED가 아니면 한 번 경고하고 사용자 ack 받기.
- `git worktree remove`, `git branch -d`는 destructive — 사용자 confirm 기본.
- archive 폴더 충돌 시 절대 덮어쓰지 말 것 (suffix 추가).
- `## Decisions`의 기존 항목을 절대 건드리지 말 것. retro는 별도 파일이거나 append.
- parent issue는 close하지 말 것 (sub-task만).

## When to use

✅ Use:
- PR이 merge됐을 때
- 포기한 feature를 archive할 때 (별도 confirm)

❌ Don't use:
- PR이 아직 review 중일 때
- 같은 worktree에서 다음 feature를 시작하려는 경우 (archive 전에 새 feature 시작 비추 — `.specs/CURRENT`가 모호해짐)
