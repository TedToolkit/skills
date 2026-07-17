# Repository Test Style

Use this file when you need local conventions rather than generic TUnit advice.

## Naming Conventions

Observed patterns from the local TedToolkit and KitchenSink test repositories:

- Test file names end with `Tests.cs`.
- Test class names end with `Tests`.
- Classes are usually `internal sealed class`.
- One file usually focuses on one API, operator, property, or behavior family.
- Test method names usually follow a `Should_xxx_when_xxx` scenario style.

Examples:

- `AdditionOperatorTests`
- `AngleNormalizePositiveTests`
- `LoopCurveDomainFromDomainTests`

## Comment Rules

This skill tightens the local style:

- Every test method must have the required XML `summary`.
- Keep each `summary` concrete and behavior-focused.
- When a test uses `[DependsOn]`, mention the prerequisite in the `summary`.

Good examples:

```csharp
/// <summary>
/// Verifies that the angle normalizes into the expected positive range.
/// </summary>
```

```csharp
/// <summary>
/// Verifies that the update operation preserves the user identifier after a successful create.
/// </summary>
```

## Unit-Test Data-Driven Style

Observed local patterns:

- Simple scalar coverage often uses `[Arguments(...)]`.
- Geometry and domain-object tests often use `[CombinedDataSources]`.
- Reusable generators are commonly implemented as custom parameter attributes inheriting from
  `DataSourceGeneratorAttribute<T>`.
- `MatrixDataSource` is used when combinatorial coverage is intended.

Prefer the following order in this codebase:

1. Custom generator attribute
2. `CombinedDataSources`
3. `MatrixDataSource`
4. `Arguments`
5. `MethodDataSource`

This order applies to deterministic unit behavior. Integration tests should prioritize an explicit
resource boundary, setup, cleanup, and parallel-safety over parameterized input coverage.

## Custom Generator Pattern

The local preferred style is an attribute per parameter family, for example:

```csharp
[AttributeUsage(AttributeTargets.Parameter)]
public sealed class IntGeneratorAttribute(int count, int min, int max)
    : DataSourceGeneratorAttribute<int>
{
    protected override IEnumerable<Func<int>> GenerateDataSources(
        DataGeneratorMetadata dataGeneratorMetadata)
    {
        return GeneratorHelper
            .GenerateInt(count, min, max)
            .ToFunc();
    }
}
```

This style is especially suitable when:

- many tests need the same kind of generated values
- the parameter type is domain-specific
- the range shape itself communicates the scenario

## Example Local Shapes

### Simple scalar rows

Use `[Arguments(...)]` for compact scalar tables:

```csharp
[Test]
[Arguments(0, 0)]
[Arguments(360, 0)]
[Arguments(-90, 270)]
public async Task Should_return_normalized_angle_when_input_is_outside_positive_range(
    int inputDegrees,
    int expectedDegrees)
{
    ...
}
```

### Combined generated data

Use `[CombinedDataSources]` with custom generators for richer coverage:

```csharp
[Test]
[CombinedDataSources]
public async Task Should_return_single_domain_when_two_domains_intersect(
    [QuantityGenerator<Dimensionless>(3, -1, 0)] Dimensionless start1,
    [QuantityGenerator<Dimensionless>(3, 0, 1)] Dimensionless start2,
    [QuantityGenerator<Dimensionless>(3, 1, 2)] Dimensionless end1,
    [QuantityGenerator<Dimensionless>(3, 2, 3)] Dimensionless end2)
{
    ...
}
```

### Mixed generators and literal rows

Use `[CombinedDataSources]` when a generated object should pair with a literal dimension:

```csharp
[Test]
[CombinedDataSources]
public async Task Should_return_wrapped_domain_when_shifted_domain_is_within_one_span(
    [CurveDomainGenerator(5, 0, 1)] CurveDomain domain,
    [Arguments(-10, -1, 0, 1, 10)] int shift)
{
    ...
}
```

## Execution Reminder

For TUnit, use the repository's documented or CI command. Both commands are valid:

```sh
dotnet test --configuration Release
# or
dotnet run --configuration Release
```
