# Keep .NET diagnostic repair scoped and reproducible

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: bug-fix -->
<!-- change-status: candidate-ready -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: commit:fba90f30bec6182226002df68226a17e4a518950 -->

<!-- section: goal-rationale -->
## Goal and rationale

.NET repair requests select one workflow owner, automated analyzer fixes stay inside the approved
diagnostic boundary, and a zero-diagnostic conclusion comes from a fresh Release build. Today a
named failing project can match both repair skills, a broad formatter can edit unrelated files, and
an incremental build can omit diagnostics from up-to-date projects.

<!-- section: scope -->
## Scope and non-goals

- In scope: `run-fix` versus `fix-csharp-diagnostics` routing; bounded analyzer-fix commands; dirty
  worktree protection; fresh final diagnostic proof; paired trigger and command-boundary evals.
- Non-goals: TUnit test design, runtime root-cause rules, whole-repository formatting, suppression
  policy changes, or claiming that a clean build proves behavioral correctness.
- Preserved: `run-fix` owns a named project's observed build/run/test failure and final verification;
  `fix-csharp-diagnostics` owns explicit diagnostic cleanup and warning-free tails; both continue to
  fix root causes and require approval for newly expanded behavior.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Repair routing and proof | A named compile failure can match two owners; analyzer fixing may be broad; incremental output can support a zero-diagnostic claim | One owner is selected, automatic fixes are bounded to observed IDs and approved paths, and the final build forces re-evaluation | Root-cause repair, Release mode, suppression gate, and exact-target reporting remain required |

<!-- acceptance-case: AC-01 -->
### AC-01 — Select one repair owner

```gherkin
Scenario: Route a .NET repair request
  Given either a named failing project or an explicit diagnostics-only cleanup
  When the request is classified
  Then a named build, run, or test failure stays with run-fix and a diagnostic-ID or warning-clean task uses fix-csharp-diagnostics without recursive handoff
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Keep automated fixes inside the approved boundary

```gherkin
Scenario: Apply an available analyzer fix
  Given observed diagnostic IDs, approved affected paths, and unrelated worktree content
  When an automated analyzer fixer is selected
  Then its command limits both diagnostics and paths, or the skill skips the broad fixer, and unrelated content remains byte-identical
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Prove the final diagnostic state freshly

```gherkin
Scenario: Report zero warnings and errors
  Given the approved target has been repaired
  When final Release verification runs
  Then the build forces non-incremental analysis and only a successful zero-warning, zero-error result supports completion
```

## Constraints and risks

- Command examples must be valid for the supported `dotnet format` and SDK syntax and inherit a
  stricter repository-authoritative gate when one exists.
- Dirty-tree preservation is fail-closed: if the fixer cannot distinguish its edits from existing
  user work, it must stop instead of reverting or accepting unrelated output.
- Routing-description changes must not make diagnostics-only cleanup re-enter `run-fix`.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: shared repair Skill descriptions, bodies, and hermetic evals.
- Other real start conditions or resource prerequisites: local Git, Bash fixture support, and a
  stubbed or installed `dotnet` that records commands without network restore.
- Likely touchpoints (non-binding): `fix-csharp-diagnostics`, `run-fix`, their `agents/openai.yaml`,
  and `tests/tedtoolkit-shared/{fix-csharp-diagnostics,run-fix}`.
- Private implementation choices left open: fixture layout, command recorder, and whether the fresh
  build also disables build servers when repository evidence warrants it.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
<!-- primary-proof: AC-02 purpose=boundary shape=integration -->
<!-- primary-proof: AC-03 purpose=structural shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Paired near-miss prompts choose one owner and never bounce recursively | `py -3.10 tests/run_evals.py --plugin tedtoolkit-shared fix-csharp-diagnostics run-fix` |
| AC-02 | Primary | Recorded formatter commands contain observed IDs and approved includes, while an out-of-scope file is unchanged | Same focused eval command |
| AC-03 | Primary | The recorded final Release build includes `--no-incremental` and completion requires zero diagnostics | Same focused eval command |

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-03 pass, existing `run-fix` regression scenarios remain green, Skill structure and
links validate, the complete candidate receives proportionate implementation review, and no
unrelated worktree content or suppression mechanism is added.
