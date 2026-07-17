---
name: merge-default-branch
description: >-
  Use when merging, syncing, or updating the current branch with the remote default branch,
  especially when local work must be preserved, conflicts may need careful resolution, and a green
  Release build is required before finishing.
---

# Merge Default Branch

Integrate the remote default branch (origin's `main`/`master`) into the current
branch **without losing work or shipping a broken tree**. The whole point is
discipline that's easy to skip by hand: local edits get committed before they
can tangle into the merge, conflicts get resolved by understanding *why* each
side changed the code (so no feature is silently dropped), and the build must
pass *before* the merge is ever committed.

The sequence is deliberately ordered. Don't reorder it — each step protects the
next.

## Workflow

### 1. Commit local work first

```sh
git status --porcelain -uall   # staged, unstaged, and every untracked file
```

If the tree is already clean, skip straight to step 2.

If the tree is **dirty**, commit it before merging. Merging on top of
uncommitted changes risks tangling your work into the merge commit or losing it
to a conflict, and it makes the merge impossible to review cleanly. Invoking a
merge already authorizes committing this local work, so no separate gate is
needed here.

Read the changes (`git diff HEAD` plus the `Read` tool on any untracked files),
then commit them in the house style — gitmoji + Conventional Commits with a
descriptive subject and a body explaining what and why. The local work is usually
one concern, so a single commit; split into separate commits only if it's clearly
unrelated changes. Commit each group with the bundled script — files as arguments,
the message piped in on a **quoted** heredoc (this passes emoji and non-ASCII text through
literally; don't drop the quotes):

```sh
bash "${CLAUDE_PLUGIN_ROOT}"/scripts/commit_group.sh <files...> <<'MSG'
<full commit message — subject, blank line, body>
MSG
```

Note the resulting commits, then continue to step 2.

### 2. Fetch

```sh
git fetch origin --prune
```

### 3. Resolve the default branch

```sh
DEF="$(bash "${CLAUDE_PLUGIN_ROOT}"/scripts/default_branch.sh)"   # e.g. main or master
```

The script reads what `origin/HEAD` points at (falling back to whichever of
`main`/`master` exists), so this works whether the project's trunk is `main`,
`master`, or something else.

### 4. Open the merge — but hold the commit

```sh
git merge --no-ff --no-commit "origin/$DEF"
```

- If git reports **"Already up to date"**, there is nothing to merge — say so and
  stop.
- `--no-commit` (with `--no-ff` to always create a real merge commit) applies the
  merge into the working tree and index but **pauses before committing**. That
  pause is what lets the build gate the commit (step 6) and lets you craft a
  proper message (step 7).

### 5. Resolve conflicts on a stronger model

First, list any conflicts:

```sh
git diff --name-only --diff-filter=U
```

If that's **empty**, there were no conflicts — skip straight to step 6.

If there *are* conflicts, resolve them carefully — this is the one step where a
careless choice silently deletes a feature the other side added, so give it your
full attention and read the file history rather than blindly accepting one side.
For **each** conflicted file (never just accept one side):

1. Read the conflict markers. `ours` (above `=======`) is the current branch,
   `HEAD`; `theirs` (below) is the incoming default branch, `MERGE_HEAD`.
2. Understand *why* each side touched the file — the commit messages say what
   each change was for:
   ```sh
   git log --oneline --left-right HEAD...MERGE_HEAD -- <file>
   git log -1 --format='%h %s%n%b' <commit>   # read messages that look relevant
   ```
   `<` marks commits only on your branch, `>` marks commits only on the default
   branch.
3. Edit the file to **integrate both sides**, keeping each side's behavior.
   Remove code only when one side genuinely supersedes the other (e.g. the same
   bug fixed two ways). When in doubt, keep both features and make them coexist.
4. Stage each resolved file: `git add <file>`.
5. **Record a structured summary** — per file: what each side changed, what was
   kept from each, and anything removed and why. That summary is the audit trail
   step 7's commit body and step 8's report are built from, so it must be
   complete.

Once every file is resolved, confirm no conflict markers remain
(`git diff --name-only --diff-filter=U` is now empty) and carry the summary
forward.

### 6. The build gate

Before committing the merge, prove the merged tree actually works. **Don't commit
a red tree** — a failing build here almost always means the merge re-introduced an
integration problem: duplicate members, a call site that drifted, a missing
`using`, an API that changed on one side.

First, check whether the repo carries a build-orchestration project:

```sh
ls Build/Build.csproj 2>/dev/null
```

**If `Build/Build.csproj` exists**, this repo defines "passing" as more than a bare
compile — that project encodes the team's real gate (tests, analyzers, packaging,
whatever they put there). Run all three checks, in this order:

```sh
dotnet build -c Debug                      # 1. Debug build
dotnet build -c Release                    # 2. Release build
dotnet run --project Build/Build.csproj    # 3. run the build project
```

Debug and Release aren't redundant — they diverge in real ways (Release-only
optimizations, `DefineConstants`, warnings-as-errors, conditional compilation), so
a tree can pass one and fail the other. Run Debug first because it's the quickest
way to surface plain compile errors, then Release, then the build project, which
is the slowest and most thorough. **All three must pass.** They're the bar because
*both* branches cleared all three before the merge — neither side brought in code
that fails them — so any failure now is damage the merge itself introduced, and
catching that is the entire point of this gate.

**If there's no `Build/Build.csproj`**, build the solution at the repo root
(`*.sln`) if there is one, otherwise the relevant project:

```sh
dotnet build -c Release
```

When a check fails, read the errors, fix them in the working tree, `git add` the
fixes, and re-run the checks **from the top** (a fix for Release can break Debug,
and the build project may depend on artifacts from the compiles). Iterate a few
times. If it still won't go green after a genuine effort, **stop and report**:
leave the merge resolved-but-uncommitted so the user can finish by hand, and
summarize the remaining errors. A broken merge commit is worse than an
unfinished one.

### 7. Commit the merge

Once the build is green, commit. Pipe the message via a **quoted** heredoc so
emoji, non-ASCII text, and characters like `` ` `` / `$` pass through literally:

```sh
git commit -F - <<'MSG'
🔀 merge(<scope>): merge latest origin/<DEF> changes

<Body: what changed upstream, why the merge was needed, and how any conflicts were reconciled.>

- 关键点（按需要列出）
MSG
```

The merge commit follows the house style (see **Merge commit message** below),
with the 🔀 gitmoji to mark a merge. When there were conflicts, the body is where
you record what you preserved and why — drawn from your step-5 resolution summary;
that's the audit trail a reviewer relies on.

### 8. Report

Tell the user: the merge commit's short hash and subject, which files conflicted
and how you resolved each (what you kept from each side), any fixes you made to
get the build green, and the final build result — naming each check that ran
(Debug, Release, and the build project when `Build/Build.csproj` is present).

### 9. Offer to push

The merge is committed **locally only** — nothing has left the machine yet. Ask
the user whether to publish it, e.g.:

> "The merge is committed locally (`<hash> <subject>`). Push the current branch to origin?"

**Do not push until the user approves.** Pushing is the one outward,
hard-to-undo step in this workflow, and the user may want to review the merge
first — so it's deliberately gated, never automatic.

- If they approve, push the current branch (a normal fast-forward push, **never
  `--force`**):
  ```sh
  git push                      # if the branch already tracks an upstream
  git push -u origin HEAD       # if it has no upstream yet
  ```
  Then report the result (the remote ref, or the branch URL if git prints one).
- If they decline, stop and say the merge is committed locally and ready to push
  later. That's a complete, valid end state — don't push anyway.

## Merge commit message

The pre-merge commits (step 1) follow the project's house style — gitmoji +
Conventional Commits with a descriptive subject. The **merge commit** in step 7 follows
that same house style, specialized for a merge:

```
<gitmoji(s)> <type>(<scope>): <subject>

<body>
```

1. **Gitmoji:** use `🔀` to mark the merge — the **actual emoji character**, never
   the shortcode (`:art:`) or HTML entity.
2. **type:** use `merge` to label it as such, or pick the type that fits.
3. **scope:** optional; the default branch name reads well (e.g. `merge(main)`).
4. **subject:** imperative, concise, no trailing period, and consistent with the repository's established history.
5. **body:** explain **what** and **why** — which upstream changes were merged and
   why. When there were conflicts, this is the audit trail: for each conflicted
   file, record each side's intent, how you integrated both, what was kept, and
   anything removed and why (drawn from your step-5 resolution summary). Lead with
   1–2 concise paragraphs, then bullet the notable points.

Output plain text only — no surrounding tags.

**Example — the merge commit** (default branch merged in, one conflict resolved):

```
🔀 merge(main): merge latest origin/main changes

Bring the latest upstream changes into the current branch and keep the branch in
sync. `Geometry.cs` conflicted because both sides added different geometry
methods, so the final resolution preserved both behaviors.

- Keep the branch's `Arc2.Length` and upstream's `Arc2.Bounds`
- Fast-forward the remaining files to the merged result
```
