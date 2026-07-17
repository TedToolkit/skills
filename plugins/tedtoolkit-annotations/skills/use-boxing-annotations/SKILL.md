---
name: use-boxing-annotations
description: >-
  Use TedToolkit.Annotations.Boxing to make intentional C# value-type boxing allocations explicit.
  Trigger only when the current project directly references TedToolkit.Annotations.Boxing (including a
  transitive project reference that exposes it); do not use this skill for projects that do not reference the package.
---

# Use TedToolkit.Annotations.Boxing

First inspect the active `.csproj`, `Directory.Packages.props`, or project-reference graph and confirm
that `TedToolkit.Annotations.Boxing` is available. If it is absent, do not propose its APIs.

## Use this skill when

Use this skill when a value type is intentionally converted to `object`, an interface, or another
reference type for an API boundary, a heterogeneous collection, logging, formatting, or interop.
Do not use it for reference-type conversions, for accidental boxing that can be removed, or as a
replacement for a performance investigation.

## Workflow

1. Locate implicit conversions of value types to `object`, interfaces, or another reference type.
   Distinguish deliberate allocations from accidental boxing that should be removed.
2. For a deliberate allocation, draft `using TedToolkit.Annotations.Boxing;` and the smallest
   `Boxer.Box` call that makes it visible. Show the draft and wait for explicit approval before editing.
3. Preserve behavior and nullable flow, then build or run the relevant analyzer after approval.

## Usage

```csharp
object boxed = Boxer.Box(count);
IComparable comparable = Boxer.Box<IComparable, int>(count);
object? boxedOrNull = Boxer.Box(nullableCount);
```

`Boxer.Box` does not avoid an allocation; it declares that the allocation is intentional to readers
and the bundled analyzer. Do not wrap conversions merely to suppress diagnostics without documenting
the reason for the allocation when it is non-obvious.

## Verify the result

Keep the target static type unchanged, select the nullable overload when a nullable value can be
absent, and confirm that the generic target type is a reference type. Run the package analyzer after
editing: remaining diagnostics should identify genuinely unreviewed boxing, not conversions hidden
behind unnecessary helper calls.
