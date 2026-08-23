# TedToolkit skill evals

Regression tests for marketplace skills. Each scenario builds a throwaway fixture, runs the skill via headless `codex exec`, and checks deterministic assertions against the produced files and the model's printed output.

## Setup

Python 3.10+ and one dependency:

```powershell
winget install -e --id Python.Python.3.10
py -3.10 -m pip install --upgrade pip pyyaml
```

The installed `codex` CLI is used directly. Set `CODEX_BIN` when it is not on `PATH`; the runner
never downloads Codex through npm. `git` and a `bash` (Git for Windows is fine — the runner finds it
even if `bash` isn't on PATH) must be installed. The merge evals also need the **.NET 10 SDK** for
their Release-build gate.

## Running

```powershell
py -3.10 tests/test_run_evals.py                          # harness self-tests; no model/API call
py -3.10 tests/run_evals.py                               # every eval
py -3.10 tests/run_evals.py generate-commit-message      # one skill
py -3.10 tests/run_evals.py --filter "conflict"          # scenarios whose name contains "conflict"
py -3.10 tests/run_evals.py --keep                       # keep work dirs to inspect on failure
py -3.10 tests/run_evals.py --judge                      # rubric failures also fail the run
py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development design-change
py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts
py -3.10 tests/run_evals.py --plugin tedtoolkit-annotations annotation-skills
py -3.10 tests/run_evals.py --plugin tedtoolkit-roslynhelper compose-roslyn-source
```

Without `--plugin`, the runner groups `tests/<plugin>/` scenarios and loads each matching plugin in
turn. With `--plugin`, it discovers scenarios only below that plugin's test directory. Static
execution such as `workflow-scripts` invokes no model and incurs no API cost. Other scenarios make
real Codex calls; `--judge` judges any present rubric with Codex and any failed or invalid grade
fails the scenario.

Each scenario prints PASS/FAIL with per-assertion detail and wall-clock. A full run also writes
`results.json` + `results.md` under a unique `tests/.results/<timestamp>-<run-id>/` directory. Exit
code is 0 only if every scenario passed.

> Codex scenarios cost tokens and take ~30s–3min (merge scenarios run a build). The runner is sequential.

## How a run works

For each scenario the runner:

1. groups scenarios by plugin, loads that plugin, then makes a temp work dir and copies the eval's
   sibling files (the `setup_fixture.sh`, stubs) into it;
2. runs `setup.commands` there via bash to build the fixture;
3. prepends `<workdir>/.binstub` and Git's tool dirs to `PATH`, and applies `setup.env`;
4. runs `codex exec` with the selected locally installed marketplace plugin from the work dir, or
   stops after setup commands for a `mode: static` scenario;
5. checks the scenario's assertions and records the result;
6. cleans up the work dir and any `cleanup_globs` (paths the fixture had to create outside it).

The plugin matching the scenario's `tests/<plugin>/` directory is loaded, so a scenario passes only
if the right skill both triggers and does the job.

## eval.yaml schema

```yaml
config: { max_parallel_scenarios: 1, max_parallel_runs: 1 }   # informational
scenarios:
  - name: "Human-readable scenario name"
    mode: "codex"                    # default; use "static" for an offline command suite
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
    timeout: 360                         # one scenario execution deadline
```

For `mode: static`, `prompt` is optional and setup output becomes the assertion output. `timeout` is
one execution deadline shared by setup, Codex, deterministic assertions, and optional judging;
individual command assertions default to 60 seconds and cannot exceed the remaining scenario time.
Static scenarios are discovered and reported like skill
evals but do not install a plugin or call Codex when they are the only selected scenarios and have
no rubric requested through `--judge`.

### Assertion types

| type | fields | passes when |
|------|--------|-------------|
| `exit_success` | — | the Codex or static scenario exited 0 |
| `file_exists` | `path` | a file matching the glob exists in the work dir |
| `file_contains` | `path`, `value` | some matching file contains the substring |
| `file_not_contains` | `path`, `value`, `allow_no_match?`=false | at least one file matches and none contains it; set `allow_no_match` only when absence of the file is intentional |
| `output_contains` | `value` | the model's final text contains it |
| `output_not_contains` | `value` | the model's final text does not |
| `output_regex` | `pattern` | the model's final text matches the Python regular expression |
| `output_contains_file` | `path` | the model's final text contains the non-empty content of a matching fixture file |
| `command` | `run`, `expect_exit?`=0, `stdout_contains?`, `stdout_not_contains?`, `stdout_empty?`, `timeout?`=60 | the bounded bash command meets all stated checks |

All globs are rooted at the fixture and recurse only when `**` is explicit: `*.cs` checks the
fixture root, while `**/*.cs` checks every level. Setup and command strings may use `${WORKDIR}`,
`${REAL_HOME}`, and `${REPO_ROOT}`.

## Layout

```
tests/
├── README.md
├── run_evals.py
├── tedtoolkit-project-development/
│   ├── design-change/              risk-scaled change contract design
│   ├── change-design/              deprecated-alias eval
│   ├── implement-change/           change-kind implementation loops
│   ├── implement-change-tdd/       deprecated-alias eval
│   ├── orchestrate-work-items/     multi-item Controlled orchestration
│   ├── review-code/                adversarial correctness review
│   ├── review-tests/               adversarial test-adequacy review
│   ├── verify-implementation/      candidate-bound execution review
│   ├── review-implementation/      risk routing and synthesis review
│   └── workflow-scripts/           offline validator/scheduler regression suite
└── tedtoolkit-shared/
    ├── generate-commit-message/   eval.yaml + setup_fixture.sh
    ├── merge-default-branch/      eval.yaml + setup_fixture.sh
    ├── run-fix/                   eval.yaml + setup_fixture.sh
    ├── tunit-testing/             eval.yaml + setup_fixture.sh
    └── tunit-unit-testing/        deprecated-alias eval
```

## Notes per skill

- **generate-commit-message** — hermetic git fixture; baseline is tagged `eval-base` so assertions count new commits with `git rev-list --count eval-base..HEAD`. Covers the atomic split and the "message-only, don't commit" intent.
- **merge-default-branch** — hermetic git fixture with a bare `origin` and a diverged default branch; asserts the merge happened, conflicts resolved keeping both sides, and a green Release build.
- **run-fix** — hermetic project fixture that exercises the diagnose-fix-verify loop against a local failing .NET target.
- **tunit-testing** — hermetic TUnit-style fixture with a stubbed `dotnet` that records the command the agent chose, so the eval can confirm the documented repository command is preserved without depending on NuGet or real test execution.
- **tunit-unit-testing** — one compatibility scenario proving the deprecated explicit name routes to `tunit-testing` without duplicating its rules.
- **change-design / implement-change-tdd** — compatibility scenarios proving explicit legacy names route to `design-change` / `implement-change` without duplicating workflow rules.
- **review-code / review-tests / verify-implementation / review-implementation** — separate fixtures for code correctness, weak or missing proof, zero-test execution, reviewer independence, and contradiction handling.
