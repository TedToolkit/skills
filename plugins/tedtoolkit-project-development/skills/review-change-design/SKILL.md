---
name: review-change-design
description: >-
  Independently review a Standard or Controlled change for correct profile, one coherent goal,
  human handoff quality, behavioral or invariant completeness, scalable proof, constraints, risks,
  ADR coverage, and readiness for approval. Use before approving Controlled changes and whenever a
  draft may be over- or under-designed. Remain read-only.
---

# Change-Design Review

Review whether the shortest safe contract is complete and usable by a human developer. Do not edit
the draft, create work items, approve it, run tests, or begin implementation.

Read [change-development-workflow.md](../../references/change-development-workflow.md),
[testing-strategy.md](../../references/testing-strategy.md), and
[agent-orchestration.md](../../references/agent-orchestration.md).

## Set the boundary

Read repository guidance, the submitted change, directly affected current documentation and code
needed to check status quo, and only the governing records actually cited. State the reviewed path
and review context. If orchestration references a preparation, inspect only the relevant approved
partition rows and evidence IDs; do not load sibling drafts or agent transcripts without a named
contradiction.

Do not use proposed implementation or tests as evidence that the future delivery is complete.

State review independence as `independent`, `compact`, or `not-established` using the shared
definitions. Controlled approval requires a fresh read-only reviewer that did not author the exact
Draft. Bind cross-context or asynchronous review with a commit or content digest; a synchronous
read-only handoff may instead compare the complete Draft before and after review. If exact input or
author separation cannot be established, report a Blocking finding. A requested Standard quality
check may be `compact`, but must not claim independence.

An explicit `change-format: 2` record that was already approved may complete unchanged only through
the deprecated compatibility path. A Draft, renewed approval, or change to its scope, contract,
proof, or map must migrate through `design-change` before review.

## Review profile and kind

Verify that evidence supports the selected profile and kind:

- Fast should not have manufactured a change record.
- Standard has one goal, one delivery, bounded reversibility, and no Controlled trigger.
- Controlled covers public/persisted contracts, security, migration, difficult reversal,
  architecture, cross-cutting delivery, or multiple work items proportionately.

Treat preparation and parallel execution as routing or runtime choices, not workflow profiles. A
multi-goal request should have been partitioned before this review; a multi-item Controlled change
may decide sequential versus parallel execution only after readiness and collision evidence exists.

An understated material risk is Blocking. Unnecessary ceremony is Important: recommend the smaller
profile or removal of redundant artifacts before approval.

## Apply the five-minute handoff test

A developer without conversation context must be able to identify goal/rationale, current and
expected behavior or invariants, scope/non-goals, constraints/risks, prerequisites, primary and
conditional proof, and open private implementation choices.

Check that the main document contains current truth rather than clarification logs, writer leases,
receipts, transaction state, repeated rationale, empty headings, or an exhaustive private edit plan.
Likely touchpoints should orient the developer while remaining explicitly non-binding.

## Review the contract

Check:

1. exactly one result-oriented goal with evidenced problem/value/why-now rationale;
2. explicit scope, non-goals, compatibility, current state, and deliberately preserved behavior;
3. behavior-change, bug-fix, and migration cases have stable observable `AC-<number>` results;
4. behavior-preserving refactors use `INV-<number>` invariants rather than invented deltas;
5. maintenance uses `STR-<number>` target structural outcomes rather than mislabeling changed state as a preserved invariant;
6. every material contract claim has an evidence, governing constraint, or current user decision;
7. required enduring decisions have accepted ADRs before approval;
8. risks, migration/recovery, operational handoffs, and completion are proportional;
9. a Standard or single-delivery Controlled record contains a usable embedded delivery brief;
10. a multi-delivery Controlled record routes planning to `plan-work-items` without prescribing the
   future map; and
11. machine markers remain stable and visible prose may be translated.

Also verify that material clarification is complete: no unanswered question may still change the
goal, observable contract, scope, compatibility, security, migration/recovery, architecture,
delivery shape, or primary proof. Do not block approval for private implementation choices.

Do not require a full clarification history in the human document. When a conversation answer
changes current truth, require that truth and its authority to be reflected; detailed history may
live in separate control state or Git history.

## Review proof proportionately

Every contract row needs exactly one credible primary proof. Its `primary-proof` marker is the
canonical purpose and execution-shape mapping; its concise human row supplies the observable
assertion and known command or bounded procedure. Acceptance is a purpose, not a
mandatory test project.

Report a blocker when a named real boundary, migration, compatibility, security, or critical
journey lacks justified evidence. Do not require Unit, Integration, and Acceptance rows merely to
fill layers, and do not require an artificial Red for a behavior-preserving refactor or mechanical
maintenance.

## Report

```md
# Change-Design Review

## Conclusion
Ready for approval | Needs revision

## Profile and handoff
- Selected profile and kind:
- Independence:
- Reviewed Draft path and review context:
- Five-minute handoff: Pass | Fail
- Over- or under-designed:

## Contract and proof
| Contract item | Evidence or primary proof | Status |
| --- | --- | --- |

## Blocking findings
- [B1] <finding> — Evidence: <location>. Impact: <impact>. Smallest revision: <change>.
  Owner: design-change / architecture-design. Verify: <check>.

## Important findings
- [I1] <finding> — Evidence: <location>. Impact: <impact>. Smallest revision: <change>.
  Owner: design-change. Verify: <check>.

## Review scope and limits
- Reviewed:
- Not reviewed: implementation and delivery completion.
- Not run: builds or tests.
```

Choose `Needs revision` when a Blocking finding exists. Choose `Ready for approval` only when the
profile is safe, the human handoff is actionable, all material contract rows and primary proof are
covered, and no contradiction or required ADR remains. Readiness is not approval.

Complete when every material contract and handoff question has a status, findings name evidence and
the smallest owner-specific revision, and the conclusion follows from the blocking set.
