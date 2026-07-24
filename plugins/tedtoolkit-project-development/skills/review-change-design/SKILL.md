---
name: review-change-design
description: >-
  Review a draft or approved change-design document before delivery planning or implementation. Use
  when asked whether a change design, change proposal, BehaviorCases, scope, constraints, risks,
  completion criteria, or estimate is correct, complete, internally consistent, and ready for human
  approval; or when a change document needs an independent read-only review. Do not review code,
  tests, work items, or implementation readiness; use review-implementation after delivery.
---

# Change-Design Review

Review the behavioral contract before it becomes the basis for delivery planning. This skill reviews
the change document, not the implementation that may later satisfy it. It is independent and
read-only: do not edit the draft, create work items, run commands, approve the change, or begin
implementation.

## Set the boundary

1. Read repository guidance, the submitted change design, its cited product-intent record,
   principles, architecture records, ADRs, and directly affected current documentation.
2. State the reviewed document revision and governing-record revisions. Do not infer an unstated
   product requirement from code, a diff, or a later work item.
3. If no change design exists, say that a design review cannot proceed and route drafting to
   `change-design`.
4. Do not inspect implementation code or tests as evidence that the proposal is delivered. Existing
   code may be read only to test the document's stated status quo and compatibility claims.

## Review the contract

Check that the document has exactly one result-oriented change goal. It must state the user-visible
outcome, not an API name, file change, or implementation task. Verify that every scope item,
BehaviorCase, completion criterion, and stated approach contributes to that one goal. Recommend
separate changes for independently releasable outcomes.

Check the following against the cited evidence:

1. Scope, non-goals, compatibility, and status quo are explicit and do not conflict.
2. BehaviorCases cover material success, failure, and boundary behavior with observable outcomes.
3. Governing records are pinned and their resulting constraints are restated rather than merely
   linked.
4. The proposed approach, alternatives, risks, migration or rollback treatment, and unresolved
   questions are proportionate to the change's reversibility and impact.
5. Completion criteria are observable, and the planning estimate states its range, assumptions,
   exclusions, confidence, and re-estimation trigger.
6. The document contains no delivery sequencing, work-item contracts, or implementation steps.
   Route these to `plan-work-items` after the design is approved.
7. Every material, enduring, or difficult-to-reverse technical choice has an accepted ADR linked
   from the change. A proposed or missing ADR is a blocking finding: route it to
   `architecture-design` now, then revise the change with the accepted ADR's constraints. Do not
   approve a change first and defer its ADR to implementation review.

Treat a missing behavioral constraint, ambiguous outcome, conflicting governing record, missing
material risk, or required ADR as a blocking design finding. Do not fix it in this skill; route the
smallest revision to `change-design` or `architecture-design`. A human, not this review, approves a
design after blocking findings are closed.

## Report

Use this exact structure. Give each finding a stable ID, evidence, impact, smallest revision, and
owner. Do not report implementation preferences or ask about documentation deletion.

```md
# Change-Design Review

## Conclusion
Ready for approval | Needs revision

## Contract traceability
| Contract item | Evidence | Status |
| --- | --- | --- |
| Change goal |  | covered / missing / partial / conflicts |

## Blocking findings
- [B1] <finding> — Evidence: <document section or governing record>. Impact: <impact>. Suggested
  revision: <smallest change>. Owner: change-design / architecture-design. Verify: <inspection or
  approval check>.

## Important findings
- [I1] <finding> — Evidence: <document section or governing record>. Impact: <impact>. Suggested
  revision: <smallest change>. Owner: change-design. Verify: <inspection or approval check>.

## Design boundary
- Not reviewed: implementation, tests, work items, builds, and merge readiness.

## Review scope and limits
- Reviewed: <change design and governing records>.
- Not run: commands, builds, or tests.
```

Choose `Needs revision` when a Blocking finding exists. Choose `Ready for approval` only when the
contract is complete and internally consistent with its governing records. The latter is a request
for human approval, not approval itself. After explicit approval, hand delivery planning to
`plan-work-items`; after implementation, hand conformance review to `review-implementation`.
