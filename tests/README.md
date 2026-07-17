# TedToolkit skill evals

Regression tests for marketplace skills. Each scenario builds a throwaway fixture, runs the skill via headless `codex exec`, and checks deterministic assertions against the produced files and the model's printed output.

## Setup

Python 3.13+ and one dependency:

```powershell
winget install -e --id Python.Python.3.13
py -3.13 -m pip install --upgrade pip pyyaml
```

`npx`, `git`, and a `bash` (Git for Windows is fine — the runner finds it even if `bash` isn't on PATH) must be installed. The merge evals also need the **.NET 10 SDK** for their Release-build gate.

## Running

```powershell
py -3.13 tests/run_evals.py                               # every eval
py -3.13 tests/run_evals.py generate-commit-message      # one skill
py -3.13 tests/run_evals.py --filter "conflict"          # scenarios whose name contains "conflict"
py -3.13 tests/run_evals.py --keep                       # keep work dirs to inspect on failure
py -3.13 tests/run_evals.py --judge                      # also LLM-judge the rubric points
py -3.13 tests/run_evals.py --plugin tedtoolkit-annotations annotation-skills
py -3.13 tests/run_evals.py --plugin tedtoolkit-roslynhelper compose-roslyn-source
```

Each scenario prints PASS/FAIL with per-assertion detail, wall-clock, and cost. A full run also writes `results.json` + `results.md` under `tests/.results/<timestamp>/`. Exit code is 0 only if every scenario passed.

> Each scenario is a real Codex invocation that costs tokens and takes ~30s–3min (merge scenarios run a build). The runner is sequential.

## How a run works

For each scenario the runner:

1. makes a temp work dir and copies the eval's sibling files (the `setup_fixture.sh`, stubs) into it;
2. runs `setup.commands` there via bash to build the fixture;
3. prepends `<workdir>/.binstub` and Git's tool dirs to `PATH`, and applies `setup.env`;
4. runs `claude -p "<prompt>" --plugin-dir plugins/tedtoolkit-shared --permission-mode bypassPermissions --output-format json` from the work dir (no `--bare` — it suppresses login);
5. checks the scenario's assertions and records the result;
6. cleans up the work dir and any `cleanup_globs` (paths the fixture had to create outside it).

The selected plugin is loaded (`tedtoolkit-shared` by default), so a scenario passes only if the
right skill both triggers and does the job.

## eval.yaml schema

```yaml
config: { max_parallel_scenarios: 1, max_parallel_runs: 1 }   # informational
scenarios:
  - name: "Human-readable scenario name"
    prompt: "What the user types."
    setup:
      copy_test_files: true
      commands: ["bash setup_fixture.sh <scenario>"]
      env: {}
      cleanup_globs: []
      cleanup_commands: []
    assertions:
      - { type: exit_success }
      - { type: file_exists,        path: "Feature.cs" }
      - { type: file_contains,      path: "*.cs", value: "Foo" }
      - { type: file_not_contains,  path: "Geometry.cs", value: "<<<<<<<" }
      - { type: output_contains,    value: "feat" }
      - { type: command, run: "git status --porcelain", stdout_empty: true }
    rubric:
      - "A criterion a human (or the --judge pass) checks."
    timeout: 360
```

### Assertion types

| type | fields | passes when |
|------|--------|-------------|
| `exit_success` | — | the `claude` process exited 0 |
| `file_exists` | `path` | a file matching the glob exists in the work dir |
| `file_contains` | `path`, `value` | some matching file contains the substring |
| `file_not_contains` | `path`, `value` | no matching file contains it |
| `output_contains` | `value` | the model's final text contains it |
| `output_not_contains` | `value` | the model's final text does not |
| `command` | `run`, `expect_exit?`=0, `stdout_contains?`, `stdout_not_contains?`, `stdout_empty?` | the bash command meets all stated checks |

## Layout

```
tests/
├── README.md
├── run_evals.py
└── tedtoolkit-shared/
    ├── generate-commit-message/   eval.yaml + setup_fixture.sh
    ├── merge-default-branch/      eval.yaml + setup_fixture.sh
    ├── run-fix/                   eval.yaml + setup_fixture.sh
    └── tunit-unit-testing/        eval.yaml + setup_fixture.sh
```

## Notes per skill

- **generate-commit-message** — hermetic git fixture; baseline is tagged `eval-base` so assertions count new commits with `git rev-list --count eval-base..HEAD`. Covers the atomic split and the "message-only, don't commit" intent.
- **merge-default-branch** — hermetic git fixture with a bare `origin` and a diverged default branch; asserts the merge happened, conflicts resolved keeping both sides, and a green Release build.
- **run-fix** — hermetic project fixture that exercises the diagnose-fix-verify loop against a local failing .NET target.
- **tunit-unit-testing** — hermetic TUnit-style fixture with a stubbed `dotnet` that records the command the agent chose, so the eval can catch accidental `dotnet test` usage without depending on NuGet or real test execution.
