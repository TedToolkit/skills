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

Resolve the installed plugin root only from a runtime-provided location. Use
`TEDTOOLKIT_PLUGIN_ROOT` in Codex or `CLAUDE_PLUGIN_ROOT` in Claude Code; if neither is available,
stop instead of guessing a cache or checkout path. On Bash, pass the full message to the canonical
helper through a quoted heredoc:

```sh
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${TEDTOOLKIT_PLUGIN_ROOT:?plugin root unavailable}}"
bash "$PLUGIN_ROOT/scripts/commit_group.sh" <files...> <<'MSG'
<full message>
MSG
```

On Windows PowerShell, use the packaged launcher beside that canonical helper. It locates Git Bash
without requiring `bash` on `PATH`, forwards the same explicit path arguments and UTF-8 standard
input, and returns the canonical helper's exit status:

```powershell
$pluginRoot = $env:TEDTOOLKIT_PLUGIN_ROOT
if (-not $pluginRoot) { throw 'plugin root unavailable' }
@'
<full message>
'@ | & "$pluginRoot\scripts\commit_group.ps1" <files...>
```

The script builds the commit in a temporary index, commits exactly the supplied literal paths, then
advances only those paths in the real index. It preserves every out-of-group staged and unstaged
entry on success; if staging, commit creation, or final index synchronization fails, it restores the
original index and removes any commit created by that invocation without resetting worktree bytes.
Do not reimplement either helper inline. A missing plugin root, launcher, canonical script, or Git
Bash runtime is a non-mutating failure. Verify the created commit and the complete remaining Git
state after every invocation.
