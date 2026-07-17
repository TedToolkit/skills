---
name: generate-commit-message
description: >-
  Use when a user wants commit messages, atomic commit grouping, or commits for the current git
  changes, including message-only requests and workflows that follow the repo's gitmoji +
  Conventional Commits style.
---

# Generate Commit Message

Split the working changes into **atomic commits** (one logical change each) and
commit them in the project's house style — gitmoji + Conventional Commits. You gather the diffs, decide the groups, and write the
messages all in this session, **show the user the full plan first**, then a
bundled script does the mechanical git work once they're happy.

The working directory is already the repo root — **do not `cd`**.

## Two modes — read the intent first

- **Commit (default for this skill).** The user wants their changes committed
  ("commit my changes", "split into separate commits"). Run the full
  workflow: gather → group → show the plan → commit → offer to push.
- **Message only.** The user just wants to *see* a message and isn't asking to
  commit ("what would a good commit message be for this?"). Do steps 1–3, show
  the messages, and **stop** — don't stage or commit. Committing silently when
  the user only wanted text would be a nasty surprise.

## 1. Gather all the changes

Build a complete picture before grouping — you can't make a sound split from a
partial view of the tree.

```sh
git status --porcelain -uall   # staged, unstaged, and every untracked file
git diff HEAD --stat           # quick map: which files changed and how much
git diff HEAD                  # the full tracked diff (staged + unstaged)
```

**Read the `git status --porcelain` columns.** Each line is `XY <path>`, where `X`
is the index (staged) state and `Y` the worktree (unstaged) state: `M` modified,
`A` added, `D` deleted, `R old -> new` renamed, `??` untracked. A file can show in
**both** columns (` M`, `MM`, `AM`) — staged *and* unstaged edits; treat it as one
changed file. For a rename, keep the **old and new path together** — one change.

`git diff HEAD` does **not** include untracked (`??`) files. Use the **`Read`** tool
on each untracked file to understand what it adds. For binary/large files, don't
dump them — summarize from `--stat` and the status code.

If there are no changes at all, say so and stop.

## 2. Group into atomic changes (file-level)

Partition the changed **files** so each group is one logical, self-contained
change. Group by *concern*, not by file type. Aim for the **fewest** groups where
each is independently reviewable and revertable — the point of atomic commits is a
history you can bisect and revert one change at a time.

**Same commit (one concern):** an implementation and its test(s); a caller and
callee changed for one behavior; a type/function and the call sites updated to
match; a config/schema change and the code depending on it; a rename's old + new
path; generated output and its source.

**Separate commits (different concerns):** two unrelated features; a dependency
bump on its own; a pure refactor separate from a feature riding alongside; an
unrelated docs/typo fix; a formatting-only change never mixed into a feature.

**Constraints:** a file belongs to exactly one group — if one file genuinely mixes
two concerns, put it with its **dominant** one and note the minor change in that
commit's body. **Order** the commits so foundational/independent changes come
first, dependents after. If everything is genuinely one concern, one commit is fine.

## 3. Commit message format

Every message — one per group — follows these rules:

```
<gitmoji(s)> <type>(<scope>): <subject>

<body>

[optional footer]
```

1. **Gitmoji:** 1–2 total, matching the change type. Output the **actual emoji
   character** (e.g. `🎨`, `✨`), never the shortcode (`:art:`) or entity
   (`&#x1f3a8;`). Reference list:
   https://raw.githubusercontent.com/carloscuesta/gitmoji/refs/heads/master/packages/gitmojis/src/gitmojis.json
2. **type:** one of `feat, fix, docs, style, refactor, perf, test, build, ci,
   chore, revert`.
3. **scope:** optional short noun (e.g. `ui`, `api`).
4. **subject:** imperative, concise, no trailing period, and consistent with the repository's established history.
5. **body:**
   - Explain **what** and **why**, not "how".
   - Start with 1–2 concise paragraphs summarizing the *entire* change and its
     purpose, so someone reading `git log` understands it without the diff.
   - Then bullet the specific changes / notable details. Keep it as short as it can
     be while still informative.
6. **Breaking changes:** append `!` after the type/scope and add a footer:
   `BREAKING CHANGE: <what changed and its impact>`.

Output plain text only — no surrounding `<gitmoji>` / `<body>` / `[footer]` tags.

## 4. Show the plan and let the user review

Before committing anything, **always** lay out the full plan — for every planned
commit, its complete message and the exact files it includes, in commit order.
Seeing the real messages and groupings is what lets the user catch a wrong split or
reword a message, so don't shortcut this into a vague summary.

- **Message-only mode** → you're done here. Nothing is staged or committed.
- **Commit mode** → let the user confirm or ask for changes; only proceed once
  they're happy. A request that already authorized committing ("commit my changes"
  ) is pre-approval — proceed without a second round-trip; an obvious
  single-group commit needs no objection to continue.

## 5. Commit each group

For each group, in order, run the bundled script — the group's files as arguments,
the commit message piped in on stdin via a **quoted** heredoc:

```sh
bash "${CLAUDE_PLUGIN_ROOT}"/scripts/commit_group.sh <files...> <<'MSG'
<full commit message — subject, blank line, body>
MSG
```

The script clears the index, stages only that group, and commits it — so each
commit contains only its files. The message goes straight through stdin, so there
are no temp files and no quoting traps for emoji, non-ASCII text, or characters like
`` ` `` and `$`. The quoted `<<'MSG'` delimiter is what guarantees the message is
taken literally; don't drop the quotes.

After committing, report the resulting short hashes + subjects, and note anything
left uncommitted (`git status`). To undo, `git reset --soft HEAD~N` keeps the
changes staged.

## 6. Offer to push

Once **every** group is committed, the new commits live **locally only**. Ask the
user whether to publish them, e.g.:

> "All N commits are in (`<hash> <subject>`, …). Push the current branch to origin?"

**Do not push until the user approves.** Pushing is the one outward, hard-to-undo
step, and the user may want to review first — so it's gated, never automatic. (This
applies only in **Commit** mode; in **Message-only** mode nothing was committed, so
don't ask.)

- If they approve, push the current branch (a normal push, **never `--force`**):
  ```sh
  git push                      # if the branch already tracks an upstream
  git push -u origin HEAD       # if it has no upstream yet
  ```
  Then report the result (the remote ref, or the branch URL if git prints one).
- If they decline, stop and say the commits are local and ready to push later.

## Example

**A 2-group plan presented for review** (a new feature plus an unrelated docs fix):

```
Commit 1 — src/Feishu/Notifier.cs, src/Feishu/NotifierTests.cs
  ✨ feat(feishu): add test result notifier

  Add a notifier that publishes a short result summary after the run.

  - Add `Notifier` and its unit tests
  - Include error details on failure

Commit 2 — README.md
  📝 docs(readme): fix quickstart typo
```

The feature and its test ride together in commit 1; the unrelated README typo is
its own commit 2 — each independently revertable.
