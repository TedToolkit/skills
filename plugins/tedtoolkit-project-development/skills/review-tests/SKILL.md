---
name: review-tests
description: >-
  Audit one test-adequacy lane for whether changed or relied-upon tests credibly prove an approved
  behavior, regression, invariant, boundary, compatibility rule, or journey. Use when
  review-implementation dispatches the lane or when the user explicitly asks for test-only scope,
  partitions, assertion strength, refactor tolerance, mocks, isolation, cleanup, parallelism,
  flakiness, or result traceability. Do not use as the complete response to a general implementation
  review. Remain read-only; do not write tests, execute them, or issue the final merge conclusion.
---

# Test Review

Determine whether the tests would fail for a material wrong implementation, not merely whether test
files and matching names exist. Return one specialist lane to `review-implementation`.

Read [testing-strategy.md](../../references/testing-strategy.md) for proof purpose, execution shape,
verification-result, and traceability rules. When the repository uses TUnit and `tunit-testing` is
available, invoke it in review mode for framework-specific layout, lifecycle, parallelism,
assertions, data sources, and mocks. Otherwise apply evidenced repository conventions and report
framework mechanics that remain unreviewed.

## Establish the review packet

Require the approved `AC-*`/`INV-*`/`STR-*`/`EXP-*` contract, the review coordinator's candidate
binding, relevant production and test code, repository test conventions, proof definition, and any
candidate-bound verification result. Independent or reusable review uses an exact range/bundle;
compact same-context review may use the captured current workspace snapshot. Do not execute commands
or infer missing results.

Use the same independence levels as `review-code`: `independent`, `compact`, or `not-established`.
A changed candidate makes the lane stale. Material Controlled risks require a fresh independent
lane; bounded low-risk work may use a compact coordinator review.

## Build the adequacy map

For every owned contract, identify only material behavior partitions: representative success,
actual boundaries, approved failure behavior, and preserved invariants. Add domain-specific risks
such as null/empty input, precision, overflow, culture, time, ordering, concurrency, or recovery only
when the contract or implementation makes them relevant. An omitted partition must be covered,
explicitly not applicable, or reported.

| Contract | Material partition | Test and execution shape | Observable oracle | Isolation/resources | Verification result | Status |
| --- | --- | --- | --- | --- | --- | --- |

Use `adequate`, `weak`, `missing`, `over-specified`, `flaky-risk`, or `unverified`. Do not use source
coverage percentage as proof of behavioral adequacy.

## Attempt to invalidate each test

Read setup, action, and assertion. Ask whether the test fails when the implementation returns a
wrong value, omits the behavior, accepts a forbidden case, throws the wrong failure, changes a
required side effect, or violates the invariant. Check that:

1. assertions observe the stable public or component boundary and are strong enough to distinguish
   the approved result;
2. interaction assertions follow an observable outcome and cover only contractually meaningful
   collaborator behavior;
3. tests tolerate equivalent private refactoring and do not encode internal call order or private
   algorithms without a real contract reason;
4. mutable state, clocks, randomness, environment, files, ports, databases, and other resources are
   isolated and cleaned up under parallel execution;
5. asynchronous assertions and lifecycle operations are awaited, and ordering/dependencies express
   real validity prerequisites rather than shared-state convenience;
6. selected commands can discover the intended tests, zero discovered tests are failure, and skips
   or external prerequisites are explicit; and
7. recorded verification belongs to the exact candidate and reports discovered, passed, failed,
   and skipped counts when available.

Recommend mutation testing only for critical deterministic logic when existing tooling or the risk
justifies its cost; absence of mutation testing is not itself a finding.

## Report findings

Use the same observed-fact, inference/impact, confidence, smallest-correction, owner, and verify
fields as `review-code`. Route missing or weak tests to `implement-change`; changed behavior or
proof standards to `design-change` or `plan-work-items`; framework mechanics to `tunit-testing` or
the applicable framework owner; and missing execution results to `verify-implementation`.

```md
# Test Review Lane

## Lane conclusion
pass | findings | blocked | stale

## Independence and scope
## Test adequacy
| Contract | Partition | Test/oracle | Isolation | Verification | Status |
| --- | --- | --- | --- | --- | --- |

## Blocking findings
## Important findings
## Suggestions
## Contradiction or decision needed
```

Complete when every owned contract and material partition has a disposition, every accepted test has
a credible oracle, and the exact candidate and verification limitations are explicit. Do not modify
files, run tests, fix findings, or announce `Ready to merge`.
