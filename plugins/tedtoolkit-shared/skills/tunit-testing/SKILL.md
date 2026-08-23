---
name: tunit-testing
description: >-
  Design, write, migrate, or perform framework-specific review of C# tests that use TUnit in
  TedToolkit or KitchenSink-style repositories. Use for Unit, Component, Contract, Integration, and
  End-to-end execution shapes; TUnit lifecycle, isolation, parallelism, data sources, assertions, or
  TUnit.Mocks. Classify proof role, proof purpose, and execution shape without manufacturing test
  layers. Test-adequacy conclusions remain owned by review-tests and candidate execution by
  verify-implementation when those skills are available.
---

# TUnit Testing

Protect an observable boundary with the narrowest reliable TUnit test. TUnit is the framework, not a
promise that every test is Unit-shaped. Make resource ownership, isolation, cleanup, and parallelism
explicit whenever a test crosses process or infrastructure boundaries.

`run-fix` owns reproduction, root-cause diagnosis, and final Release verification for a failing
named project. Invoke it once when this skill is the original entry point for such a request. When
`run-fix` delegates TUnit work back here, do not invoke `run-fix` again: own only the test's
expression, layout, lifecycle, isolation, mocks, and framework migration, then return that bounded
result to `run-fix`. This skill does not own aggregate test adequacy or merge readiness.

Read [repo-style.md](references/repo-style.md) on every run; it is the single source for layout,
naming, comments, and local data-source preference. Read
[tunit-capabilities.md](references/tunit-capabilities.md) when selecting lifecycle, data sources,
parallel controls, dependencies, assertions, runner options, or migrating another test framework.
Read
[tunit-mocks.md](references/tunit-mocks.md) whenever a collaborator must be controlled or verified.

## Establish the test contract

Inspect production behavior, the approved acceptance case or regression, adjacent tests, project
file, central package management, scripts, CI, and contributor guidance.

Classify three independent dimensions:

- **Proof role:** Primary when the test directly demonstrates one approved contract, or Conditional
  when it addresses an additional applicable risk.
- **Proof purpose:** Acceptance, Regression, Boundary, Structural, or Journey.
- **Execution shape:** Unit for deterministic callable behavior, Component for controlled in-process
  collaborators, Contract for API/schema/protocol compatibility, Integration for real process or
  infrastructure boundaries, or End-to-end for a critical deployed journey.

Role is not purpose: a Regression proof can be Primary for a bug fix, while a Boundary proof can be
Conditional evidence for the same contract. Acceptance is a purpose, not a mandatory project or
execution shape. A deterministic TUnit test through a public API may have the Primary role, serve
both Acceptance and Regression purposes, and remain Unit-shaped.
Use Integration only when real components or infrastructure cooperate, Contract when compatibility
assets form the observed boundary, and End-to-end only when narrower proof cannot establish the
material journey.

Keep the test in the repository's existing coherent test project by default. Create a separate
project only when environment, resources, lifecycle, runtime, cadence, isolation, or ownership
differs materially; do not split projects merely to mirror proof purposes.

Use TUnit and preserve the repository's authoritative command. Ensure the project references
`TUnit`. Preserve an existing `RCS1046` suppression, but do not introduce it as a TUnit requirement.
If the repository's required behavior-focused naming conflicts with that analyzer, propose a
test-project-scoped suppression with its reason as part of the gated plan. During migration, remove incompatible
VSTest-only packages and configuration identified by `tunit-capabilities.md`; translate the existing
behavior proof rather than weakening or duplicating it.

Complete when observable behavior, proof role, proof purpose, execution shape, project placement,
local layout, and verification command are explicit. Report classifications with stable labels:
`Proof role:`, `Proof purpose:`, and `Execution shape:`.

## Design the smallest proving test

Choose one focused setup, action, and observable assertion. Cover the root cause rather than private
implementation. For deterministic input variation, use the data-source decision rules in
`repo-style.md`; explicit boundary rows should remain obvious, while reusable generators are useful
for shaped domain families and invariants. Stateful integration behavior prioritizes explicit
resource setup, cleanup, and parallel safety over parameter count.

Assume parallel execution:

- give each integration test an independently addressable resource;
- use `[NotInParallel("resource-key")]` only for one unavoidable shared resource;
- use `ParallelLimiter<T>` for bounded shared capacity; and
- use `[DependsOn]` only for a real validity prerequisite, naming that prerequisite in the XML
  summary.

Complete when the test proves its behavior without hidden mutable state or another test's cleanup.

## Gate test writes

Present behavior, proof role, proof purpose, execution shape, proposed cases, data/resource strategy,
collaborator choice, target files, and verification command. Wait for explicit approval before
creating or editing tests or package references. A request that already directs adding or changing
tests is pre-approval after this plan is shown. In review/explanation mode, do not edit.

## Choose real collaborators or TUnit.Mocks

Prefer real values and small in-memory implementations when they clarify the contract. Use a mock
only to control or observe a collaborator boundary such as time, messaging, storage, transport, or
another injected service.

When mocking:

1. Read `tunit-mocks.md`.
2. Confirm package, language-version, target-framework, and central-version compatibility.
3. Use `TUnit.Mocks`; add specialized HTTP or logging packages only for those boundaries.
4. Configure scenario-relevant behavior with the narrowest matchers.
5. Assert the observable result first, then verify only contractually meaningful interactions.

Complete when every mock represents a real boundary and no incompatible framework change or second
mocking framework was introduced.

## Write in repository style

Apply `repo-style.md`. Await every TUnit assertion. Keep each method focused on one behavior
contract and keep overload coverage together. Every added or changed test must:

- occupy the required class/method location;
- have the required behavior-focused XML summary;
- await every assertion;
- own and clean its external resources; and
- express only observable behavior and necessary collaborator interactions.

## Verify or hand off verification

During implementation, run the repository's authoritative Release command. When no command exists,
use:

```sh
dotnet test --configuration Release
```

Use TUnit's `--treenode-filter` for focused selection. Treat zero intended tests as failed
verification. Report the exact command, discovered/passed/failed/skipped counts, proof role, proof
purpose, execution shape, resource strategy, and unverified prerequisites.

When an independent candidate review is underway, return the proof definition and framework facts
to `review-tests`; let `verify-implementation` or trusted CI produce the exact candidate-bound
verification result. Do not write transient pass counts or candidate SHAs into long-lived test
source.
