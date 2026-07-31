---
name: use-boxing-annotations
description: >-
  Expose intentional C# value-type boxing with TedToolkit.Annotations.Boxing. Use when a project
  that references the package converts a value type to object, an interface, or another reference
  type and the allocation must be distinguished from accidental boxing.
---

# Use TedToolkit.Annotations.Boxing

Make deliberate boxing explicit without changing the target type or claiming that the allocation
was removed.

When the API also needs caller-facing prose, invoke `write-csharp-api-comments`. Apply another
annotation skill only for an independent contract; this skill retains the boxing semantics.

## Steps

1. Inspect the active project and reference graph. Continue only when
   `TedToolkit.Annotations.Boxing` is available; otherwise report the failed package gate.
2. Inventory the in-scope value-type conversions and classify every one as removable or deliberate.
   Complete this step when each conversion has one classification and its target static type is known.
3. Remove accidental boxing through the underlying API or data-flow fix. For deliberate boxing,
   draft the smallest `Boxer.Box` call and show it for explicit approval before editing.
4. After approval, preserve nullable flow and target types, then run the affected build or analyzer.
   Complete only when behavior is unchanged and every in-scope boxing diagnostic is resolved or
   reported with its exact location.

## Usage

```csharp
object boxed = Boxer.Box(count);
IComparable comparable = Boxer.Box<IComparable, int>(count);
object? boxedOrNull = Boxer.Box(nullableCount);
```

`Boxer.Box` declares an allocation; it does not avoid one. Document a non-obvious allocation reason
beside the contract rather than using the wrapper as an unexplained suppression.

## Verify the result

Keep the target static type unchanged, select the nullable overload when the value may be absent,
and require a reference type for the generic target.
