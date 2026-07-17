---
name: review-feature-change
description: >-
  Review a proposed feature change against its approved design, acceptance criteria, BehaviorCases,
  ADRs, code, tests, and documentation. Use when asked to review a feature or epic work-package
  implementation before merging; check whether code conforms to the design or specification; assess
  change readiness; trace requirements through implementation and tests; or recommend whether its
  human-facing documentation should be retained, extracted, deleted, or exceptionally archived.
  This is a read-only design-consistency review: do not modify files, run builds or tests, approve a
  pull request, or implement fixes.
---

# Review Feature Change

Review a change by evidence, not by whether its code merely looks reasonable. The question is
whether the approved behavior has been implemented, protected by appropriately expressed tests, and
documented without unrecorded design changes.

## Set the review boundary

1. Read repository guidance, the feature design or work package, BehaviorCases, acceptance criteria,
   applicable ADRs, the current diff, affected production and test code, and relevant documentation.
   For a work package, also read the parent epic index and its declared prerequisites.
2. State the reviewed revision or diff range and the documents used as the baseline.
3. If the supplied document is an epic index rather than one work package, say that an
   implementation-readiness conclusion is not possible until a work package is selected. Do not
   infer the work-package boundary from the diff.
4. If there is no approved feature design, say that this is a general code review only. Review local
   correctness and repository conventions, but do not claim that the change satisfies unspecified
   requirements.
5. Do not modify files, run builds, run tests, approve a pull request, or infer test results. Point
   to existing test code as evidence of intent, not proof that it currently passes.

## Build the traceability map

Create one row for every acceptance criterion or BehaviorCase in the selected delivery. Map it to
the implementation and test that express it. Mark a row `covered`, `missing`, `partial`, or
`deviates` and explain the evidence. Treat implementation belonging to another work package as a
design deviation even if it appears locally correct.

| Design item | Expected observable behavior | Implementation evidence | Test evidence | Status |
| --- | --- | --- | --- | --- |
| BC-01 |  |  |  | covered / missing / partial / deviates |

Do not accept a test merely because its name resembles a requirement. Read its setup, action, and
assertion to determine whether it proves the intended observable behavior.

## Review implementation against design

For every mapped item, inspect whether the code:

1. Delivers the stated acceptance behavior, including specified failure and boundary behavior.
2. Uses the approved domain terminology, state meanings, and API/data-model contracts consistently.
3. Preserves documented compatibility, dependency direction, security, migration, and rollout
   constraints where they apply.
4. Avoids unapproved behavior, hidden side effects, unrelated refactors, and new enduring technical
   decisions that should have an ADR or a design update.
5. Does not bypass an incomplete prerequisite or silently change the parent epic's dependency order.

When the implementation makes a materially different but potentially valid choice, report a design
deviation. Do not silently reinterpret the design to match code.

## Review test expression without running it

Inspect test code only; do not execute it. Check that each material BehaviorCase has an appropriate
test and that the test asserts observable behavior rather than private implementation details.
Review negative and boundary cases when the design names them. Flag a mismatched level when a test
needs real infrastructure but is presented as a unit test, or when a slow higher-level test is the
only protection for deterministic domain behavior.

Follow the repository's existing testing conventions. If the project uses TUnit, apply the
`tunit-unit-testing` conventions while reviewing its test code, but still do not run `dotnet run`.

## Review documentation consistency

Check whether the feature design, parent epic, ADR, README, migration, or rollout documentation
must be updated because of this change. A change that materially differs from an approved design is
not resolved by editing code alone: it needs an explicit design update and approval.

Perform a documentation-disposition review after tracing the implementation. For each material
document or content block, recommend one of: retain, extract to an architecture record, retain in an
ADR, retain as an active migration guide, delete after merge, or preserve as a superseded historical
record. Base the recommendation on what a future human maintainer needs to know, not on preserving
the implementation process for an AI.

Never edit, delete, move, or archive a document in this review. A recommendation to delete or
archive is not authorization: the user must decide, and the approved follow-up should be a separate,
small documentation change. Historical preservation is exceptional. `docs/history/` is not a source
of current behavior and every retained historical record must link to its replacement.

## Report findings

Use this exact report structure. Give every finding a stable ID, its evidence location, impact, and
recommended next action. Do not report style preferences as blockers.

```md
# Feature Change Review

## Conclusion
Ready to merge | Ready with follow-ups | Not ready

## Traceability
| Design item | Implementation | Test | Status |
| --- | --- | --- | --- |

## Blocking findings
- [B1] <finding> — Evidence: <file or design item>. Impact: <impact>. Action: <next action>.

## Important findings
- [I1] <finding> — Evidence: <file or design item>. Impact: <impact>. Action: <next action>.

## Suggestions
- [S1] <finding> — Evidence: <file or design item>. Action: <optional improvement>.

## Design deviations
- <approved design differs from implementation, cross-work-package scope expansion, or none found>

## Documentation disposition
| Document or content | Recommendation | Reason | Required follow-up |
| --- | --- | --- | --- |
|  | Retain / extract / ADR / migration / delete / history |  | Human decision or separate change |

## Review scope and limits
- Reviewed: <diff/revision and documents>.
- Not run: builds or tests.
- Not reviewed: <out-of-scope area, if any>.
```

Choose the conclusion from the findings:

- **Not ready** when a Blocking finding exists: an acceptance criterion is unmet, a material
  BehaviorCase lacks protection, compatibility or a stated constraint is broken, a prerequisite is
  bypassed, or the code materially deviates from approved design.
- **Ready with follow-ups** when no blocker exists but Important findings require ownership before
  or soon after merge.
- **Ready to merge** only when the traceability map is complete, no material design deviation
  remains, and no blocking or important finding is open.

Hand fixes to `implement-feature-tdd`; hand a material design decision or design deviation to
`feature-design`. Hand an unbounded delivery to `decompose-feature-epic`. Keep the review
independent by not fixing the code in this skill.
