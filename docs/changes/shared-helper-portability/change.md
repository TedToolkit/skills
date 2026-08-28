# Make shared Git helper launchers portable

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: bug-fix -->
<!-- change-status: in-progress -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

Make the shared Git helpers reliably executable from the installed `tedtoolkit-shared` plugin in
Codex on Windows and Claude Code in Bash. The baseline instructions at
`d3ddb70db54ba3d78a848e995b940f944a6cc7d6` require both `bash` on `PATH` and
`CLAUDE_PLUGIN_ROOT`, so a supported Windows Codex host can fail before the helper runs and the
skills may be tempted to duplicate safety-critical Git mechanics.

<!-- section: scope -->
## Scope and non-goals

- In scope: host-appropriate launchers for `default_branch`, `commit_group`, and the safety-critical
  `premerge_guard`; launcher discovery
  from the installed plugin location; shared-skill, commit-style reference, and repository guidance
  updates; offline Windows and Bash static smoke coverage.
- Non-goals: changing default-branch selection, remote-refresh behavior, commit-message style,
  staging/index rules, atomic grouping policy, merge behavior, or push authorization.
- Compatibility: Bash use remains supported without `CLAUDE_PLUGIN_ROOT`; the Windows route must
  not require `bash` to be present on `PATH`. Both routes retain the helpers' arguments, standard
  input, standard output, diagnostics, exit status, and Git effects.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | A shared skill invokes `default_branch` from its installed plugin | The documented invocation requires `bash` on `PATH` and `CLAUDE_PLUGIN_ROOT` | Codex Windows and Claude Bash can invoke a host-appropriate launcher from the actual plugin location without either shared assumption | The helper prints only the detected `origin` default-branch name on success and otherwise exits non-zero |
| OB-02 | A shared skill invokes `commit_group` from its installed plugin | The only documented route is a Bash script addressed through `CLAUDE_PLUGIN_ROOT` | Both hosts pass explicit path arguments and the complete literal message on standard input through an equivalent launcher contract | The helper clears the index, stages only the named paths, creates one commit, and reports its short hash and subject |
| OB-03 | Launcher discovery or invocation cannot be completed safely | Host setup can fail before the helper runs, with no common documented stop condition | The caller receives a non-zero result with an actionable diagnostic and stops without guessing a plugin root, mutating Git, or reimplementing the helper inline | Existing helper precondition failures remain failures and never widen the selected paths |
| OB-04 | `merge-default-branch` runs its mandatory clean-tree guard on Windows | Only the Bash entrypoint is packaged | A PowerShell launcher locates Git Bash and preserves the guard's exit/output contract | Dirty work remains a terminal metadata-only result and no fetch or merge occurs |

<!-- acceptance-case: AC-01 -->
### AC-01 — Detect the default branch on both supported hosts

```gherkin
Scenario: Invoke default_branch from the installed plugin
  Given an offline repository whose origin default branch is known and no CLAUDE_PLUGIN_ROOT value
  When the host-appropriate launcher is run from the plugin's actual location on Windows or Bash
  Then it exits successfully and prints exactly the same default-branch name on both hosts
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Commit one explicit group on both supported hosts

```gherkin
Scenario: Invoke commit_group with literal input
  Given an offline dirty repository with explicit target paths and unrelated index and worktree state
  When either host launcher receives those paths and a literal UTF-8 commit message on standard input
  Then it creates one equivalent commit containing only the named paths and preserves the established index contract
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Fail closed when safe launch is impossible

```gherkin
Scenario: Reject an unusable or invalid helper invocation
  Given a missing or ambiguous plugin location, unavailable required host runtime, or invalid helper arguments
  When a shared skill attempts to launch the helper
  Then it exits non-zero with a diagnostic and leaves Git history, index, and worktree unchanged
```

## Constraints and risks

- Treat each helper's baseline shell behavior as the compatibility oracle; portability must not
  introduce a second Git policy or silently route around a failed launcher.
- Skill and reference examples must describe one consistent host-selection and plugin-location
  contract without hard-coding a developer checkout or cache version.
- The main risk is semantic drift between launchers, especially stdin encoding, path quoting, exit
  propagation, and `commit_group` index effects. Static parity fixtures must make those differences
  observable.
- Escalate if implementation requires changing Git semantics or index ownership, a host-wide
  installation, a new external dependency, or a plugin packaging contract outside
  `tedtoolkit-shared`.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Implement from baseline `d3ddb70db54ba3d78a848e995b940f944a6cc7d6` after approval.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target area: one portable launcher contract under
  `plugins/tedtoolkit-shared/scripts/`, consumed consistently by the shared Git skills and guidance.
- Other start conditions: Windows PowerShell, Git for Windows, and a Bash environment are available
  to run the two offline smoke paths; neither smoke may inherit `CLAUDE_PLUGIN_ROOT`.
- Likely touchpoints (non-binding): both helper scripts and host launchers; `generate-commit-message`,
  `merge-default-branch`, and `run-fix`; `references/commit-style.md`; root `CLAUDE.md`; and a static
  helper-launcher eval group under `tests/tedtoolkit-shared/`.
- Private choices left open: shared implementation versus wrappers, launcher filenames, plugin-root
  discovery mechanics, fixture layout, and test-script decomposition, provided the observable
  contracts and packaging remain identical.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=integration -->
<!-- primary-proof: AC-02 purpose=regression shape=integration -->
<!-- primary-proof: AC-03 purpose=boundary shape=integration -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Windows and Bash launch from the plugin location with `CLAUDE_PLUGIN_ROOT` unset and print the same expected branch | `py -3.10 tests/run_evals.py --plugin tedtoolkit-shared helper-launchers` |
| AC-02 | Primary | Both launchers preserve literal stdin, explicit-path commit membership, output, and established post-commit index/worktree state | Same static helper-launcher suite |
| AC-03 | Primary | Missing location/runtime and invalid-argument cases return non-zero, emit diagnostics, and preserve repository state | Same static helper-launcher suite |
| Shared callers and guidance | Conditional | No active skill, reference, or root guidance requires `CLAUDE_PLUGIN_ROOT` or `bash` on Windows, and all documented invocations name the portable contract | Repository-local static search and link checks in the same suite |

<!-- section: completion-criteria -->
## Completion

Complete when the offline static suite passes on Windows PowerShell and Bash, proves launcher parity
and fail-closed behavior for both helpers, and the affected skills, reference, and `CLAUDE.md`
describe the same installed-plugin invocation contract. Preserve all baseline Git and index
semantics; no durable documentation beyond the updated active guidance is required.
