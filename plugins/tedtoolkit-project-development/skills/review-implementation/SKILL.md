---
name: review-implementation
description: >-
  Review a proposed implementation against its approved change, acceptance criteria, BehaviorCases,
  code, tests, and directly affected documentation. Use when asked to review an implementation,
  feature, fix, refactor, migration, or change work-package before merging; check whether code
  conforms to an approved design or specification; assess implementation readiness; trace
  requirements through implementation and tests; or recommend whether its human-facing
  documentation should be retained, extracted, deleted, or exceptionally archived.
  This is a read-only design-consistency review: do not modify files, run builds or tests, approve a
  pull request, or implement fixes.
---

# Implementation Review

Review implementation by evidence, not by whether its code merely looks reasonable. The question is
whether the approved change has been implemented, protected by appropriately expressed tests, and
documented without unrecorded design changes. Principles and architecture are reviewed when the
architecture or change design is approved; do not reopen them during final implementation review.

This skill owns read-only conformance review. It consumes the approved work item and its declared
governing records; it does not reinterpret product intent, principles, architecture, or ADRs. Route
a missing or changed product-intent constraint to `library-product-intent` through `change-design`,
and route a delivery-plan defect to `plan-work-items` or an implementation fix to
`implement-change-tdd`.

## Set the review boundary

1. Read repository guidance, the approved change index and selected work package, BehaviorCases,
   acceptance criteria, the current diff, affected production and test code, and directly affected
   documentation. For a work package, also read its parent change index and declared prerequisites.
2. State the reviewed revision or diff range and the documents used as the baseline.
3. If the supplied document is a change index rather than one work package, say that an
   implementation-readiness conclusion is not possible until a work package is selected. Do not
   infer the work-package boundary from the diff.
4. If there is no approved change design, say that this is a general code review only. Review local
   correctness and repository conventions, but do not claim that the change satisfies unspecified
   requirements.
5. Do not modify files, run builds, run tests, approve a pull request, or infer test results. Point
   to existing test code as evidence of intent, not proof that it currently passes.

Before reviewing code, check the selected work item's delivery contract. Report a blocking
finding when it has more than one independently observable outcome, lacks an objective definition
of done, omits a verification mapping for a material BehaviorCase, or cannot identify its logical
prerequisites and recommended execution sequence. Report a blocking finding when completion evidence
for an earlier prerequisite is absent but the reviewed implementation has begun. Do not reconstruct
the missing contract from the diff.

Also check that the parent change names exactly one result-oriented change goal and that every
BehaviorCase and selected work-item outcome contributes to it. Report a blocking finding when the
goal is missing, is merely an implementation task, or the package serves an unrelated result. Hand
such defects to `change-design`; do not invent or rename the goal during review.

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
3. Preserves the compatibility, dependency direction, security, migration, and rollout constraints
   made explicit in the approved change.
4. Avoids unapproved behavior, hidden side effects, unrelated refactors, and new enduring technical
   decisions that should have an ADR or a design update.
5. Does not bypass an incomplete prerequisite or silently change the parent change's dependency order.
6. Satisfies every objective definition-of-done criterion, including recorded passing verification
   evidence, required documentation or migration state, actual effort, and any material estimate
   variance. Treat missing effort or variance alone as a planning follow-up; treat missing required
   verification or delivery evidence as blocking because it cannot unlock the next package.

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

Check whether the change design, parent change, README, migration, rollout documentation, or a
declared product-intent record must be updated because of this change. A change that materially
differs from an approved design is not resolved by editing code alone: it needs an explicit
change-design update and approval. When the approved change itself lacks a necessary constraint,
hand it to `change-design`; do not infer the missing product, principle, or architecture rule from
the implementation.

Perform a documentation-disposition review after tracing the implementation. For each material
document or content block, recommend one of: retain, retain in an ADR, retain as an active migration
guide, or delete after merge. Base the recommendation on what a future human maintainer needs to
know, not on preserving the implementation process for an AI.

Before recommending deletion of a completed change, perform a documentation-extraction check.
Identify every durable decision introduced or changed by the delivery, every current cross-cutting
semantic that a future maintainer needs, and every still-active migration or operational procedure.
Verify respectively that it is captured in an accepted ADR, a current architecture record, or an
active migration guide or runbook. Mark each category `not needed`, `captured`, or `missing` with
evidence. Do not use an ADR as an archive for the change; capture only a durable decision and its
rationale. A missing extraction is an Important finding and requires `architecture-design` or the
appropriate documentation owner before change deletion can be recommended.

Ask for a change-closure decision only when all of the following are true: the conclusion is
`Ready to merge`; the selected work package completes the parent change; and completion evidence
exists for every other planned work package; and every documentation-extraction category is `not
needed` or `captured`. Ask once, at the end of the report, whether the parent
`docs/changes/<change>/` directory should be deleted after merge, retained, or first distilled into
an ADR, architecture record, or active migration guide. Recommend deletion by default when nothing
needs retaining. Do not ask this question for a partial work package, `Ready with follow-ups`, or
`Not ready` review. Do not infer completion merely from a clean-looking diff. A user decision to
delete is approval for a separate, small documentation cleanup after merge; it is never permission
to delete during this read-only review.

Never edit, delete, or move a document in this review. A recommendation to delete is not
authorization: the user must decide, and the approved follow-up should be a separate, small
documentation change. Use Git history for documents that no longer guide current behavior.

## Report findings

Use this exact report structure. Give every finding a stable ID, evidence location, impact, and a
concrete modification recommendation. Explain the smallest change that resolves the finding, the
owner skill (`change-design`, `plan-work-items`, or `implement-change-tdd`), and the verification
that proves the recommendation worked. Do not report style preferences as blockers or prescribe an
unapproved redesign.

```md
# Implementation Review

## Conclusion
Ready to merge | Ready with follow-ups | Not ready

## Traceability
| Design item | Implementation | Test | Status |
| --- | --- | --- | --- |

## Blocking findings
- [B1] <finding> — Evidence: <file or design item>. Impact: <impact>. Suggested change: <smallest
  acceptable modification>. Owner: <skill>. Verify: <inspection, test, or command>.

## Important findings
- [I1] <finding> — Evidence: <file or design item>. Impact: <impact>. Suggested change: <smallest
  acceptable modification>. Owner: <skill>. Verify: <inspection, test, or command>.

## Suggestions
- [S1] <finding> — Evidence: <file or design item>. Suggested change: <optional improvement>.
  Owner: <skill or human>. Verify: <inspection, test, or command>.

## Design deviations
- <approved design differs from implementation, cross-work-package scope expansion, or none found>

## Documentation extraction
| Required knowledge | Durable location | Evidence | Status |
| --- | --- | --- | --- |
| Decision / current semantic / active procedure | ADR / architecture / migration guide |  | not needed / captured / missing |

## Documentation disposition
| Document or content | Recommendation | Reason | Required follow-up |
| --- | --- | --- | --- |
|  | Retain / ADR / migration / delete |  | Human decision or separate change |

## Change closure decision
<Include only for a complete parent change that is Ready to merge and has no missing extraction:
should `docs/changes/<change>/` be deleted after merge? Recommend deletion unless the disposition
identifies an active record to retain, then wait for the user's decision.>

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

Hand implementation fixes to `implement-change-tdd`, delivery-plan defects to `plan-work-items`,
and material design decisions or deviations to `change-design`. Keep the review independent by not
fixing the code in this skill.
