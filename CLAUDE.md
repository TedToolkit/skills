# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## What this repo is

An Agent Skills marketplace (per [agentskills.io](https://agentskills.io)) — not an application. It packages reusable Codex skills as installable plugins. Install locally with `/plugin marketplace add ./path/to/skills`.

Both marketplace manifests must declare the same plugins: `.codex-plugin/marketplace.json` for Codex and `.claude-plugin/marketplace.json` for Claude Code. Their schemas differ and are not byte-identical.

## Layout

- `plugins/<plugin>/.codex-plugin/plugin.json` — Codex plugin manifest; its `name` must match the plugin directory and marketplace entry
- `plugins/<plugin>/plugin.json` — Claude Code compatibility manifest
- `plugins/<plugin>/skills/<skill-name>/SKILL.md` — one skill per directory; **`name:` frontmatter must equal the directory name** (kebab-case)
- `plugins/<plugin>/scripts/` — helpers shared across the plugin's skills; single source of truth for strict, deterministic mechanics so a skill never retypes them by hand.
  - `*.sh` — bash helpers for git logic (`default_branch.sh`, `commit_group.sh`); invoked via `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/<name>.sh`
  - `${CLAUDE_PLUGIN_ROOT}` is substituted inline in skill content. No per-skill copies to mirror.
- `plugins/<plugin>/hooks/hooks.json` + scripts — plugin-level hooks
- `tests/` — custom Python eval harness (see Testing)

The marketplace exposes four plugins: `tedtoolkit-shared`, `tedtoolkit-annotations`, `tedtoolkit-roslynhelper`, and `tedtoolkit-project-development`. `tedtoolkit-shared` contains five shared Git and .NET skills: `fix-csharp-diagnostics`, `generate-commit-message`, `merge-default-branch`, `run-fix`, and `tunit-unit-testing`.

## SKILL.md conventions

Frontmatter fields in use: `name`, `description` (a long when-to-use paragraph with trigger phrases — this drives skill matching), `allowed-tools` (CSV with bash wildcards like `Bash(git:*)`), `user_invocable: true`.

Body is imperative and **gate-first**: read-only investigation → show the user a plan/draft → explicit approval gate → only then write/commit. Preserve these confirmation gates when editing skills; they are the core safety design, not boilerplate.

## House conventions (apply when a skill generates output)

- **Commits**: gitmoji + Conventional Commits. Atomic — one logical change per commit.
- C# edits trigger `tedtoolkit-shared/hooks/dotnet-format-changed.sh` (best-effort `dotnet format`).

## Testing

Bespoke headless harness (not pytest/jest): each scenario runs a skill via `codex exec` inside a throwaway fixture, then checks deterministic assertions. Scenarios live in `tests/<plugin>/<skill>/eval.yaml` (+ `setup_fixture.sh`). The current git skills are fully offline (local bare-remote repos).

Requires: Python 3.13+ with `pyyaml`, Codex CLI, `git`, `bash`, and .NET 10 SDK (for `merge-default-branch` Release-build gates).

```powershell
py -3.13 tests/run_evals.py                               # all scenarios
py -3.13 tests/run_evals.py generate-commit-message      # one skill
py -3.13 tests/run_evals.py --filter conflict            # scenarios matching substring
py -3.13 tests/run_evals.py --keep                       # keep work dirs for debugging
py -3.13 tests/run_evals.py --judge                      # also grade qualitative rubric via LLM
```

Each run costs real API spend and ~30s–3min per scenario; results archive to `tests/.results/<timestamp>/`. See `tests/README.md` for the assertion schema before adding scenarios.

### Harness gotchas (Windows headless eval)

- Do not add an interactive Codex option to the headless `codex exec` invocation.
- Do not redirect `USERPROFILE`/`HOME` for the Codex subprocess — it can break authentication.
- `python` is the WindowsApps stub — use `py -3.13`. `bash` isn't on PATH; Git's is at `C:\Program Files\Git\bin\bash.exe` (the runner locates it).
- Force UTF-8 on every subprocess + stdout when assertions inspect non-ASCII output. `grep -P` needs `LC_ALL=C.UTF-8` (Git bash leaves `LANG` empty).
