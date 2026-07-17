---
name: tunit-unit-testing
description: >-
  Use when writing, refactoring, reviewing, or explaining C#/.NET tests that use TUnit in repos
  following the TedToolkit or KitchenSink style, including unit, integration, contract, and
  end-to-end tests. Use it especially when adding tests, improving weak tests, migrating to TUnit,
  or choosing TUnit lifecycle, isolation, parallelism, data-driven, and documentation conventions.
---

# TUnit Testing

## Overview

Use this skill to produce TUnit tests that match the style and expectations used in this codebase.
First classify the boundary under test: unit tests should be fast and deterministic; integration,
contract, and end-to-end tests must make real-resource ownership, isolation, cleanup, and
parallelism explicit. Favor root-cause coverage and documentation of each test's purpose and
prerequisites.

Read [references/tunit-capabilities.md](references/tunit-capabilities.md) when you need a focused
reminder of TUnit features and execution rules. Read
[references/repo-style.md](references/repo-style.md) when you need naming, structure, and local
style examples.

## Non-Negotiables

- For every project that uses TUnit, ensure its project file contains
  `<NoWarn>$(NoWarn);RCS1046</NoWarn>`; preserve any existing `NoWarn` values.
- Preserve the repository's authoritative test command. Both `dotnet run` and `dotnet test` work
  with current TUnit; prefer `dotnet test` when all target frameworks must run, and use
  `dotnet run` when the repository uses it or when its runner arguments make it clearer.
- Add the repository-required XML `summary` comment to every test method. No test method should be left without one.
- Always `await` TUnit assertions.
- Assume tests run in parallel by default. Avoid hidden shared mutable state.
- For deterministic unit behavior, prefer data-driven tests over repetitive one-case methods when
  only inputs vary. Do not manufacture data-driven rows for stateful integration scenarios.
- Prefer custom attribute-based generators over ad hoc `MethodDataSource` only when the same
  deterministic domain data will be reused.
- Use `[DependsOn]` only when a test is valid only after another test has established a necessary
  prerequisite. Do not use it as a lazy replacement for independent setup.

If you detect TUnit, do not infer a command from the project name or `<IsTestProject>`. Inspect
the repository's scripts, CI, and documentation first. TUnit uses Microsoft.Testing.Platform, so
runner-specific arguments and filtering differ from VSTest even when the command is `dotnet test`.

## Workflow

## 1. Identify the test surface

- Find the production API, operator, or behavior being verified.
- Match the local naming pattern: one test file and one test class per focused member or behavior
  family when practical.
- Prefer root-cause behavior coverage over asserting implementation details.

## 2. Choose the narrowest useful test shape

- Use a single ordinary `[Test]` when the case is truly one-off.
- Use `[Arguments(...)]` for simple compile-time scalar rows.
- Use `[CombinedDataSources]` when different parameter generators should be composed on one test.
- Use `[MatrixDataSource]` when the Cartesian product itself is the intent.
- For unit tests, use a custom `DataSourceGeneratorAttribute<T>` when the same object family,
  boundary pattern, or domain-specific value creation will likely recur.
- For integration tests, give each test an independently addressable resource boundary (for
  example, a database/schema, temp directory, queue, container, or remote-test identity) and clean
  it up reliably. Use shared fixtures only when their lifecycle and reset strategy are explicit.
- Use `[ClassDataSource<T>]` for injected infrastructure or a deliberately shared fixture, not as a
  substitute for ordinary input data. Do not let its reuse hide mutable state between tests.

## 3. Make integration boundaries safe

Apply this section only when the test crosses persistence, filesystem, network, serialization, DI,
or multiple real components.

- Use unique per-test names or namespaces by default; cleanup must run even after assertion
  failures.
- Keep tests parallel when their resources are isolated.
- When a resource cannot safely overlap, constrain only that resource with
  `[NotInParallel("resource-key")]`. Use a `ParallelLimiter<T>` for bounded shared capacity such
  as browser or database connections; do not serialize the whole assembly without a concrete
  reason.
- Do not use `[DependsOn]` to create or preserve shared external state. Model a multi-step user
  journey as one test, or create the prerequisite in that test's setup.
- Keep environment-specific configuration and secrets outside source; fail or skip with a clear
  prerequisite message when an externally supplied dependency is unavailable.

## 4. Write the test in local style

- Use file names and class names ending with `Tests`.
- Prefer scenario-style method names in the local convention, usually
  `Should_xxx_when_xxx`.
- Add the required XML `summary` comment above every test method. Keep it short and concrete.
- When `[DependsOn]` is present, state the prerequisite in the `summary`.
- Keep each test method focused on one behavior contract.
- Prefer `internal sealed class` for test classes unless the repo pattern clearly differs.

## 5. Model prerequisites explicitly

When one test depends on another to establish validity:

- Add `[DependsOn(nameof(OtherTest))]`.
- State the prerequisite in the `summary`, not only in the attribute.
- Keep the dependency graph small and obvious.
- If many tests need ordering, reconsider the design. It is usually a sign that setup belongs in a
  fixture, hook, or helper instead.

Good reasons for `[DependsOn]`:

- A later test validates a transition that only makes sense after an earlier creation or bootstrap
  test.
- A regression test intentionally verifies a second-stage effect after a first-stage invariant has
  been proven.

Bad reasons for `[DependsOn]`:

- Sharing state because setup felt inconvenient.
- Enforcing arbitrary execution order for unrelated assertions.
- Hiding flakiness caused by parallel unsafe tests.

## 6. Verify with the repository command

Choose the command from the repository's test scripts, CI, and contributor documentation. If no
authoritative command exists, use `dotnet test --configuration Release` for multi-targeted
projects; otherwise `dotnet run --configuration Release` is a suitable simple-project default.

Examples:

```sh
dotnet test --configuration Release
# or
dotnet run --configuration Release
```

Preserve the repository's project path, working directory, and TUnit flags. Do not use VSTest
`--filter` syntax for TUnit selection; use its `--treenode-filter` syntax when filtering is needed.

## Unit-Test Data Source Preference Order

Choose the first option that fits:

1. Custom parameter attribute based on `DataSourceGeneratorAttribute<T>` for reusable domain data.
2. `[CombinedDataSources]` with generator attributes when several generated dimensions should be
   combined in one scenario.
3. `[MatrixDataSource]` when exhaustive combinations are the point of the test.
4. `[Arguments(...)]` for simple literal rows.
5. `MethodDataSource` only when the data is genuinely computed or too awkward to express as an
   attribute.

Bias toward option 1 in this codebase. The user prefers the attribute-driven approach, especially
for mathematical and geometric objects.

## Example Pattern

```csharp
internal sealed class AngleNormalizePositiveTests
{
    /// <summary>
    /// Verifies that the angle normalizes into the expected positive range.
    /// </summary>
    [Test]
    [Arguments(0, 0)]
    [Arguments(360, 0)]
    [Arguments(-90, 270)]
    public async Task Should_return_normalized_angle_when_input_is_outside_positive_range(
        int inputDegrees,
        int expectedDegrees)
    {
        var input = Angle.FromDegree(inputDegrees);
        var expected = Angle.FromDegree(expectedDegrees);

        var result = input.NormalizePositive();

        await Assert.That(result).IsEqualTo(expected);
    }
}
```

For richer object inputs, prefer a custom generator attribute and `CombinedDataSources` instead of
hand-building many rows inline.

## Review Checklist

Before finishing, verify all of the following:

- Every test method has the required XML `summary`.
- Every assertion is awaited.
- The chosen data source is the simplest one that still expresses deterministic domain intent
  clearly; stateful integration scenarios use explicit setup instead.
- `[DependsOn]` appears only when there is a real prerequisite and that prerequisite is described in
  the comment.
- The test names, file names, and class names follow the repo convention.
  Prefer `Should_xxx_when_xxx` for test method names.
- The final command matches the repository's documented or CI command, and TUnit filters use
  `--treenode-filter` rather than VSTest `--filter`.
- Integration tests own and clean up their resources, and any necessary parallel constraint is as
  narrow as the constrained resource.

## Common Mistakes

- Treating `dotnet run` as the only valid TUnit command, or using `dotnet test` without checking
  the repository's existing convention and target frameworks.
- Passing VSTest `--filter` expressions to a TUnit run and mistaking a zero-test run for a test
  failure.
- Sharing database records, temp paths, ports, or external identities between integration tests
  without isolation or a targeted parallel constraint.
- Splitting a stateful user journey across dependent tests instead of giving one test ownership of
  its setup and cleanup.

## References

- [references/tunit-capabilities.md](references/tunit-capabilities.md)
- [references/repo-style.md](references/repo-style.md)
