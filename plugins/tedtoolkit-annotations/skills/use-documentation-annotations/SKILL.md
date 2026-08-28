---
name: use-documentation-annotations
description: >-
  Specify observable C# API contracts, operational behavior, behavior cases, state transitions,
  assumptions, and local design rationale with TedToolkit.Annotations.Documentations. Use when a
  project that references the package needs machine-readable intent paired with XML documentation.
---

# Use TedToolkit.Annotations.Documentations

Make one observable contract explicit at a time. Annotations supply machine-readable intent and XML
documentation remains the caller-facing contract.

Invoke `write-csharp-api-comments` for caller-facing XML. Invoke the matching annotation skill for
an independent ownership, const, maintenance, or boxing contract; this skill retains the observable
behavior contract.

## Steps

1. Confirm that the active project references `TedToolkit.Annotations.Documentations`; otherwise
   report the failed package gate.
2. Inventory the in-scope success and failure paths, persistent state, threading, effects, state
   transitions, external dependencies, and tests. Complete when every proposed contract has
   observable evidence and every material branch is accounted for.
3. Read [annotation-catalog.md](references/annotation-catalog.md) for each relevant contract family
   and [attribute-arguments.md](../../references/attribute-arguments.md) before drafting text.
4. Choose the narrowest target and one attribute per independent rule. Draft equivalent XML
   documentation and a focused test for each `BehaviorCase`; keep `hasUnitTest: false` until the
   exact intended test has executed successfully with non-zero discovery and reported
   passed/failed/skipped counts. A test name, source inspection, prompt claim, skipped run, failing
   run, or zero-discovery result is not proof.
   When that test project uses TUnit and `tunit-testing` is available, invoke it for the test
   expression while this skill retains ownership of the `BehaviorCase` contract.
5. Show the complete proposal and wait for explicit approval before modifying source or tests.
6. After approval, build with the analyzer and run the focused tests. Complete when every annotation
   matches runtime behavior and XML prose, every claimed behavior case passes, and all remaining
   diagnostics are reported.

## Verify the paired documentation

For each annotation, require the following paired evidence:

- typed `Precondition` and `BehaviorCase<TException>` agree with `<exception>`;
- `Postcondition`, `Invariant`, and `StateTransition` say exactly when their guarantee holds;
- `ThreadSafety`, `ThreadAffinity`, and `MayBlock` name conditions and boundaries. Emit one
  `MayBlock` per independently applicable wait category: synchronous I/O is
  `MayBlockKind.INPUT_OUTPUT` even when the same method also waits for synchronization;
- every `SideEffect` names the affected state, external system, resource, or recipient; and
- every behavior case has a fresh passing focused-test result, including non-zero discovery and
  passed/failed/skipped counts, before it claims coverage.

A contract that is not observable, specific, and durable remains XML documentation or a focused
implementation comment rather than an annotation.
