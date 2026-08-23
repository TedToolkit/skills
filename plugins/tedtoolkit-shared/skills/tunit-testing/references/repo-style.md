# Repository Test Style

## Contents

- [Naming conventions](#naming-conventions)
- [Comment rules](#comment-rules)
- [Unit-test data-driven style](#unit-test-data-driven-style)
- [Custom generator pattern](#custom-generator-pattern)
- [Example local shapes](#example-local-shapes)

## Naming Conventions

Required layout for TedToolkit and KitchenSink test repositories:

- Place the tests for production class `ClassName` in a `ClassNameTests` directory.
- Within that directory, place each tested method in `MethodNameTests.cs`.
- Name the single test class in that file `MethodNameTests`.
- Keep overloads of the same method in the same test class.
- When a focused behavior has no single corresponding method, replace `MethodName` with a concrete
  behavior name such as `Constructor`, `AdditionOperator`, or `RoundTrip`.
- Classes are usually `internal sealed class`.
- Test method names usually follow a `Should_xxx_when_xxx` scenario style.

Example for production class `Angle`:

```text
AngleTests/
├── ConstructorTests.cs       // internal sealed class ConstructorTests
├── NormalizePositiveTests.cs // internal sealed class NormalizePositiveTests
└── AdditionOperatorTests.cs  // internal sealed class AdditionOperatorTests
```

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

- Simple scalar coverage often uses `[Arguments(...)]`.
- Geometry and domain-object tests often use `[CombinedDataSources]`.
- Reusable generators are commonly implemented as custom parameter attributes inheriting from
  `DataSourceGeneratorAttribute<T>`.
- `MatrixDataSource` is used when combinatorial coverage is intended.

Choose the source that makes the material behavior partition visible:

- use `[Arguments(...)]` for named examples and exact boundaries whose values are part of the test's
  meaning;
- use a custom generator attribute for a reusable shaped family or invariant where several tests
  need the same domain distribution;
- use `[CombinedDataSources]` when independent parameter-level sources form the intended scenario;
- use `MatrixDataSource` only when the Cartesian product itself is intended coverage; and
- use `MethodDataSource` when construction cannot be expressed clearly by the options above.

Generated volume does not replace explicit success, failure, or boundary partitions, and a few
literal rows do not replace a domain invariant when broad shaped inputs are the actual contract.
Integration tests prioritize an explicit resource boundary, setup, cleanup, and parallel safety
over parameterized input coverage.

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
