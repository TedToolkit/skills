---
name: use-maintenance-annotations
description: >-
  Record actionable C# workarounds, temporary implementations, technical debt, and cleanup triggers
  with TedToolkit.Annotations.Maintenance. Use when a project that references the package contains
  a deliberate compromise with a concrete cause and removal condition.
---

# Use TedToolkit.Annotations.Maintenance

Turn a deliberate compromise into a removable maintenance record. Read
[attribute-arguments.md](../../references/attribute-arguments.md) before drafting its text.
Invoke `use-documentation-annotations` for an independent API contract and
`write-csharp-api-comments` for its caller-facing explanation. This skill retains the maintenance
record.

## Steps

1. Confirm that the active project references `TedToolkit.Annotations.Maintenance`; otherwise
   report the failed package gate.
2. Establish the compromise's external cause or trade-off, affected behavior or cost, owner, and
   objective removal trigger. Complete when all four are explicit.
3. Choose the narrowest declaration and most specific annotation. Show the complete proposed record
   and wait for explicit approval before editing.
4. After approval, build with the analyzer. Complete when the annotation remains beside its cause
   and the trigger is specific enough to decide whether removal is due.

## Selection guide

- Use `Workaround` for a named external defect or compatibility limitation.
- Use `TemporaryImplementation` for intentional incomplete behavior.
- Use `TechnicalDebt` with `DESIGN`, `COMPATIBILITY`, `PERFORMANCE`, or `RELIABILITY` for an explicit trade-off.
- Use `CleanupRequired` for code with a concrete cleanup trigger.

```csharp
[TechnicalDebt(TechnicalDebtKind.PERFORMANCE,
    "Replace the linear scan when the collection exceeds 1,000 items; tracked by #123.")]
```

Use the annotation instead of an ownerless `TODO`, `FIXME`, or `HACK`. Define
`ANNOTATIONS_MAINTENANCE` only when reflection or downstream tooling needs compiled metadata.

## Write actionable maintenance records

Prefer a version, measurable threshold, migration milestone, or issue identifier over an indefinite
promise.

## Review and removal

When the removal condition is met, remove the cause and annotation in the same change. Treat vague
reasons such as "temporary" or "fix later" as incomplete records.
