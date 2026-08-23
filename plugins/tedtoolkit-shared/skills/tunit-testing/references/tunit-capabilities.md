# TUnit Capabilities

## Execution

- Follow the repository's test command. Both `dotnet run` and `dotnet test` support TUnit.
- `dotnet test` is preferable when every target framework should run; `dotnet run` remains a good
  simple-project command and is often better for runner-specific arguments.
- TUnit filtering uses `--treenode-filter`, not the VSTest `--filter` syntax.

Treat a zero-test run as failure even when the command exits successfully. Record the discovered,
passed, failed, and skipped counts so a runner or filter mistake cannot masquerade as verification.

## Migration Compatibility

When migrating an existing test project to TUnit, inspect the project file, central package
management, build props, CI, and coverage scripts before editing:

- remove `Microsoft.NET.Test.Sdk`; it selects the VSTest platform and conflicts with TUnit's
  Microsoft.Testing.Platform runner;
- remove `coverlet.collector` and `coverlet.msbuild`; use TUnit's
  Microsoft.Testing.Platform-compatible coverage support instead;
- remove the previous framework's packages after all in-scope tests have been translated;
- replace framework-specific test, assertion, data-source, setup, teardown, ordering, and filtering
  APIs without changing the behavior being proved;
- preserve central package management and the repository's target frameworks unless the installed
  TUnit or TUnit.Mocks version makes an incompatibility explicit; and
- verify the repository's documented Release command with a non-zero discovered-test count after
  the incompatible packages and syntax are gone.

Do not remove VSTest packages from a different test project that is not part of the approved
migration. Do not report a migration complete from package-file inspection alone.

## Core Rules

- TUnit test classes are instantiated per test method.
- Tests run in parallel by default.
- Keep mutable state owned by one test instance.
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

Use a fixture, hook, or helper instead when:

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

For mechanics beyond this reference, consult the matching current page on
`https://tunit.dev/docs/`.
