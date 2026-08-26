# C# exception paths

Use this reference during implementation or code review only when exception construction affects
an evidenced hot path, an inline candidate, generated or repeated code size, an approved
performance constraint, or the candidate adds or changes a framework guard, custom throwing
helper, or exception factory. The presence of business logic or a direct `throw` is not enough:
ordinary direct throws remain valid when no such condition exists.

## Preserve the failure contract first

Keep the caller-visible exception behavior unchanged unless the approved change explicitly owns it:

- exception type, parameter name, actual value, message or resource, and inner exception;
- the point at which validation occurs and which failure wins when several inputs are invalid;
- stack-trace presentation when callers, diagnostics, or repository conventions depend on it; and
- target-framework and public-API compatibility.

Do not trade a clearer or more accurate failure contract for a speculative inlining benefit.

## Choose the narrowest mechanism

Apply this order:

1. Prefer an equivalent framework guard available on every supported target framework, such as
   `ArgumentNullException.ThrowIfNull`, `ArgumentException.ThrowIfNullOrEmpty`, or an applicable
   `ArgumentOutOfRangeException.ThrowIf*`. Inspect the actual target frameworks and API semantics;
   do not assume that the newest API is available or equivalent.
2. Keep a direct `throw new ...` when it is a clear one-off path and caller code size, duplication,
   allocation placement, or inlining is not a demonstrated concern.
3. Extract an always-throwing helper when doing so keeps exception construction, resource lookup,
   message formatting, boxing, or repeated IL out of a performance-sensitive caller. Prefer the
   existing domain or component owner over a repository-wide catch-all helper when the failure is
   domain-specific.
4. When a performance claim decides between valid shapes, use the approved Benchmark proof on the
   affected target frameworks and architectures. Read
   [benchmarkdotnet.md](../../skills/architecture-design/references/benchmarkdotnet.md) before
   creating or running a BenchmarkDotNet project.

Moving the cold exception-construction path can reduce caller IL and native code size and can make
an inline decision more likely. It does not guarantee that the JIT will inline the caller: the JIT
also considers the call site, target runtime, code-size budget, profile data, and other heuristics.
Do not report an inlining or throughput improvement without observing the relevant generated code
or representative measurement.

## Shape a custom throwing helper

Keep the normal condition and hot-path work clear at the call site; put exception construction and
expensive message work in an always-throwing method:

```csharp
using System.Diagnostics.CodeAnalysis;

if (!CanTransition(current, next))
{
    OrderThrow.InvalidTransition(current, next);
}

ApplyTransition(next);

internal static class OrderThrow
{
    [DoesNotReturn]
    internal static void InvalidTransition(OrderState current, OrderState next) =>
        throw new InvalidOperationException(
            $"Cannot transition an order from {current} to {next}.");
}
```

For a custom helper:

- return `void` and add `System.Diagnostics.CodeAnalysis.DoesNotReturnAttribute` when the method
  always throws; do not add it to a conditional guard that may return;
- defer string formatting, resource lookup, exception allocation, and avoidable boxing until inside
  the helper rather than computing them as call arguments;
- use narrow typed parameters so the helper can reproduce the exact failure contract without
  forcing hot-path boxing or lossy state reconstruction;
- do not mark the throwing helper `AggressiveInlining`; its purpose is to keep cold construction out
  of the caller;
- use `System.Diagnostics.StackTraceHiddenAttribute` only when its target-framework availability is
  established and hiding the helper frame is an intentional diagnostic convention; and
- reuse an existing helper only when its semantics match exactly. Similar exception types do not
  justify collapsing distinct parameter names, messages, resources, or domain ownership.

An exception factory that returns an exception for `throw Factory.Create(...)` may centralize
construction, but it retains the `throw` operation in the caller. Do not substitute that pattern
when the evidenced goal is specifically to move the throwing path out of an inline candidate.

## Reject mechanical rewrites

Do not:

- ban every direct `throw` in a method that also contains business logic;
- add a helper, guard abstraction, or dependency solely to satisfy a visual coding pattern;
- claim that a helper makes throwing cheap or use exceptions as expected control flow;
- rewrite an existing failure path without regression proof for its observable contract; or
- introduce a helper across public, shared, generated, or dependency boundaries outside the
  approved delivery scope.

Complete the choice when the failure contract is preserved, the mechanism is available on the
supported targets, the cold path has one cohesive owner, and every claimed performance effect has
proof proportionate to its role in the change.

## Primary sources

Use the target runtime and framework documentation when a version-specific fact affects the choice:

- [CommunityToolkit `ThrowHelper` technical details](https://learn.microsoft.com/dotnet/communitytoolkit/diagnostics/throwhelper)
  explain the caller code-size effect of moving exception construction.
- [RyuJIT inlining overview](https://github.com/dotnet/runtime/blob/main/docs/design/coreclr/jit/ryujit-overview.md#inlining)
  describes the profitability heuristics that prevent an inlining guarantee.
- [Runtime `ThrowHelper` source](https://github.com/dotnet/runtime/blob/main/src/libraries/System.Private.CoreLib/src/System/ThrowHelper.cs)
  shows the runtime's current `DoesNotReturn` and `StackTraceHidden` usage.
- [Framework exception guard APIs](https://learn.microsoft.com/dotnet/api/system.argumentnullexception.throwifnull)
  provide the starting point for checking the supported target frameworks and exact semantics.
