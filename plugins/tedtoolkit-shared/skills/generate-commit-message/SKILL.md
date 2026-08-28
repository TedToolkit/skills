---
name: generate-commit-message
description: >-
  Compose atomic gitmoji + Conventional Commit messages from the complete worktree. Use when the
  user wants commit-message text, logical commit grouping, or authorized local commits.
---

# Generate Commit Message

Build an **atomic** plan from the whole worktree, bind it to the inspected Git state, show its exact
messages and paths, then commit only when the request authorizes local commits. Read
[commit-style.md](../../references/commit-style.md) before drafting messages.

Leave pre-merge and merge commits to `merge-default-branch`. Leave a verified repair commit to
`run-fix`.

## Select the mode

- **Commit:** the user asked to commit the changes. Complete the whole process and offer to push.
- **Message only:** the user asked for message text or a proposed grouping. Leave the index and
  history unchanged.

## 1. Gather the complete change set

Run:

```sh
git --no-optional-locks status --porcelain=v2 -z -uall
git diff HEAD --stat
git diff HEAD
git diff --cached --binary
git ls-files --stage
```

Read both `XY` status columns so staged and unstaged edits to the same path remain one changed file.
Keep both sides of a rename together. A general commit request authorizes inspection of tracked
diffs, but untracked content is sensitive by default. Inventory only each untracked path and its
status metadata, then name the path and obtain explicit authorization before reading it. Ask
separately whether that path may be included unless the same response explicitly authorizes both
inspection and inclusion. Do not print untracked content while requesting authorization.

Complete when every staged, unstaged, renamed, deleted, and authorized untracked path is accounted
for. An unapproved untracked path is a path-specific blocker, not permission to inspect, stage, or
commit it. When blocked, the response must explicitly state that the general commit request does
not authorize reading untracked content, list each blocked path without its contents, and ask
whether each exact path may be inspected and included. A clean tree is a terminal result: report it
and stop.

## 2. Form atomic groups

Partition files by concern, using the fewest groups that remain independently reviewable and
revertible:

- Keep an implementation with its tests, generated output with its source, and a signature change
  with its affected callers.
- Separate unrelated features, dependency bumps, pure refactors, documentation, and formatting.
- Assign each path to exactly one group. When a file mixes concerns, place it with the dominant
  concern and disclose the smaller one in the body.
- Order foundations before their consumers.

Complete when every changed path appears exactly once and each group has one logical purpose.

## 3. Draft and present the plan

Draft one complete message per group using the commit-style reference. Present every group in commit
order with its exact path list and full subject and body.

Bind the plan to the current HEAD, complete path inventory, tracked worktree diff, index entry
identities and modes, and the content identity of each authorized untracked path. Record deletions
explicitly. Immediately before the first commit, repeat that inventory: a changed planned path or
any added path invalidates the plan and requires reinspection and presentation. After each approved
group commits, treat only that group and the resulting HEAD as the expected transition; recheck all
remaining path and index identities before committing the next group.

- In message-only mode, this presentation completes the task.
- In commit mode, an explicit request to commit is approval after the plan is shown. Otherwise wait
  for explicit approval.

## 4. Commit the approved groups

For each group, run `commit_group.sh` exactly as specified in the commit-style reference. After each
commit, verify its paths and message. The helper commits from an isolated temporary index and
advances only the approved group in the real index; do not reset, stash, or otherwise normalize the
remaining state. Complete when every approved group has one commit and `git status` accounts for all
remaining changes, including unchanged out-of-group staged and unstaged entries.

After the last commit, run `git --no-optional-locks status --porcelain=v1 -uall`. In the final
response, use this evidence-complete shape for every created commit:

- `<short hash>` — `<subject>`
- Paths: every committed path
- Body: the complete committed body, including what changed and why

Then explicitly report whether the worktree is clean; otherwise list every remaining path and
status.

## 5. Gate the push

Commits remain local. Ask whether to push and wait for explicit approval.

```sh
git push
# or, when the branch has no upstream
git push -u origin HEAD
```

Use a normal push. Report the remote ref after success; when approval is withheld, report that the
commits remain local.
