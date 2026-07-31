---
name: tunit-unit-testing
description: >-
  Design, write, migrate, or review C# tests that use TUnit in TedToolkit or KitchenSink-style
  repositories. Use for unit, integration, contract, and end-to-end coverage; TUnit lifecycle,
  isolation, parallelism, data sources, assertions, or TUnit.Mocks test doubles, including test
  changes reached from run-fix or implement-change-tdd.
---

# TUnit Testing

Protect an **observable boundary** with the narrowest reliable TUnit test. Make resource ownership,
isolation, cleanup, and parallelism explicit whenever a test crosses process or infrastructure
boundaries.

When the request begins with a failing named project, invoke `run-fix` for reproduction and final
Release verification. This skill owns only the TUnit test change.

Read [repo-style.md](references/repo-style.md) on every run; it is the single source for layout,
naming, comments, and local data-source preference. Read
[tunit-capabilities.md](references/tunit-capabilities.md) when selecting lifecycle, data sources,
parallel controls, dependencies, assertions, or runner options. Read
[tunit-mocks.md](references/tunit-mocks.md) whenever a collaborator must be controlled or verified.

## 1. Establish the test contract

Inspect the production behavior, approved behavior case or regression, adjacent tests, project file,
central package management, scripts, CI, and contributor guidance.

Classify the test as:

- unit for deterministic domain behavior;
- integration for persistence, filesystem, serialization, DI, network, or multiple real components;
- contract for a stable public API or external protocol; or
- end-to-end for a critical deployed-system journey.

Use TUnit and preserve the repository's authoritative command. Ensure the project references
`TUnit` and preserves `<NoWarn>$(NoWarn);RCS1046</NoWarn>`.

Complete when the observable behavior, test level, project, local layout, and verification command
are explicit.

## 2. Design the smallest proving test

Choose one focused setup, action, and observable assertion. Cover the root cause rather than private
implementation. For deterministic input variation, follow the data-source order in `repo-style.md`;
for stateful integration behavior, prioritize explicit resource setup and cleanup.

Assume parallel execution:

- give each integration test an independently addressable resource;
- use `[NotInParallel("resource-key")]` only for one unavoidable shared resource;
- use `ParallelLimiter<T>` for bounded shared capacity; and
- use `[DependsOn]` only for a real validity prerequisite, naming that prerequisite in the XML
  summary.

Complete when the test can prove its behavior without relying on hidden mutable state or a later
test's cleanup.

## 3. Gate the test plan

Present the behavior, test level, proposed cases, data and resource strategy, collaborator choice,
target files, and verification command. Wait for explicit approval before creating or editing tests
or package references. A request that already directs you to add or change tests is pre-approval
after this plan is shown. In review or explanation mode, return the proposal without editing.

## 4. Choose real collaborators or TUnit.Mocks

Prefer real values and small in-memory implementations when they clarify the contract. Use a mock
only to control or observe a collaborator boundary such as time, messaging, storage, transport, or
another injected service.

When mocking:

1. Read `tunit-mocks.md`.
2. Confirm package, language-version, target-framework, and central-version compatibility.
3. Use `TUnit.Mocks`; add specialized HTTP or logging packages only for those boundaries.
4. Configure scenario-relevant behavior with the narrowest matchers.
5. Assert the observable result first, then verify only contractually meaningful interactions.

Complete when every mock represents a real boundary and no incompatible target-framework change or
second mocking framework was introduced.

## 5. Write in repository style

Apply the complete layout, naming, XML-summary, and data-driven conventions from `repo-style.md`.
Await every TUnit assertion. Keep each method focused on one behavior contract and keep overload
coverage together.

Complete when every added or changed test:

- occupies the required class/method location;
- has the required behavior-focused XML summary;
- awaits every assertion;
- owns and cleans its external resources; and
- expresses only observable behavior and necessary collaborator interactions.

## 6. Verify

Run the authoritative repository command in Release. When no command exists, use:

```sh
dotnet test --configuration Release
```

Use TUnit's `--treenode-filter` when focused selection is needed. Treat a zero-test run as a failed
verification until the selection is corrected.

Complete only when all intended tests are discovered and pass, cleanup succeeds, and the final diff
contains the requested coverage without unrelated framework or target changes. Report the command,
discovered and passed counts, test level, resource strategy, and any unverified external
prerequisite.
