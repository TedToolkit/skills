---
name: review-implementation
description: >-
  Trace an implementation against its approved work item, behavior cases, code, tests, completion
  evidence, and affected documentation. Use for an independent read-only conformance and merge-
  readiness review, including documentation extraction and disposition.
---

# Implementation Review

Build **traceability** from approved behavior to evidence. The question is
whether the approved change has been implemented, protected by appropriately expressed tests, and
documented without unrecorded design changes. Principles and architecture are reviewed when the
architecture or change design is approved; do not reopen them during final implementation review.

This skill owns read-only conformance review. Read
[change-development-workflow.md](../../references/change-development-workflow.md) before setting the
boundary; its terms, governing direction, and documentation lifecycle are authoritative.

## Set the review boundary

1. Read repository guidance, the approved change record and selected work item, BehaviorCases,
   acceptance criteria, the current diff, affected production and test code, and directly affected
   documentation. For a work item, also read its parent change record and declared prerequisites.
2. State the reviewed revision or diff range and the documents used as the baseline.
3. If the supplied document is a change record rather than one work item, say that an
   implementation-readiness conclusion is not possible until a work item is selected. Keep the
   work-item boundary anchored in its approved record rather than inferring it from the diff.
4. If there is no approved change design, inspect the diff only enough to classify it. Report a
   Blocking finding and route to `change-design` when production code changes observable behavior;
   do not treat local correctness as a substitute for a design. If the evidence shows purely
   mechanical, no-behavior maintenance, say that the change-design workflow is not required and
   limit the conclusion to local correctness and repository conventions. When uncertain, report the
   missing design as Blocking.
5. Do not modify files, run builds, run tests, approve a pull request, or infer test results. Point
   to existing test code as evidence of intent, not proof that it currently passes.

Before reviewing code, check the selected work item's delivery brief. Report a blocking
finding when it has more than one independently observable outcome, lacks an objective definition
of done, omits a verification mapping for a material BehaviorCase, or cannot identify its logical
prerequisites. Do not require a recommended order when the items are independent. Report a blocking
finding when completion evidence for a real prerequisite is absent but the reviewed implementation
has begun. Do not reconstruct the missing delivery boundary from the diff.

Report a blocking delivery-plan finding when a work item does not name an observable outcome and
bounded target-delivery area, or exists only for research, review, approval, coordination, or
external operations. The expected internal area may be non-exhaustive; do not require exact private
files or symbols. Route design activities to `change-design` and external actions to their
operational owner; do not treat either as implementation evidence.

For a change-closure conclusion, verify that every required operational handoff named by the parent
change has recorded completion evidence. Do not review the external action itself as code, and do
not convert it into a work item because it blocks closure.

Also check that the parent change names exactly one result-oriented change goal and that every
BehaviorCase and selected work-item outcome contributes to it. Report a blocking finding when the
goal is missing, is merely an implementation task, or the package serves an unrelated result. Hand
such defects to `change-design`; do not invent or rename the goal during review.

## Build the traceability map

Create one row for every acceptance criterion or BehaviorCase in the selected delivery. Map it to
the implementation and test that express it. Mark a row `covered`, `missing`, `partial`, or
`deviates` and explain the evidence. Treat implementation belonging to another work item as a
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
5. Does not bypass an incomplete prerequisite.
6. Satisfies every objective definition-of-done criterion, including recorded passing verification
   evidence, required documentation or migration state, actual effort, and any material estimate
   variance. Treat missing effort or variance alone as a planning follow-up; treat missing required
   verification or delivery evidence as blocking because it cannot unlock the next package.

Treat different internal files, private symbols, algorithms, test organization, and edit order as
ordinary implementation choices when the observable outcome, public contracts, scope, and governing
constraints remain intact. Report a design deviation only when the implementation materially changes
one of those approved boundaries; do not silently reinterpret the design to match code.

Report a Blocking finding when a behavior-changing production-code diff is not covered by the
approved design, even if the resulting code appears locally correct. Route an expanded or changed
behavioral contract to `change-design` for revision and renewed approval; do not repair the missing
design in this review.

## Review test expression without running it

Inspect test code only; do not execute it. Check that each material BehaviorCase has an appropriate
test and that the test asserts observable behavior rather than private implementation details.
Review negative and boundary cases when the design names them. Flag a mismatched level when a test
needs real infrastructure but is presented as a unit test, or when a slow higher-level test is the
only protection for deterministic domain behavior.

Follow the repository's existing testing conventions while reviewing its test code, but do not run
the test command.

## Review documentation consistency

Apply the reference's documentation lifecycle to every material document or content block. Mark
durable decisions, current cross-cutting semantics, and active migration or operational procedures
as `not needed`, `captured`, or `missing`, with evidence. A missing extraction is an Important
finding owned by `architecture-design` or the applicable documentation skill.

Ask for a change-closure decision only when all of the following are true: the conclusion is
`Ready to merge`; the selected work item completes the parent change; and completion evidence
exists for every other planned work item; and every documentation-extraction category is `not
needed` or `captured`. Ask once, at the end of the report, whether the parent
`docs/changes/<change>/` directory should be deleted after merge, retained, or first distilled into
an ADR, architecture record, or active migration guide. Recommend deletion by default when nothing
needs retaining. Do not ask this question for a partial work item, `Ready with follow-ups`, or
`Not ready` review. Do not infer completion merely from a clean-looking diff. A user decision to
delete is approval for a separate, small documentation cleanup after merge; it is never permission
to delete during this read-only review.

Keep this review read-only. A human deletion decision authorizes a separate documentation change
after merge.

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
- <approved behavior, public contract, governing constraint, or work-item scope differs from implementation; cross-work-item scope expansion; or none found>

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
  bypassed, or the code materially deviates from approved behavior or delivery boundaries. A
  different conforming private implementation is not a deviation.
- **Ready with follow-ups** when no blocker exists but Important findings require ownership before
  or soon after merge.
- **Ready to merge** only when the traceability map is complete, no material design deviation
  remains, and no blocking or important finding is open.

Hand implementation fixes to `implement-change-tdd`, delivery-plan defects to `plan-work-items`,
and material design decisions or deviations to `change-design`. Keep the review independent by not
fixing the code in this skill.

Complete when every selected-work-item contract row has a status, every finding has evidence and an
owner, documentation disposition accounts for every durable record, and the conclusion follows from
the open Blocking and Important findings.
