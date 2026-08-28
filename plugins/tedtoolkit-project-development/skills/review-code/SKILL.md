---
name: review-code
description: >-
  Audit one production-code correctness lane against an approved delivery contract and its actual
  risk. Use when review-implementation dispatches the lane or when the user explicitly asks for
  code-only correctness, failure semantics, compatibility, dependency direction, resource,
  concurrency, maintainability, or scope review. Do not use as the complete response to a general
  implementation-review request. Remain read-only; do not review test adequacy, execute verification,
  fix findings, or issue the final merge conclusion.
---

# Code Review

Try to falsify the implementation's claim of correctness. Return one evidence-first specialist
lane to `review-implementation`; do not duplicate test-quality review or final delivery synthesis.

Read [change-development-workflow.md](../../references/workflow/change-development-workflow.md) for
the approved boundary and
[agent-orchestration.md](../../references/orchestration/agent-orchestration.md) when a fresh
review agent is used.

## Establish the review packet

Require the approved Fast plan, change, or selected work item; repository guidance; affected
production/configuration artifacts; and the review coordinator's candidate binding. Independent or
reusable review uses an exact range/bundle; compact same-context review may use the captured current
workspace snapshot. Do not reconstruct a missing behavior contract from the diff.

State the independence level:

- `independent`: a fresh context that did not implement the candidate, has no write task, and reviews
  the exact candidate;
- `compact`: the delivery coordinator performs the lane for a bounded low-risk change; or
- `not-established`: candidate binding or separation is insufficient.

Never claim independence merely because the report uses review language. A changed candidate makes
the lane stale. Controlled public or persisted contracts, security, migration, concurrency, shared
boundaries, or other difficult-to-reverse behavior require `independent`; report their absence as
Blocking.

## Review by attempting disproof

For each owned `AC-*`, `INV-*`, `STR-*`, or `EXP-*`, inspect the implementation or experiment artifact and
ask which realistic input, state,
failure, cancellation, interleaving, or dependency response could violate it. Check only applicable
risks:

1. approved success, failure, boundary behavior, and preserved invariants;
2. public API, serialization, persistence, protocol, and compatibility changes;
3. error, cancellation, timeout, partial-failure, and recovery semantics;
4. disposable/resource ownership, callbacks, subscriptions, and cleanup;
5. shared mutable state, concurrency, ordering, and reentrancy;
6. dependency direction, security, migration, rollout, and operational constraints;
7. cohesion, unnecessary complexity, duplication, dead code, and misleading names when they create
   a concrete maintenance or correctness cost; and
8. unrelated edits, debug artifacts, hidden side effects, or an unrecorded enduring decision.

Do not turn preferences, hypothetical style improvements, generic security advice, or missing test
layers into findings. Do not accept a green test name as code-correctness evidence; test adequacy is
owned by `review-tests`.

Evaluate implementation shape against present evidence, not raw code size. For every added type,
member, abstraction, or widened access level that materially affects maintainability, determine its
actual responsibility, caller, lifecycle, policy, or boundary and whether a simpler shape would
preserve cohesion and the approved contract. In particular, check for single-use wrappers, trivial
forwarding methods, speculative interfaces or factories, fragmented control flow, and production
visibility widened only for tests. Treat a new or widened public or protected surface outside the
approved contract as a design deviation. Report unnecessary structure only when it creates a
concrete cost such as extra public surface, duplicated paths, obscured ownership, navigation without
separation, or additional state/lifecycle burden. Do not issue findings solely because a class or
method is long, an interface has one implementation, or a personal count threshold was exceeded.

When changed C# code adds or changes a framework guard, custom throwing helper, exception factory,
or exception-path performance claim, read
[csharp-exception-paths.md](../../references/code-quality/csharp-exception-paths.md). Check the
caller-visible failure contract, target-framework compatibility, helper ownership, and evidence for
any code-size, inlining, or performance claim. A direct `throw` is not a finding by itself.

For each new or materially changed production callable, or when the review packet contains a
cognitive-complexity result, read
[cognitive-complexity.md](../../references/code-quality/cognitive-complexity.md). Treat `15` as an
advisory starting point only when the repository defines no numeric policy. Any explicit repository
threshold is authoritative whether stricter or looser. Cite its source and analyzer evidence for a
numeric violation; without measurable evidence, report only the concrete control-flow burden and
request the repository gate under `Verify`, never an invented score or mandatory exception. Do not
confuse this quality signal with a personal method-length preference, and do not recommend
fragmenting cohesive logic merely to reduce a score.

## Make findings falsifiable

Separate what was observed from what is inferred:

```md
- [B1|I1|S1] <finding>
  - Observed fact: <source location and exact condition>
  - Inference and impact: <contract or risk consequence>
  - Confidence and basis: high | medium | low — <why the cited source supports it>
  - Smallest correction: <bounded change>
  - Owner: design-change | plan-work-items | implement-change | other
  - Verify: <inspection or proof needed>
```

Use Blocking only when the approved result, a governing constraint, required independence, or merge
safety is not met. Use Important for a material non-blocking risk and Suggestion for optional value.
Route changed behavior or governing contracts to `design-change`, changed item boundaries to
`plan-work-items`, and conforming implementation defects to `implement-change`.

## Return the specialist lane

```md
# Code Review Lane

## Lane conclusion
pass | findings | blocked | stale

## Independence and scope
- Level:
- Baseline/candidate:
- Reviewed artifacts:
- Not reviewed:

## Contract and risk coverage
| Contract or risk | Attempted counterexample | Implementation location | Status |
| --- | --- | --- | --- |

## Blocking findings
## Important findings
## Suggestions
## Contradiction or decision needed
```

Complete when every applicable contract/risk has a disposition, every finding cites primary source
material, and the handoff identifies its exact candidate. Do not modify files, run builds or tests,
approve a pull request, or announce `Ready to merge`.
