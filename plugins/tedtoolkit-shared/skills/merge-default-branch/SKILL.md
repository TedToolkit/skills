---
name: merge-default-branch
description: >-
  Integrate the remote default branch into the current branch while preserving local work,
  reconciling both sides of every conflict, and gating the merge commit on the repository's Release
  verification. Use when the user asks to merge, sync, or update from origin's default branch.
---

# Merge Default Branch

**Integrate** both histories: preserve local work, explain each conflict resolution, and commit only
a verified merged tree. Execute the steps in order.

This skill owns pre-merge preservation and the merge commit. Invoke `generate-commit-message` only
for a separate commit task requested by the user.

## 1. Preserve local work

Inspect `git status --porcelain -uall`. A clean tree advances to fetch. For a dirty tree, inspect
every tracked and untracked change, read [commit-style.md](../../references/commit-style.md), and
commit atomic local groups with `commit_group.sh`. The merge request authorizes these local
pre-merge commits.

Complete when the worktree is clean and every pre-existing change is represented by a verified local
commit.

## 2. Fetch and resolve the default branch

```sh
git fetch origin --prune
DEF="$(bash "${CLAUDE_PLUGIN_ROOT}"/scripts/default_branch.sh)"
```

Complete when `origin/$DEF` resolves to the fetched default-branch tip.

## 3. Open the merge without committing

```sh
git merge --no-ff --no-commit "origin/$DEF"
```

`Already up to date` is a terminal result. Otherwise keep the merge uncommitted until verification
passes.

## 4. Reconcile every conflict

List conflicts:

```sh
git diff --name-only --diff-filter=U
```

For each conflicted file:

1. Read both marker regions and the relevant history:
   ```sh
   git log --oneline --left-right HEAD...MERGE_HEAD -- <file>
   git log -1 --format='%h %s%n%b' <commit>
   ```
2. State the intent of `ours` and `theirs`.
3. Compose a result that preserves both behaviors. Remove one behavior only when evidence shows it
   is superseded, and record that evidence.
4. Stage the resolved file and record: each side's intent, retained behavior, and any removal with
   rationale.

Complete when the unmerged-file list is empty, conflict markers are absent, and every conflicted
file has a complete resolution record.

## 5. Gate the merge commit on verification

Use the repository's authoritative build orchestration. When `Build/Build.csproj` exists, run:

```sh
dotnet build -c Debug
dotnet build -c Release
dotnet run --project Build/Build.csproj
```

Otherwise run the root solution or relevant project in Release:

```sh
dotnet build -c Release <target>
```

Fix merge-introduced integration failures, stage those fixes, and restart the full gate. A failure
that remains after root-cause investigation leaves the merge resolved but uncommitted and is
reported with its diagnostics.

Complete when every authoritative command passes on the staged merged tree.

## 6. Commit and report the merge

Read the commit-style reference and create the merge commit through a quoted heredoc:

```sh
git commit -F - <<'MSG'
🔀 merge(<scope>): merge latest origin/<DEF> changes

<Why the merge was needed and how conflicts were reconciled.>
MSG
```

For every conflict, include the recorded intent and resolution in the body. Verify the commit, then
report its hash and subject, conflict resolutions, integration fixes, and every verification result.

## 7. Gate the push

Ask whether to publish the local merge and wait for explicit approval:

```sh
git push
# or, without an upstream
git push -u origin HEAD
```

Use a normal fast-forward push. Without approval, report that the verified merge remains local.
