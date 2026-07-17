---
name: use-const-annotations
description: >-
  Use TedToolkit.Annotations.Const to document and verify C# object-graph non-mutation contracts.
  Trigger only when the current project directly references TedToolkit.Annotations.Const (including a
  transitive project reference that exposes it); do not use this skill for projects that do not reference the package.
---

# Use TedToolkit.Annotations.Const

Confirm that the active project references `TedToolkit.Annotations.Const`. Otherwise, do not suggest
`[Const]`, `ConstDepth`, or `AsConst`.

## Workflow

1. Inspect writes and invoked members to establish the real mutation boundary; do not infer
   immutability from a method name alone.
2. Draft the narrowest accurate contract, present it with corresponding XML documentation, and wait
   for explicit approval before editing source.
3. Build or run the analyzer after approval. Correct the contract or mutation; never weaken a true
   contract without explaining the behavioral change.

## Attribute argument rule

Use `nameof(...)` instead of a handwritten string whenever an attribute argument identifies a C#
source symbol. Literal strings remain appropriate only for non-symbol values required by the
attribute. Attribute text may use visible Unicode, including Chinese and ordinary full-width
punctuation. Do not use non-printing or invisible Unicode characters: control or format characters
(such as zero-width or bidirectional controls), U+0085, U+2028/U+2029, or unpaired surrogates.
Rider may display them as escape sequences such as `\u...`. XML documentation comments may use
Unicode normally, subject to well-formed XML.

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

Use a parameter contract when the caller-owned object must not be mutated, a method contract when
the method must not mutate its own instance or static state, and `AsConst.Local` for a local alias
that must remain read-only within a scope. Before choosing a depth, trace assignments through fields,
properties, helper calls, and aliases. Document the observable non-mutation guarantee in XML when it
is material to callers; do not label a method `Const` merely because it usually reads state today.

## Verify the result

Compile with the bundled analyzer and inspect diagnostics at the selected depth. Check overrides and
interface implementations because their contracts compose. Treat an analyzer warning about an external
call as a request to confirm behavior, not as proof that the external API is safe.
