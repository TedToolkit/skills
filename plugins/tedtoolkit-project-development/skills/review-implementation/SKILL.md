---
name: review-implementation
description: >-
  Plan, coordinate, and synthesize a risk-scaled implementation review for an approved Fast plan,
  Standard or Controlled delivery, selected work item, or integrated multi-item change. Use exact
  candidate-bound code, test, and verification lanes; establish reviewer independence when risk
  requires it; resolve contradictions from primary artifacts; and issue the only final merge-
  readiness conclusion without modifying the implementation.
---

# Implementation Review

Require an explicit current request to review or continue; a candidate becoming ready does not
start review by itself. Own the review plan and final conclusion. Use `review-code`, `review-tests`,
and `verify-implementation` as distinct professional lanes; do not collapse implementation
correctness, test adequacy, and successful execution into one vague claim.

Read [change-development-workflow.md](../../references/change-development-workflow.md),
[testing-strategy.md](../../references/testing-strategy.md), and
[agent-orchestration.md](../../references/agent-orchestration.md).

The coordinator remains non-writing: do not modify implementation/test artifacts, fix findings,
approve a pull request, merge, or update delivery status. Specialist review lanes remain read-only.
`verify-implementation` may create ordinary build/test output but must not change source or delivery
records.

## Select the mode and bind the review

Select exactly one mode:

- `delivery-candidate`: one Fast plan, Standard/single-delivery Controlled change, or selected work
  item against an exact baseline-to-candidate range; or
- `integrated-change`: one multi-item Controlled parent, every non-superseded item, authoritative
  integration SHA, combined verification, operational handoffs, and documentation disposition.

Require the approval source, repository guidance, affected artifacts, and a candidate binding scaled
to the review. Independent, cross-context, asynchronous, CI, or integrated review uses a committed
full SHA or, when a candidate commit was not authorized, `HEAD` plus a cryptographic digest of the
complete tracked diff and every in-scope untracked blob. A synchronous compact review in the same
workspace may instead bind to the baseline plus a complete raw working-tree snapshot captured and
compared before and after its serial checks; it needs no commit or digest and is not reusable outside
that context. Record the approved contract path and human approval source as authorization context.
Any candidate, relevant baseline, or approved-contract change makes the conclusion or affected
professional judgment stale.

Repeat cross-change readiness before concluding. For a committed candidate, run format-3 validation
with `--require-ready --baseline <candidate-sha>`. For a frozen uncommitted bundle, use the recorded
implementation `HEAD` baseline only after proving that every prerequisite source record is unchanged
by the bundle; otherwise report Blocking because readiness is not candidate-bound. An unmet source
contract is Blocking and never changes the dependent change's approved lifecycle status. An explicit
legacy prerequisite base remains valid only when the validator confirms the contract changed by
lifecycle status alone.

Do not infer a missing behavior contract from the diff. Route behavior-changing code without an
approved boundary to `design-change`. In `delivery-candidate`, require one selected work item when a
Controlled change has a delivery map. In `integrated-change`, require every non-superseded item to be
`Verified` on the authoritative integration SHA; `Implemented` remains Blocking.

## Choose compact or independent review

Record one aggregate independence level:

- `independent`: at least one fresh read-only review context that did not implement the candidate
  receives the exact candidate and raw governing artifacts, owns every required professional
  judgment, and synthesizes the conclusion;
- `compact`: the delivery coordinator performs the necessary checks for a bounded low-risk change
  and does not claim independence; or
- `not-established`: reviewer separation, candidate binding, or read-only ownership is insufficient.

Require `independent` for public or persisted contracts, security, migration, shared cross-item
boundaries, concurrency, difficult reversal, or another material Controlled risk. When independent
review is required but fresh agents are unavailable, return `Not ready`; do not simulate multiple
reviewers in one context and label them independent.

Use SubAgents only when their independence or context separation has material review value:

1. Keep one user-facing delivery owner. In independent mode, one fresh review coordinator owns the
   judgments and synthesis; the delivery owner only receives the conclusion and updates status. In
   compact mode, the delivery owner may coordinate and synthesize in the same context while remaining
   read-only during review.
2. A single fresh reviewer may perform `review-code` and `review-tests` checks serially and keep the
   conclusions distinct. Split them into additional SubAgents only when specialist expertise,
   context size, or conflict isolation justifies it. Use a separate verification executor only when
   environment or permission separation adds material confidence; otherwise the reviewer may run it
   or reuse exact-revision CI.
3. When splitting concerns across contexts, send each lane only the objective, exact
   baseline/candidate, approved contract and IDs, governing paths, allowed read scope, required
   handoff, and stop conditions.
4. Do not send a split lane an implementer transcript, sibling findings, suspected answer, or
   proposed fix. One fresh reviewer covering several concerns may retain its own evidence while
   keeping conclusions distinct.
5. Use a compact coordinator review when only one bounded low-risk lane is useful or SubAgent setup
   costs more than the risk reduction.

## Collect the professional lanes

### Code correctness

Invoke `review-code` for production/configuration changes. It attempts to disprove correctness and
returns contract/risk coverage plus cited findings. It does not judge test adequacy or merge status.

### Test adequacy

Invoke `review-tests` whenever behavior, regression, invariants, or changed tests contribute to the
delivery claim. It returns material behavior partitions, observable oracle strength, refactor
tolerance, isolation/flakiness, and result-traceability findings. It does not execute tests.

### Verification result

Use `verify-implementation` or equivalent trusted CI output for the exact candidate when command
execution is required. A passing command proves only that the selected command succeeded on that
candidate; it cannot overrule a missing behavior partition or weak assertion. A failed command,
zero intended tests, unexplained skips, candidate mismatch, or stale result is Blocking when that
gate is required.

For low-risk compact review, perform the same lane questions serially and label them compact. Do not
manufacture separate reports merely to mimic independent agents.

## Synthesize traceability

Create the single authoritative traceability table; specialist lanes contribute facts but do not
each own a competing final table.

| Contract | Implementation | Test/procedure and adequacy | Candidate-bound verification | Status |
| --- | --- | --- | --- | --- |
| AC-01, INV-01, STR-01, or EXP-01 |  |  |  | covered / weak / missing / partial / deviates / unverified |

In `delivery-candidate`, include every owned contract and promised supporting input. In
`integrated-change`, trace every parent contract through its owning item to the integrated
implementation and combined verification. Read primary artifacts behind every specialist citation;
a matching test name or worker success message is not proof.

In integrated mode, reuse still-valid item-level judgments when the item patch, approved contract,
and relevant baseline behavior are unchanged. Review the parent mapping, integration-only diff,
cross-item/shared-boundary interaction, combined verification, documentation, and operational
handoffs. A new integration commit SHA alone does not make equivalent evidence stale; changed patch
content or relevant baseline semantics does.

## Resolve contradictions without voting

Do not count reviewer votes or average confidence scores.

- Command failure is an observed fact and cannot be overruled by a positive code review.
- Command success cannot overrule a credible test-adequacy or contract-implementation gap.
- Resolve a factual conflict by reopening the cited contract, code, test, and raw result, then state
  the decisive source.
- If the coordinator implemented the candidate or cannot resolve a material dispute without making
  a new specialist judgment, dispatch one fresh narrowly scoped adjudication SubAgent. Do not show it
  sibling conclusions; give it the disputed claim and primary artifacts.
- If the contract itself is ambiguous, route to `design-change`; reviewers do not invent behavior.

Any code, test, configuration, contract, or candidate revision change after a lane returns invalidates
the affected lane. Re-verify and re-review the changed surface before reusing the conclusion.

## Check delivery and documentation

Confirm scope, non-goals, prerequisites, compatibility, dependency direction, security, migration,
rollout, operational handoffs, done criteria, and absence of unrelated changes. Route changed
behavior or governing contracts to `design-change`, changed item boundaries or proof standards to
`plan-work-items`, and conforming implementation/test defects to `implement-change`.

Mark enduring decisions, cross-cutting current semantics, and active migration/operations procedures
as `not needed`, `captured`, or `missing`. Missing durable extraction is Important and belongs to
`architecture-design` or the applicable documentation owner. Apply repository retention only after
the complete parent is ready, operational handoffs and extraction are complete, and deletion was
separately authorized when required.

## Report

Preserve each specialist finding's observed fact, inference/impact, confidence basis, smallest
correction, owner, and verification method. Do not flatten a cited fact and an uncertain inference
into one authoritative sentence.

```md
# Implementation Review

## Conclusion
Ready to merge | Ready with follow-ups | Not ready | Stale

## Review mode and independence
- Mode: delivery-candidate | integrated-change
- Independence: independent | compact | not-established
- Baseline:
- Candidate binding: current workspace snapshot (compact only) | committed SHA | frozen uncommitted bundle
- Contract source/revision:
- Implementer context:
- Code reviewer:
- Test reviewer:
- Verification executor/source:

## Traceability
| Contract | Implementation | Test/procedure and adequacy | Verification result | Status |
| --- | --- | --- | --- | --- |

## Professional lane conclusions
- Code:
- Tests:
- Verification:
- Contradictions and resolution:

## Blocking findings
## Important findings
## Suggestions

## Design deviations
- <material contract or scope difference, or none>

## Documentation extraction and disposition
| Knowledge or record | Durable location or recommendation | Status / follow-up |
| --- | --- | --- |

## Change closure decision
<Only for a complete Ready-to-merge parent with extraction complete.>

## Review scope and limits
- Reviewed:
- Executed by verification lane:
- Not reviewed or verified:
```

Emit every report heading above exactly and in order for every conclusion, including `Not ready`.
Do not rename, merge, or omit later sections after finding an early blocker. Omit only `## Change
closure decision` unless the reviewed subject is a complete Ready-to-merge parent with extraction
complete; use `none` or `not applicable` where another section has no content.

Choose `Not ready` for Blocking findings or missing required independence, `Ready with follow-ups`
when only Important findings remain, `Ready to merge` only with complete traceability, required
independence, passing candidate-bound verification, and no material deviation, and `Stale` whenever
the bound candidate or contract changed. Return the exact reviewed range to the delivery owner; only
that owner may advance lifecycle state.
