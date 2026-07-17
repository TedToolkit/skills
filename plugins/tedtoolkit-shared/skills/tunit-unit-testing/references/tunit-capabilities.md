# TUnit Capabilities

Use this file when you need TUnit-specific mechanics while writing or reviewing tests.

## Execution

- Follow the repository's test command. Both `dotnet run` and `dotnet test` support TUnit.
- `dotnet test` is preferable when every target framework should run; `dotnet run` remains a good
  simple-project command and is often better for runner-specific arguments.
- TUnit filtering uses `--treenode-filter`, not the VSTest `--filter` syntax.

## Core Rules

- TUnit test classes are instantiated per test method.
- Tests run in parallel by default.
- Shared mutable instance state is unsafe by default.
- TUnit assertions are asynchronous and must be awaited.

For integration tests, isolate external resources per test whenever possible. Use
`[NotInParallel("resource-key")]` only for tests that must not share a particular resource, and
use `ParallelLimiter<T>` when an external dependency has bounded capacity.

## Data-Driven Options

### `[Arguments(...)]`

Use for simple compile-time rows:

- primitive values
- enum rows
- small boundary tables

### `[CombinedDataSources]`

Use when multiple parameter-level sources should be composed in one scenario. This is a strong fit
for this codebase because custom parameter attributes are common.

### `[MatrixDataSource]`

Use when the Cartesian product of dimensions is itself the intended coverage.

### `[ClassDataSource<T>]`

Use for expensive shared fixtures or injected infrastructure with lifecycle management. Favor
`IAsyncInitializer` and `IAsyncDisposable` when setup or teardown is asynchronous.

### Custom `DataSourceGeneratorAttribute<T>`

Use when the project repeatedly needs the same family of generated values or domain objects.
Return `IEnumerable<Func<T>>` from `GenerateDataSources(...)` so discovery can defer instance
materialization.

Prefer this route in mathematical or geometric domains, especially when:

- inputs need shaped ranges, not just literals
- object construction is noisy
- the same generator is useful across many tests
- the test intent is clearer when the parameter name carries the generator meaning

## Hooks

Use hooks sparingly:

- Put cheap ordinary setup in constructors.
- Use `[Before(Test)]` or `[After(Test)]` for per-test async setup or cleanup.
- Use `[Before(Class)]` or `[After(Class)]` for class-wide setup or cleanup.
- Prefer `ClassDataSource<T>` over custom global lifecycle code when a reusable fixture object is
  the real dependency.

## `[DependsOn]`

Use `[DependsOn]` only to express a real validity prerequisite between tests.

Use it when:

- a later test proves a second step that only makes sense after a first step succeeds
- a multi-step scenario must stay split for readability, but the dependency is real and explicit

Do not use it when:

- you merely want a convenient order
- setup should instead be a helper, fixture, or hook
- the dependency exists only because the tests share mutable state

If `[DependsOn]` is used, document the prerequisite in the test method's XML `summary`.

## Useful Assertion Patterns

- `await Assert.That(value).IsEqualTo(expected);`
- `await Assert.That(flag).IsTrue();`
- `await Assert.That(sequence).Count().IsEqualTo(n);`
- `await Assert.That(action).Throws<SomeException>();`
- `using (Assert.Multiple())` when several related assertions should report together

## Official Docs Read During Skill Authoring

These sections informed this skill:

- Intro
- Installing TUnit
- Writing your first test
- Running your tests
- Things to know
- Assertions getting started
- Data-driven overview
- Arguments
- Class data source
- Test lifecycle overview
- Hooks
- Tips and pitfalls

If you need deeper detail than this reference covers, consult the corresponding page on
`https://tunit.dev/docs/`.
