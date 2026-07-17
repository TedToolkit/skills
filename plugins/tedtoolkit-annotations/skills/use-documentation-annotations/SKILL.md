---
name: use-documentation-annotations
description: >-
  Use TedToolkit.Annotations.Documentations to express C# API contracts, operational behavior,
  specifications, assumptions, and design rationale alongside XML documentation. Trigger only when
  the current project directly references TedToolkit.Annotations.Documentations (including a
  transitive project reference that exposes it); do not use this skill for projects that do not
  reference the package.
---

# Use TedToolkit.Annotations.Documentations

Confirm the project reference before suggesting these attributes. They document intent for tools,
tests, and maintainers; they do not change runtime behavior. XML documentation remains the
caller-facing explanation, so keep it equivalent to every material annotation.

## Workflow

1. Inspect the API's actual success and failure paths, persistent state, threading, observable
   effects, state machine, external dependencies, and tests. Annotate only specific, observable,
   durable contracts.
2. Choose the smallest attribute whose target and semantics match the contract. Draft it with the
   matching XML documentation and the test change required by any `BehaviorCase`.
3. Show the proposal and wait for explicit approval before modifying source.
4. After approval, build the project and run the relevant tests. Do not use an annotation to hide a
   defect, unsupported concurrency, ambiguous state, or missing test coverage.

## Attribute argument rule

When an attribute argument identifies a C# source symbol—such as a parameter, member, or type—use
`nameof(...)` rather than a handwritten string, for example `nameof(amount)` rather than `"amount"`.
Keep literal text only when it is the human-readable contract, rationale, state label, or other
non-symbol value required by the attribute. Attribute text may use visible Unicode, including Chinese
and ordinary full-width punctuation. Do not use non-printing or invisible Unicode characters—control
characters, format characters (for example, zero-width or bidirectional controls), U+0085,
U+2028/U+2029, or unpaired surrogates—because Rider may display them as escape sequences such as
`\u...`. XML documentation comments may use visible Unicode normally, subject to well-formed XML.
When a contract needs visual emphasis, proactively use one familiar marker with explicit explanatory
text—for example, `⚠️` for a restriction, `✅` for a guarantee, `💡` for a usage note, or `⏱️` for
blocking or timing behavior. Put it in caller-facing XML prose such as `<remarks>` or `<example>`;
do not use it as a substitute for an XML element, a symbol name, or the contract text itself.

## Choose the annotation family

| Need | Attribute | Use it when | Do not use it for |
| --- | --- | --- | --- |
| Caller must satisfy a condition | `Precondition` | A constructor, method, or parameter has a non-obvious input, state, or environment requirement. | A condition the signature or nullable type already makes clear. |
| Successful call guarantees a result | `Postcondition` | A method, constructor, parameter, or return value gains a useful guarantee after successful completion. | A fact true only on some unrecorded branch. |
| State must always remain valid | `Invariant` | A type or property has a persistent rule that maintenance must preserve. | A temporary local condition or one method's precondition. |
| Concurrency or context matters | `ThreadSafety`, `ThreadAffinity` | Concurrent-call guarantees, caller synchronization, or a required UI/dispatcher context affect use. | Vague claims such as “uses a lock” without saying what callers may do. |
| Call can stall the caller | `MayBlock` | A method, constructor, or property can synchronously wait. | An asynchronous API merely returning an incomplete task. |
| Call has an externally observable effect | `SideEffect` | It changes state, performs I/O, notifies, invokes callbacks, or changes resource lifetime. | Internal computation with no observable effect. |
| Retrying is safe | `Idempotent` | Repeating the same effective operation adds no further observable effect. | “Usually harmless” or an operation that increments, appends, charges, or publishes again. |
| A meaningful branch is a testable specification | `BehaviorCase` | A constructor or method has an important input/state condition with a concrete expected outcome. | Every ordinary branch, implementation detail, or a state transition better expressed by `StateTransition`. |
| Success changes named state | `StateTransition` | An API advances an object, workflow, or resource from one legal state to another. | Illegal transitions or exception paths; model those with `BehaviorCase`. |
| A durable reason or boundary needs preserving | `DesignDecision`, `DesignConstraint`, `Assumption` | Maintainers need a local decision, non-negotiable boundary, or unverified external fact. | Repository-wide architecture; use an ADR or architecture document. |

## Contracts: requirements, guarantees, and invariants

Use the generic precondition form whenever violating the condition throws a known exception. It
communicates the exception type to the analyzer, which can generate the matching XML `<exception>`
documentation. Put `Precondition` on the narrowest applicable method, constructor, or parameter;
put `Postcondition` on a method, constructor, parameter, or return value; put `Invariant` on a
type or property.

### One attribute, one independent rule

Write each independently meaningful `Precondition`, `Postcondition`, or `Invariant` as its own
attribute. Do not combine several rules into one compound sentence or predicate, even when they
apply to the same symbol and exception type. Separate attributes make each contractual obligation
individually visible, traceable, reviewable, and independently maintainable; a future change can
remove, relax, or test one rule without accidentally changing another.

For example, “`amount` must not be zero” and “`amount` must not be one” are two requirements, not
one “`amount` must be neither zero nor one” requirement:

```csharp
[Precondition<ArgumentOutOfRangeException>("amount must not be zero.")]
[Precondition<ArgumentOutOfRangeException>("amount must not be one.")]
public void SetAmount(int amount) { /* ... */ }
```

Apply the same rule to `Invariant` and `Postcondition`. Only keep facts together when they form one
indivisible condition whose meaning cannot be preserved if split; state that condition precisely.

```csharp
/// <exception cref="ArgumentOutOfRangeException">Thrown when <paramref name="amount"/> is not positive.</exception>
[Precondition<ArgumentOutOfRangeException>("amount must be positive.")]
[return: Postcondition("The result is greater than or equal to amount after successful completion.")]
public int Add(int amount) => _value += amount;

[Invariant("MaxConcurrency is at least 1.")]
public int MaxConcurrency { get; }
```

Use non-generic `Precondition("…", typeof(ArgumentException))` only when that shape is needed;
the supplied type must derive from `Exception`. A postcondition describes only success: document
failure behavior separately with a precondition or behavior case.

## Operational behavior

Prefer the enum overload when the library has a standard category. The text is still essential: it
names the actual lock, context, boundary, recipient, resource, or condition rather than repeating
the enum.

```csharp
[ThreadSafety(ThreadSafetyKind.CONDITIONALLY_THREAD_SAFE,
    "Concurrent reads are safe; callers synchronize writes with _gate.")]
[ThreadAffinity("Must run on the UI dispatcher that owns _view.")]
[MayBlock(MayBlockKind.SYNCHRONIZATION, "Waits to acquire _gate.")]
[SideEffect(SideEffectKind.NOTIFICATION_PUBLICATION, "Raises Changed after the value is updated.")]
[SideEffect(SideEffectKind.INSTANCE_STATE_MUTATION, "Updates _value.")]
[Idempotent]
public void Refresh() { }
```

- `ThreadSafetyKind`: `THREAD_SAFE`, `CONDITIONALLY_THREAD_SAFE`,
  `EXTERNAL_SYNCHRONIZATION_REQUIRED`, or `NOT_THREAD_SAFE`.
- `MayBlockKind`: `SYNCHRONIZATION`, `INPUT_OUTPUT`, `WAIT`, `CALLBACK`,
  `EXTERNAL_PROCESS`, or `OTHER`. Use `OTHER` only when the description precisely identifies the
  non-standard source and boundary.
- `SideEffectKind`: `INSTANCE_STATE_MUTATION`, `STATIC_STATE_MUTATION`,
  `EXTERNAL_STATE_MUTATION`, `INPUT_OUTPUT`, `NOTIFICATION_PUBLICATION`,
  `CALLBACK_INVOCATION`, `RESOURCE_ACQUISITION`, `RESOURCE_RELEASE`, or `OTHER`.
  Apply `SideEffect` more than once when effects have distinct categories.

`ThreadSafety` says whether simultaneous calls are allowed; `ThreadAffinity` says where a call may
run. They are independent and may both be necessary. `Idempotent` makes a strong promise about
observable effects, not merely the final in-memory value.

## BehaviorCase: make important branches executable specifications

Use `BehaviorCase` for a caller-relevant branch whose condition and expected outcome can be tested
directly. Write the condition as an observable setup and the expectation as a precise result. Apply
one attribute per independent case; it is valid only on a constructor or method and supports
multiple instances.

```csharp
/// <exception cref="ArgumentOutOfRangeException">Thrown when <paramref name="count"/> is negative.</exception>
[BehaviorCase("count is zero", "Returns an empty batch without invoking the processor.", hasUnitTest: true)]
[BehaviorCase<ArgumentOutOfRangeException>("count is negative", "Throws before invoking the processor.", hasUnitTest: true)]
public Batch Create(int count) { /* ... */ }
```

Use `BehaviorCase<TException>` when the expected outcome is an exception: its type argument must
derive from `Exception`, and it records that type without fragile `typeof(...)` text. The
non-generic form also accepts `exceptionType: typeof(SomeException)` when the type cannot be used as
the generic argument. Do not describe the exception twice inconsistently: its XML `<exception>`,
the behavior case condition, and the implementation must agree.

`hasUnitTest` is a coverage declaration, not a request to create a test. The bundled analyzer emits
`TAD202` for every `BehaviorCase` whose value is omitted or `false`; its code fix only changes the
attribute to `true`. Therefore:

1. Write or locate a focused test that executes the stated condition and asserts the stated result
   (including the exception type when applicable).
2. Set `hasUnitTest: true` only after that test exists and passes.
3. Keep it `false` while proposing work; after approval, add the test and annotation together.

`BehaviorCase` is source-usable in every build but is emitted into compiled metadata only if the
project defines `ANNOTATIONS_BEHAVIOR_CASE`. Define that symbol only when reflection or downstream
tooling needs to discover behavior cases; it is not required for source analysis.

```xml
<PropertyGroup>
  <DefineConstants>$(DefineConstants);ANNOTATIONS_BEHAVIOR_CASE</DefineConstants>
</PropertyGroup>
```

## State and rationale

Use `StateTransition(fromState, toState, condition: ...)` for a successful legal transition. Use a
separate typed `BehaviorCase` for an illegal state and its exception; this keeps success-state
guarantees separate from failures.

```csharp
[StateTransition("Open", "Closed", "Dispose completes successfully.")]
[BehaviorCase<ObjectDisposedException>("The resource is already closed", "Throws.", hasUnitTest: true)]
public void Close() { }
```

Use `DesignDecision(id, decision, rationale, alternatives)` for a stable local choice and link it
to an ADR or issue when one exists. Use `DesignConstraint(constraint, rationale)` for a boundary
that future changes must not cross. Use `Assumption(description)` only for an external protocol,
deployment fact, or caller convention the code relies on but cannot verify. Do not turn ordinary
implementation comments into rationale attributes.

## Verify the paired documentation

For each annotation, ensure XML documentation tells a caller the same contract in plain language:

- typed `Precondition` and `BehaviorCase<TException>` agree with `<exception>`;
- `Postcondition`, `Invariant`, and `StateTransition` say exactly when their guarantee holds;
- `ThreadSafety`, `ThreadAffinity`, and `MayBlock` name conditions and boundaries;
- every `SideEffect` names the affected state, external system, resource, or recipient; and
- every behavior case has a passing focused test before it claims coverage.

After approval, build with the analyzer and run those tests. If a contract is not observable,
specific, or durable enough to verify, leave it as clear XML documentation or an implementation
comment instead of adding an attribute.
