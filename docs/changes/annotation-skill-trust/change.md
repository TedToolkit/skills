# Make annotation evidence executable

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: bug-fix -->
<!-- change-status: candidate-ready -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: commit:fba90f30bec6182226002df68226a17e4a518950 -->

<!-- section: goal-rationale -->
## Goal and rationale

The Documentation and Maintenance annotation Skills make claims only from executed proof and
compile their representative guidance against the supported package APIs. The current fixture can
reward `hasUnitTest: true` while its test omits the exception and side-effect assertions, and its
package references use a nonexistent `0.1.0` version even though the locally verifiable packages are
`2026.7.16.2`.

<!-- section: scope -->
## Scope and non-goals

- In scope: a real focused BehaviorCase test; true and false coverage branches; package-bound compile
  fixtures for `TedToolkit.Annotations.Documentations` and `TedToolkit.Annotations.Maintenance`
  `2026.7.16.2`; structured `RemoveWhen` guidance; aligned eval assertions; annotation-plugin release
  identity.
- Non-goals: changing annotation package APIs, covering Const/Ownership/Boxing package compatibility,
  changing general XML documentation scope, or treating stubs as compatibility proof.
- Preserved: XML prose remains the caller-facing contract; specialized Skills retain their current
  semantic ownership; package presence remains a hard gate.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Annotation proof reported by focused evals | A prompt can assert a passing test that the fixture never executes, and representative snippets target an unavailable package version | `hasUnitTest: true` is emitted only after the exact focused test passes, the non-passing path remains false, and Documentation/Maintenance snippets compile against `2026.7.16.2` | No source-only inspection is promoted to test proof and no unsupported annotation family is claimed as package-compatible |

<!-- acceptance-case: AC-01 -->
### AC-01 — Require the real behavior-case test

```gherkin
Scenario: Mark a documented exceptional behavior as tested
  Given the fixture has a runnable test that observes ArgumentOutOfRangeException and verifies no allocation side effect
  When the runner executes that focused test successfully before invoking the Skill
  Then the proposed BehaviorCase may set hasUnitTest to true and identifies the proved branch
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Refuse unexecuted or failing test evidence

```gherkin
Scenario: Test proof is missing or fails
  Given the same behavior-case fixture has not produced a successful focused-test result
  When Documentation annotations are proposed
  Then hasUnitTest remains false and the output does not describe the branch as tested
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Compile supported structured annotation APIs

```gherkin
Scenario: Propose Documentation and Maintenance annotations
  Given NuGet packages TedToolkit.Annotations.Documentations and TedToolkit.Annotations.Maintenance version 2026.7.16.2 are restored for net10.0
  When representative BehaviorCase, operational, and maintenance records are rendered
  Then the fixture builds and the maintenance reason is separate from its objective RemoveWhen condition
```

## Constraints and risks

- Package constructors, enum values, targets, and named arguments come from the real restored
  `2026.7.16.2` assemblies, never a look-alike stub.
- An offline run may use the exact package from the local NuGet cache; if neither cache nor restore can
  supply it, AC-03 is blocked rather than weakened.
- The real test command must finish before its result becomes model-visible; prompt text alone is not
  proof.
- Before publishing changed annotation Skills, fetch `origin` and its tags, enumerate every
  annotation-plugin version reachable from the remote default branch and release tags, select the
  next SemVer value absent from that history, and keep the Codex and Claude manifests identical.
  Because this repository is the plugin marketplace, that remote history is the authoritative
  release channel; missing remote evidence blocks candidate readiness.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: Documentation/Maintenance Skill contracts, their package-bound
  fixture, executable test setup, eval scenarios, and annotation plugin manifests.
- Other real start conditions or resource prerequisites: .NET 10 SDK, TUnit `1.63.0`, the two exact
  annotation packages, and fetched `origin` default-branch/tag history for the annotation plugin.
- Likely touchpoints (non-binding): `use-documentation-annotations`,
  `use-maintenance-annotations`, `tests/tedtoolkit-annotations/annotation-skills`, and both annotation
  plugin manifests.
- Private implementation choices left open: test-project layout and whether package restore is
  shared across static setup cases.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=boundary shape=integration -->
<!-- primary-proof: AC-02 purpose=boundary shape=integration -->
<!-- primary-proof: AC-03 purpose=structural shape=integration -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | TUnit `1.63.0` discovers exactly the intended test, passes it, reports non-zero discovered plus passed/failed/skipped counts, and covers both the exception and the pre-allocation side-effect boundary before output contains `hasUnitTest: true` | Setup restores once, then records `dotnet run --project Sample.Tests.csproj -c Release --no-restore -- --treenode-filter "/*/*/BatchFactoryTests/Create_negative_count_throws_before_allocating"` before the focused annotation eval |
| AC-02 | Primary | Zero-discovery, unexecuted, and failing result fixtures each continue into the Skill invocation, produce `hasUnitTest: false`, and make no tested claim | Three paired focused annotation evals capture the test process result without allowing setup's fail-fast mode to terminate before the model-visible evidence is written |
| AC-03 | Primary | Real package-bound declarations compile, including `RemoveWhen` as a named argument distinct from the reason | Fixture `dotnet restore`, then `dotnet build -c Release --no-restore` for `net10.0`, followed by focused annotation eval assertions |

Conditional structural proof: after `git fetch --prune --tags origin`, record the remote URL,
default-branch SHA, tag refs, inspection time, every reachable historical annotation-plugin version,
and the selected absent SemVer value; parse both candidate manifests and assert that their versions
are equal to that value.

Remote release inspection on 2026-08-28T11:13:06+08:00 fetched
`https://github.com/TedToolkit/skills.git`; `origin/HEAD` resolved to `origin/main` at
`8fbad2edc0e2c254764187beb9fcb6f4883b61c5`, no reachable release tags existed, and the reachable
annotation manifest history contained only `0.1.0`. The next absent SemVer is `0.2.0`, selected for
both manifests because this delivery changes observable Skill behavior.

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-03 pass from the exact candidate, the TUnit `1.63.0` run records a non-zero discovery
count and passed/failed/skipped counts, package availability and test results are captured without
prompt-only substitution, both annotation manifests use the remote-history-confirmed unoccupied
version, the exact candidate receives independent implementation review, and no other annotation
family is described as compile-proven.
