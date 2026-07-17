---
name: use-maintenance-annotations
description: >-
  Use TedToolkit.Annotations.Maintenance to record deliberate C# workarounds, temporary
  implementations, technical debt, and cleanup work. Trigger only when the current project directly
  references TedToolkit.Annotations.Maintenance (including a transitive project reference that exposes it);
  do not use this skill for projects that do not reference the package.
---

# Use TedToolkit.Annotations.Maintenance

Confirm the package reference first. If absent, do not suggest maintenance attributes from this package.

## Workflow

1. Verify that the workaround or debt is real and identify its cause, affected behavior, and removal
   condition or tracking issue.
2. Choose the most specific annotation, draft the reason as an actionable complete sentence, and show
   it for approval before modifying source.
3. After approval, keep it on the affected code and remove it in the same change that removes its cause.

## Attribute argument rule

Use `nameof(...)` rather than a handwritten string when an attribute argument identifies a C# source
symbol. Keep literal strings for the actionable maintenance rationale and other non-symbol values.
Attribute text may use visible Unicode, including Chinese and ordinary full-width punctuation. Do
not use non-printing or invisible Unicode characters: control or format characters (such as
zero-width or bidirectional controls), U+0085, U+2028/U+2029, or unpaired surrogates. Rider may
display them as escape sequences such as `\u...`. XML documentation comments may use Unicode
normally, subject to well-formed XML.

## Selection guide

- Use `Workaround` for a named external defect or compatibility limitation.
- Use `TemporaryImplementation` for intentional incomplete behavior.
- Use `TechnicalDebt` with `DESIGN`, `COMPATIBILITY`, `PERFORMANCE`, or `RELIABILITY` for an explicit trade-off.
- Use `CleanupRequired` for code with a concrete cleanup trigger.

```csharp
[TechnicalDebt(TechnicalDebtKind.PERFORMANCE,
    "Replace the linear scan when the collection exceeds 1,000 items; tracked by #123.")]
```

Do not replace this with an ownerless `TODO`, `FIXME`, or `HACK`. Define `ANNOTATIONS_MAINTENANCE`
only when the attributes must be retained in compiled metadata for reflection or downstream tools.

## Write actionable maintenance records

State the external cause or intentional trade-off, the affected behavior or cost, and the event that
allows removal. Prefer a version, measurable threshold, migration milestone, or issue identifier over
an indefinite promise. Put the annotation on the narrowest affected declaration; do not mark a whole
type for a single method-level workaround.

## Review and removal

During review, reject vague reasons such as "temporary" or "fix later". When the removal condition is
met, remove both the workaround and its annotation in the same change. Retain metadata conditionally
only when reflection or downstream tooling needs to inspect it after compilation.
