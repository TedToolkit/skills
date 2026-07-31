# Documentation annotation catalog

Read the sections that match the contract being documented.

## Contract annotations

| Need | Attribute | Boundary |
| --- | --- | --- |
| Caller requirement | `Precondition` | Constructor, method, or parameter |
| Successful-call guarantee | `Postcondition` | Constructor, method, parameter, or return value |
| Persistent state rule | `Invariant` | Type or property |
| Caller-relevant branch | `BehaviorCase` | Constructor or method |
| Successful legal state change | `StateTransition` | Method |

Use a generic `Precondition<TException>` or `BehaviorCase<TException>` when violation has a known
exception type. The type must derive from `Exception`. Keep the condition, expected result,
implementation, and XML `<exception>` semantically identical.

Write one attribute for each independently testable rule. Keep facts together only when separating
them would destroy the condition's meaning.

```csharp
/// <exception cref="ArgumentOutOfRangeException">
/// Thrown when <paramref name="amount"/> is not positive.
/// </exception>
[Precondition<ArgumentOutOfRangeException>("amount must be positive.")]
[return: Postcondition("The result is at least amount after successful completion.")]
public int Add(int amount) => _value += amount;
```

For `BehaviorCase`, state an observable setup and a precise outcome. `hasUnitTest: true` is a
coverage claim: set it only after a focused passing test executes that condition and asserts that
outcome. Leave it `false` in a proposal that still needs its test.

```csharp
[BehaviorCase("count is zero", "Returns an empty batch without invoking the processor.",
    hasUnitTest: true)]
[BehaviorCase<ArgumentOutOfRangeException>("count is negative",
    "Throws before invoking the processor.", hasUnitTest: true)]
public Batch Create(int count) { /* ... */ }
```

Use `StateTransition(fromState, toState, condition: ...)` for successful legal transitions. Express
an illegal transition and its exception as a separate typed `BehaviorCase`.

Define `ANNOTATIONS_BEHAVIOR_CASE` only when reflection or downstream tooling needs compiled
`BehaviorCase` metadata.

## Operational annotations

| Need | Attribute | Required precision |
| --- | --- | --- |
| Concurrent-call contract | `ThreadSafety` | Name safe operations and required synchronization |
| Required execution context | `ThreadAffinity` | Name the owning thread or dispatcher |
| Synchronous waiting | `MayBlock` | Name the wait source and boundary |
| Observable effect | `SideEffect` | Name affected state, system, resource, callback, or recipient |
| Safe repetition | `Idempotent` | Cover every observable effect of repetition |

Prefer the standard enum category and use text to name the specific boundary:

```csharp
[ThreadSafety(ThreadSafetyKind.CONDITIONALLY_THREAD_SAFE,
    "Concurrent reads are safe; callers synchronize writes with _gate.")]
[MayBlock(MayBlockKind.SYNCHRONIZATION, "Waits to acquire _gate.")]
[SideEffect(SideEffectKind.NOTIFICATION_PUBLICATION,
    "Raises Changed after the value is updated.")]
public void Refresh() { }
```

`ThreadSafetyKind` values are `THREAD_SAFE`, `CONDITIONALLY_THREAD_SAFE`,
`EXTERNAL_SYNCHRONIZATION_REQUIRED`, and `NOT_THREAD_SAFE`.

`MayBlockKind` values are `SYNCHRONIZATION`, `INPUT_OUTPUT`, `WAIT`, `CALLBACK`,
`EXTERNAL_PROCESS`, and `OTHER`. Use `OTHER` with a precise non-standard source.

`SideEffectKind` values are `INSTANCE_STATE_MUTATION`, `STATIC_STATE_MUTATION`,
`EXTERNAL_STATE_MUTATION`, `INPUT_OUTPUT`, `NOTIFICATION_PUBLICATION`, `CALLBACK_INVOCATION`,
`RESOURCE_ACQUISITION`, `RESOURCE_RELEASE`, and `OTHER`. Use separate attributes for distinct
categories.

Thread safety and thread affinity are independent contracts. Idempotence covers observable effects,
not only the final in-memory value.

## Rationale annotations

Use:

- `DesignDecision(id, decision, rationale, alternatives)` for a stable local choice;
- `DesignConstraint(constraint, rationale)` for a local boundary future changes must preserve;
- `Assumption(description)` for an external fact the code relies on but cannot verify.

Keep repository-wide decisions in an ADR or architecture record. Keep ordinary implementation
explanation in a focused comment.

