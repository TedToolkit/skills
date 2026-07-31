---
name: generate-commit-message
description: >-
  Compose atomic gitmoji + Conventional Commit messages from the complete worktree. Use when the
  user wants commit-message text, logical commit grouping, or authorized local commits.
---

# Generate Commit Message

Build an **atomic** plan from the whole worktree, show its exact messages and paths, then commit only
when the request authorizes local commits. Read
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
git status --porcelain -uall
git diff HEAD --stat
git diff HEAD
```

Read both `XY` status columns so staged and unstaged edits to the same path remain one changed file.
Keep both sides of a rename together. Inspect every untracked text file; use metadata and focused
inspection for binary or large files.

Complete when every staged, unstaged, renamed, deleted, and untracked path is accounted for. A clean
tree is a terminal result: report it and stop.

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
order with its exact paths and full message.

- In message-only mode, this presentation completes the task.
- In commit mode, an explicit request to commit is approval after the plan is shown. Otherwise wait
  for explicit approval.

## 4. Commit the approved groups

For each group, run `commit_group.sh` exactly as specified in the commit-style reference. After each
commit, verify its paths and message. Complete when every approved group has one commit and
`git status` accounts for all remaining changes.

Report the short hash and subject for every created commit.

## 5. Gate the push

Commits remain local. Ask whether to push and wait for explicit approval.

```sh
git push
# or, when the branch has no upstream
git push -u origin HEAD
```

Use a normal push. Report the remote ref after success; when approval is withheld, report that the
commits remain local.
