---
name: use-ownership-annotations
description: >-
  Use TedToolkit.Annotations.Ownership to document disposable-resource ownership transfer and callback
  lifetime in C#. Trigger only when the current project directly references TedToolkit.Annotations.Ownership
  (including a transitive project reference that exposes it); do not use this skill for projects that do not reference the package.
---

# Use TedToolkit.Annotations.Ownership

Confirm the package reference before suggesting these attributes. Pair every material ownership
annotation with XML documentation that tells callers who disposes the resource.

## Workflow

1. Trace each `IDisposable` or `IAsyncDisposable` value across the API boundary. Establish whether the
   caller retains responsibility, transfers it, or receives a borrowed value; inspect disposal paths.
2. Draft the smallest matching `Ownership` or `CallbackLifetime` annotation and corresponding XML
   text. Show it and wait for explicit approval before editing.
3. After approval, run the bundled analyzer or project tests. Do not use an attribute to conceal a
   double-dispose, leak, or unclear lifetime.

## Attribute argument rule

When an attribute argument identifies a C# source symbol, write it with `nameof(...)` instead of a
handwritten string. Use literal strings only where the attribute requires a non-symbol value.
Attribute text may use visible Unicode, including Chinese and ordinary full-width punctuation. Do
not use non-printing or invisible Unicode characters: control or format characters (such as
zero-width or bidirectional controls), U+0085, U+2028/U+2029, or unpaired surrogates. Rider may
display them as escape sequences such as `\u...`. XML documentation comments may use Unicode
normally, subject to well-formed XML.

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

Trace normal, exceptional, cancellation, replacement, and disposal paths. The XML comment must state
who disposes each resource in plain language, and the attribute must match that statement. Run the
bundled analyzer after approval; do not silence lifetime diagnostics by changing annotations unless the
actual ownership contract has changed.
