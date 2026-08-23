# TUnit.Mocks

## Contents

- [Package and compatibility](#package-and-compatibility)
- [Decide whether to mock](#decide-whether-to-mock)
- [Create and configure mocks](#create-and-configure-mocks)
- [Match arguments precisely](#match-arguments-precisely)
- [Assert outcomes and verify interactions](#assert-outcomes-and-verify-interactions)
- [Specialized boundaries](#specialized-boundaries)

## Package and compatibility

- Add the `TUnit.Mocks` package to the test project only when mocks are needed.
- Preserve central package management: put the version in `Directory.Packages.props` when the
  repository uses it, and keep the project-level `PackageReference` versionless.
- `TUnit.Mocks` currently requires C# 14 or later. The generated `T.Mock()` extension syntax also
  requires .NET 10. Inspect the project's language version and target frameworks before using it.
- If `T.Mock()` is unavailable but the installed package supports the project, use a documented
  factory such as `Mock.Of<T>()`. If the package itself is incompatible, stop and report the
  constraint; do not silently upgrade the target framework or add a different mocking library.
- Add `TUnit.Mocks.Http` only for HTTP helpers and `TUnit.Mocks.Logging` only for logging helpers.

Consult the current official documentation at `https://tunit.dev/docs/writing-tests/mocking/` when
the installed version differs from these examples or an advanced API is required.

## Decide whether to mock

Mock a dependency only when the test needs to control or observe a collaborator boundary. Typical
boundaries include clocks, queues, storage gateways, remote clients, and injected services.

Prefer real objects for:

- the system under test
- ordinary records, value objects, collections, or deterministic domain logic
- a real component whose behavior is the purpose of the test
- a large stateful dependency when a small purpose-built in-memory implementation communicates the
  scenario more clearly

Mock behavior should make the tested contract easier to see, not reproduce the collaborator's
implementation.

## Create and configure mocks

Prefer the generated extension syntax when available:

```csharp
var priceSource = IPriceSource.Mock(MockBehavior.Strict);
priceSource.GetPrice("sku-1").Returns(12.5m);
```

Use the documented alternative factories for shapes that need them:

- `Mock.Of<T>()` when `T.Mock()` is unavailable
- `Mock.OfDelegate<T>()` for delegates
- `Mock.Wrap(instance)` for a deliberate partial override of a real instance
- `Mock.Of<T1, T2>()` when one generated object must implement multiple interfaces

Configure only calls needed by the scenario. `Returns(...)`, `Throws(...)`, and `Callback(...)`
turn the generated member expression into setup. TUnit.Mocks automatically wraps configured return
values for supported `Task<T>` and `ValueTask<T>` members.

Choose mock behavior deliberately:

- Use `MockBehavior.Strict` when any unexpected call indicates a contract violation.
- Use the default loose behavior only when unconfigured calls and smart defaults are intentionally
  irrelevant to the scenario.
- Do not use loose mocks to avoid understanding required setup.

## Match arguments precisely

Use the narrowest matcher that expresses the behavior:

- raw values such as `42` or `"sku-1"` for exact equality
- `Any()` only when the argument is irrelevant
- inline predicates such as `id => id > 0` when a property of the value matters
- a captured `Arg<T>` when the test must assert over values passed to the collaborator

Broad matchers can let the wrong call satisfy a setup. Prefer exact values whenever the argument is
part of the behavior contract.

## Assert outcomes and verify interactions

Assert the observable result or state change first. Verify a collaborator call only when that
interaction is itself required behavior, such as publishing exactly one event or never deleting a
record during a read operation.

Prefer TUnit assertion integration so verification follows the same awaited assertion convention:

```csharp
using TUnit.Mocks;
using TUnit.Mocks.Assertions;

internal sealed class PricingServiceTests
{
    /// <summary>
    /// Verifies that the service multiplies the collaborator price by the requested quantity.
    /// </summary>
    [Test]
    public async Task Should_return_total_when_price_source_has_a_matching_sku()
    {
        var priceSource = IPriceSource.Mock(MockBehavior.Strict);
        priceSource.GetPrice("sku-1").Returns(12.5m);
        var sut = new PricingService(priceSource);

        var result = sut.GetTotal("sku-1", 2);

        await Assert.That(result).IsEqualTo(25m);
        await Assert.That(priceSource.GetPrice("sku-1")).WasCalled(Times.Once);
    }
}
```

Useful verification forms include:

- `.WasCalled()` for at least one call
- `.WasCalled(Times.Once)` or `.WasCalled(Times.Exactly(n))` for an exact count
- `.WasNeverCalled()` for a prohibited interaction
- `VerifyNoOtherCalls()` only when the complete interaction set is intentionally part of the
  contract

Do not verify every internal call. Overspecified interaction tests resist harmless refactoring and
usually test implementation rather than behavior.

## Specialized boundaries

- Use `Mock.HttpClient(...)`, `Mock.HttpHandler()`, or `Mock.HttpClientFactory()` from
  `TUnit.Mocks.Http` for HTTP responses and request verification. Do not mock `HttpClient` internals
  by hand.
- Use `Mock.Logger()` or `Mock.Logger<T>()` from `TUnit.Mocks.Logging` when log capture or
  verification is required behavior. Do not assert incidental diagnostic text.
