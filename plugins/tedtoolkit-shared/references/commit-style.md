# Commit style

Read this reference before drafting a commit message.

Use one logical, independently reviewable and revertible change per commit. Keep implementation and
its tests together; separate unrelated features, dependency bumps, pure refactors, documentation,
and formatting.

Format every message as:

```text
<gitmoji(s)> <type>(<scope>): <subject>

<body>

[optional footer]
```

- Use one or two actual gitmoji characters that match the change.
- Choose `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`,
  `revert`, or `merge`.
- Use an optional short noun for scope.
- Write an imperative, concise subject without a trailing period and align it with repository
  history.
- Explain the whole change and its reason in one or two concise paragraphs; add bullets only for
  details that improve review.
- Mark a breaking change with `!` after type or scope and add
  `BREAKING CHANGE: <change and impact>`.

Output plain text without placeholder tags. Use the repository's established language where one
exists.

When committing through `commit_group.sh`, pass the full message through a quoted heredoc:

```sh
bash "${CLAUDE_PLUGIN_ROOT}"/scripts/commit_group.sh <files...> <<'MSG'
<full message>
MSG
```

The script clears the index, stages exactly the supplied paths, and commits them. Verify the created
commit and the remaining worktree after every invocation.

