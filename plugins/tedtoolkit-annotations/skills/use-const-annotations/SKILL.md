---
name: use-const-annotations
description: >-
  Specify C# object-graph non-mutation contracts with TedToolkit.Annotations.Const. Use when a
  project that references the package needs a verifiable read-only boundary for a parameter,
  instance or static method, or local alias.
---

# Use TedToolkit.Annotations.Const

Make the real mutation boundary explicit. Read
[attribute-arguments.md](../../references/attribute-arguments.md) before drafting annotation text.
Invoke `use-ownership-annotations` for resource ownership or callback lifetime,
`use-documentation-annotations` for operational behavior, and `write-csharp-api-comments` for
caller-facing XML. This skill retains the non-mutation contract.

## Steps

1. Confirm that the active project references `TedToolkit.Annotations.Const`; otherwise report the
   failed package gate.
2. Trace assignments, aliases, property access, and invoked members for every in-scope contract.
   Complete when the deepest protected graph edge and every possible write are accounted for.
3. Draft the narrowest accurate depth with equivalent XML documentation. Show the draft and wait
   for explicit approval before editing source.
4. After approval, build with the analyzer. Complete when the selected depth is proved, overrides
   and interface implementations compose correctly, and every remaining diagnostic is explained.

## Usage

```csharp
[Const(ConstDepth.DEPTH0_OR_GREATER)]
public string Describe([Const] Order order) => order.Customer.Name;

var snapshot = AsConst.Local(order, ConstDepth.DEPTH1_OR_GREATER);
```

`DEPTH0` on a parameter protects reassignment of that parameter variable; each deeper value protects
one further member access. On an instance method, `DEPTH0` protects direct state on `this`.
Prefer `DEPTHn_OR_GREATER` for a depth and every deeper depth, or the default `ALL` only when the
whole reachable graph is truly non-mutating. Do not apply `[Const]` to an `out` parameter.

## Apply the contract deliberately

Use a parameter contract for caller-owned objects, a method contract for instance or static state,
and `AsConst.Local` for a scoped read-only alias. Apply a contract only when all reachable behavior
at the selected depth satisfies it.

## Verify the result

Treat a diagnostic on an external call as an unresolved proof obligation until that API's behavior
is established.
