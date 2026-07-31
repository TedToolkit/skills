---
name: use-ownership-annotations
description: >-
  Specify disposable-resource ownership transfer and callback lifetime with
  TedToolkit.Annotations.Ownership. Use when a project that references the package exposes borrowed,
  transferred, stored, deferred, or subscription-lifetime values across a C# API boundary.
---

# Use TedToolkit.Annotations.Ownership

Make responsibility and lifetime explicit at the API boundary. Read
[attribute-arguments.md](../../references/attribute-arguments.md) before drafting annotation text.
Invoke `use-const-annotations` for an independent non-mutation contract,
`use-documentation-annotations` for operational behavior, and `write-csharp-api-comments` for
caller-facing XML. This skill retains ownership and lifetime semantics.

## Steps

1. Confirm that the active project references `TedToolkit.Annotations.Ownership`; otherwise report
   the failed package gate.
2. Trace every in-scope disposable and callback through normal return, exception, cancellation,
   replacement, and disposal paths. Complete when each path names the responsible owner and lifetime.
3. Draft the smallest matching `Ownership` or `CallbackLifetime` annotation with equivalent XML
   text. Show it and wait for explicit approval before editing.
4. After approval, run the analyzer and affected tests. Complete when every path has exactly one
   disposal responsibility, callback escape is represented, and no leak or double-dispose is hidden.

## Usage

Returns and `out` parameters transfer ownership by default; ordinary parameters and property getters
borrow by default. State a non-default contract explicitly:

```csharp
public void Store([Ownership(OwnershipKind.TRANSFERRED)] IDisposable item) => _item = item;

[return: Ownership(OwnershipKind.UNCHANGED)]
public Stream GetSharedStream() => _stream;

public void Subscribe([CallbackLifetime(CallbackLifetimeKind.SUBSCRIPTION)] Action handler) => _handlers += handler;
```

For `ref` parameters and properties, specify `OwnershipFlow.INPUT` or `OwnershipFlow.OUTPUT` when
the two directions differ. Use `IMMEDIATE` for a callback invoked before the method returns,
`DEFERRED` for later invocation, and `SUBSCRIPTION` for retention until unsubscription or disposal.

## Decide the boundary contract

Use `TRANSFERRED` when responsibility to dispose crosses into or out of the API. Use `UNCHANGED` when
a value remains borrowed despite a boundary default that would imply transfer. Annotate fields when a
type stores and later disposes a resource. For callbacks, use `IMMEDIATE` only when invocation cannot
outlive the call; use `DEFERRED` or `SUBSCRIPTION` when the delegate can escape.

## Verify ownership documentation

The XML comment states who disposes each resource in plain language and matches the annotation.
Change an annotation only when the actual ownership contract changes.
