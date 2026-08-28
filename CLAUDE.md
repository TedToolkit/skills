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
  - `default_branch.sh` and `commit_group.sh` are the canonical Git mechanics for Bash.
  - Their paired `.ps1` launchers locate packaged scripts through `$PSScriptRoot` and Git Bash without requiring `bash` on `PATH`; they do not duplicate Git policy.
  - Skills link every packaged helper explicitly and resolve it relative to the loaded `SKILL.md` or
    reference source path supplied by the host. Missing linked resources are a stop condition; never
    require an installation-root variable, guess a cache version, or search a developer checkout.
- `plugins/<plugin>/hooks/hooks.json` + scripts — plugin-level hooks
- `tests/` — custom Python eval harness (see Testing)

The marketplace exposes five plugins: `tedtoolkit-shared`, `tedtoolkit-annotations`, `tedtoolkit-roslynhelper`, `tedtoolkit-project-development`, and `tedtoolkit-resume`. `tedtoolkit-shared` contains reusable Git and .NET skills including `fix-csharp-diagnostics`, `generate-commit-message`, `merge-default-branch`, `run-fix`, and `tunit-testing`; `tunit-unit-testing` is a deprecated explicit compatibility alias. Project-development uses `design-change`, `continue-change`, `implement-change`, and `orchestrate-work-items`; `change-design` and `implement-change-tdd` are deprecated explicit aliases. `tedtoolkit-resume` contains factual resume creation, revision, review, job-matching, and interview-question workflows.

## SKILL.md conventions

Frontmatter fields in use: `name`, `description` (a long when-to-use paragraph with trigger phrases — this drives skill matching), `allowed-tools` (CSV with bash wildcards like `Bash(git:*)`), `user_invocable: true`.

Body is imperative and **gate-first**: investigate read-only → show the user the proposed boundary
or draft → obtain explicit approval → write project artifacts. An explicit request to create or
update a named workflow record authorizes that Draft write, but never authorizes production changes
or a Draft-to-approved status transition. Temporary multi-agent control state may be persisted only
after the user requests persistent orchestration or approves its creation. Preserve these gates when
editing skills; they are the core safety design, not boilerplate.

## House conventions (apply when a skill generates output)

- **Commits**: gitmoji + Conventional Commits. Atomic — one logical change per commit.
- C# edits trigger `tedtoolkit-shared/hooks/dotnet-format-changed.sh` (best-effort `dotnet format`).
- **Human delivery records**: change designs and work items are concise implementation handoffs for
  human developers, not agent transcripts. Keep current approved truth in the main document and
  keep orchestration history or machine state in stable markers or separate control artifacts. A
  new developer should understand the why, changed and preserved behavior, scope, constraints,
  proof, and next delivery within five minutes. The authoritative rules live in
  `plugins/tedtoolkit-project-development/references/workflow/change-development-workflow.md`.
- **Repository-local TedToolkit state**: use the tracked `.tedtoolkit/` namespace and the lifecycle
  in `plugins/tedtoolkit-project-development/references/orchestration/tool-state-layout.md`. New
  skills must not invent another preparation, worktree, run-state, cache, log, or temporary-state
  root.

## Testing

Bespoke headless harness (not pytest/jest): each scenario runs a skill via `codex exec` inside a throwaway fixture, then checks deterministic assertions. Scenarios live in `tests/<plugin>/<skill>/eval.yaml` (+ `setup_fixture.sh`). The current git skills are fully offline (local bare-remote repos).

Requires: Python 3.10+ with `pyyaml`, Codex CLI, `git`, `bash`, and .NET 10 SDK (for `merge-default-branch` Release-build gates).

```powershell
py -3.10 tests/test_run_evals.py                          # harness self-tests; no API
py -3.10 tests/run_evals.py                               # all scenarios
py -3.10 tests/run_evals.py generate-commit-message      # one skill
py -3.10 tests/run_evals.py --filter conflict            # scenarios matching substring
py -3.10 tests/run_evals.py --tier static                 # all selected offline scenarios; no API
py -3.10 tests/run_evals.py --tier smoke                  # static plus explicit reviewed smoke scenarios
py -3.10 tests/run_evals.py --keep                       # keep work dirs for debugging
py -3.10 tests/run_evals.py --judge                      # rubric failures fail the scenario
py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development design-change
py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts  # no API
```

Without `--plugin`, evals are grouped by `tests/<plugin>/` and each matching plugin is loaded in
turn. Codex scenarios cost real API spend and take ~30s–3min; `mode: static` scenarios make no model
call for their execution. Results archive to `tests/.results/<timestamp>-<run-id>/`. See `tests/README.md`
for the assertion schema before adding scenarios.

### Harness gotchas (Windows headless eval)

- Do not add an interactive Codex option to the headless `codex exec` invocation.
- Do not redirect `USERPROFILE`/`HOME` for the Codex subprocess — it can break authentication.
- `python` may be the WindowsApps stub — use `py -3.10`. `bash` isn't always on PATH; Git's is at `C:\Program Files\Git\bin\bash.exe` (the runner locates it).
- Force UTF-8 on every subprocess + stdout when assertions inspect non-ASCII output. `grep -P` needs `LC_ALL=C.UTF-8` (Git bash leaves `LANG` empty).
