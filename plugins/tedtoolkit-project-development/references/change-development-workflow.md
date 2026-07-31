# Change-development workflow boundaries

This reference defines the handoffs for the change-development workflow. It distinguishes the
records that control work from the product artifacts that a delivery changes.

## Contents

- [Governing dependency direction](#governing-dependency-direction)
- [Terms](#terms)
- [Gates and lifecycle](#gates-and-lifecycle)
- [Documentation lifecycle](#documentation-lifecycle)
- [Route new information without guessing](#route-new-information-without-guessing)
- [Status meanings](#status-meanings)

## Governing dependency direction

Use this one-way chain:

```text
product intent
  → design principles
    → architecture records and ADRs
      → change design
        → work items
          → implementation
            → implementation review
```

Later records may cite an approved earlier record and restate the constraint they consume. Product
intent, principles, architecture records, and ADRs remain durable: derive their claims from durable
evidence and keep them independent from `docs/changes/`, work items, review reports, and other
temporary delivery artifacts.

## Terms

| Term | Meaning | Not this |
| --- | --- | --- |
| Governing record | Approved product intent, principle, architecture record, or ADR that constrains later work. | An implementation plan or proof that delivery is complete. |
| Change design | The approved behavioral contract for one user or system outcome. | A task list, file list, or test-command plan. |
| Target delivery artifact | A version-controlled code, test, configuration, build, or user/maintainer documentation artifact whose bounded modification contributes to the approved change goal. | Change-design records, work-item records, status fields, review reports, or completion evidence. Those are workflow control records and never justify a work item by themselves. |
| Work item | One approved, independently verifiable delivery boundary that states an outcome, constraints, real prerequisites, and proof for a bounded target-delivery area. | A private code design, exhaustive file list, executable edit sequence, or external action. |
| Operational handoff | A separately tracked action outside the repository, such as a release, deployment, access request, manual production configuration, or stakeholder communication. | A work item. It may be required for change closure, but it is not implemented through the development work-item flow. |
| No-delivery-change conclusion | An approved conclusion that no target delivery artifact must change. | An absence of documentation: the change-design record still documents and closes the conclusion. |

## Gates and lifecycle

1. `change-design` may create and revise a Draft while clarifying uncertainty. A draft control
   record is not a target delivery artifact and does not authorize implementation.
2. `review-change-design` independently checks the behavioral contract. A human approves it.
3. If the approved design names no target delivery artifact, it records the evidence and completion
   criteria, resolves any operational handoffs, and closes without a delivery map or work item.
4. Otherwise, `plan-work-items` creates only the work items needed to modify target delivery
   areas. A human approves the delivery plan before implementation.
5. `implement-change-tdd` selects one approved item, chooses the concrete internal artifacts, and
   changes only its bounded delivery area. It records verification and completion evidence.
   Discovery that changes the approved contract stops implementation and follows the routing rules
   below.
6. `review-implementation` checks the selected item against the approved design and evidence. A
   change closes only when every planned item is complete, every change completion criterion is met,
   and every required operational handoff has recorded completion evidence.

## Documentation lifecycle

Keep active delivery control in `docs/changes/`. At final implementation review:

1. Extract an enduring decision and rationale to an ADR.
2. Extract current cross-cutting semantics to an architecture record.
3. Retain an active migration or operational procedure in its owning guide or runbook.
4. Update product intent or principles only when their durable baseline actually changes.
5. Let a human decide whether the remaining process-only change record is retained or deleted after
   merge; Git history supplies recovery.

## Route new information without guessing

| Discovery | Route | Do not do |
| --- | --- | --- |
| A behavior case, scope, compatibility constraint, risk, or completion criterion is missing or changes | `change-design`, then review and renewed human approval | Alter the work item or code to decide it implicitly. |
| A material technical direction is missing or invalid | `architecture-design`, then update the change design with accepted constraints | Put the decision in a work item or infer it from current code. |
| The approved behavior is unchanged but the work-item outcome, delivery boundary, real dependency, estimate, or verification standard needs refinement | `plan-work-items`, then renewed delivery-plan approval | Treat the refinement as a design change. |
| Internal files, private symbols, algorithms, test organization, or edit order need to be chosen or changed within the approved boundary | `implement-change-tdd`; record the actual result in completion evidence | Return to planning merely because private implementation was not predetermined. |
| The actual internal files differ from planning evidence but the outcome, scope, public contracts, and constraints remain unchanged | Continue implementation and record the actual changed artifacts | Report a design deviation or seek reapproval solely for internal file drift. |
| Work uncovers research or a decision | `change-design` | Create a research or decision work item. |
| Delivery needs a release, permission, deployment, or manual external configuration | Record an operational handoff with owner, evidence, and closure condition in the change design or established operations system | Add it to a work item merely because it blocks release. |
| No target delivery artifact must change | `change-design` records the evidence and closes after review and approval | Create a zero-change work item to make the workflow look complete. |

## Status meanings

- A change is `Approved` when its behavioral contract is approved; this does not approve a work
  item or prove delivery.
- A work item is `Approved` when its bounded delivery brief is approved; it may then be
  implemented.
- A work item is `Implemented` only after its target-artifact changes and declared verification
  evidence are recorded.
- A change is `Completed` only after all required work items and operational handoffs are complete,
  the change-level completion criteria are met, and the final documentation disposition is decided.
