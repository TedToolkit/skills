---
name: plan-work-items
description: >-
  Slice one approved Controlled change into two or more independently verifiable human work items.
  Use only when one embedded delivery brief cannot honestly implement and prove the approved goal,
  or when a multi-item dependency map is required. Decide this from the approved contract rather
  than asking the user whether the change is simple or complex. Do not use for Fast or Standard
  work or manufacture a one-row delivery map.
---

# Plan Work Items

Create the smallest multi-item delivery map that lets human developers implement the approved
Controlled change without reading the originating conversation. This skill owns item outcomes,
real prerequisites, delivery boundaries, primary proof, conditional proof, and done criteria. It
does not change the approved behavioral contract or prescribe private implementation.

Read [change-development-workflow.md](../../references/workflow/change-development-workflow.md) for
profile, human-handoff, and approval rules. Read
[testing-strategy.md](../../references/workflow/testing-strategy.md)
for proof purpose and execution shape. Read
[tool-state-layout.md](../../references/orchestration/tool-state-layout.md) before persisting planning
control state for recovery.

## Confirm planning is justified

Require an approved Controlled format-3 change whose approved delivery shape is `multi-item`, with
one goal and a complete contract, plus an explicit current request to plan or continue. Approval
alone records the contract and does not start planning. Do not ask the user to choose a complexity
label.

- If the record is Fast or Standard, keep its one delivery in the embedded delivery brief, report
  `implement-change` as the only next delivery phase, and stop.
- If one bounded delivery can implement and prove the complete change, stop and return the delivery
  shape to `design-change` for revision and renewed approval; do not edit the approved contract or
  create a one-row map here.
- If the change kind is `experiment`, return it to `design-change`; experiments are single-delivery
  evidence changes and do not use work-item maps.
- If the request contains another independently valuable goal, return it to `scope-changes`; do not
  hide it as an item.
- If behavior, public contracts, migration semantics, security, or architecture remains undecided,
  return to the owning design skill.

Planning is justified only when at least two deliveries have distinct independently verifiable
outcomes, real dependency inputs, separate reversibility, or materially different proof/ownership
boundaries.

## Split by outcome, not repository shape

Each item must let one human developer:

1. identify one bounded outcome and why it contributes to the parent goal;
2. start from completed real prerequisites;
3. change a bounded target-delivery area;
4. prove its own outcome without a later item; and
5. supply any declared output that unlocks a dependent item.

Do not split by class, directory, team, acceptance-case row, or estimated size alone. Keep a
foundation with its smallest proving consumer instead of creating an item whose proof is deferred.
Research, review, coordination, approval, release, permission, and manual external operations are
not work items.

## Write concise human handoffs

Create `work-items/<ID>-<slug>.md` from [work-item-template.md](assets/work-item-template.md) and
create the parent change's authoritative `work-items.md` from
[delivery-map-template.md](assets/delivery-map-template.md).
Remove all inapplicable optional content.

Every item states:

- one outcome, scope, and explicit non-goals;
- concrete inputs supplied by real prerequisites;
- exact public or persisted contracts and implementation-facing constraints;
- evidence-backed likely components or files as non-binding touchpoints;
- parent `AC-<number>`, `INV-<number>`, or `STR-<number>` responsibility without copying the contract;
- one primary proof with proof purpose, execution shape, assertion, and known command;
- only the conditional boundary, migration, structural, or broader regression evidence justified by
  actual risk; and
- objective done and completion-evidence requirements.

Do not include agent history, coordination state, executable edit steps, exhaustive private file
lists, algorithms, method decomposition, or repeated parent rationale. Store only material planning
decisions in `.tedtoolkit/runs/<workflow-id>/` when recovery needs them and the user approved that
persistence; update the work item with the resulting current truth.

## Map proof and ownership

Every parent contract row has exactly one owning item. Other items may support it only by naming a
verified input. An owning item must have a credible primary proof; it need not create a distinct
Acceptance test when a Unit, Component, Contract, Integration, End-to-end, or bounded manual shape
is the narrowest reliable observation.

Require Integration only for a changed real boundary. Require Unit only when deterministic logic
benefits from focused protection. Require End-to-end only for a material deployed journey that
narrower proof cannot establish. One test may serve Acceptance and regression purposes.

## Validate and approve

Run `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-work-items.sh <parent-change-directory>` and
resolve structural, ownership, dependency, and proof errors. Then apply the five-minute handoff
test to the parent and every item.

Treat `work-items.md` as the only mutable item-status source. Approved item documents are stable
delivery contracts; workers and reviewers do not maintain a second status field inside them.

Present the map with each item's outcome, prerequisites, primary proof, conditional proof, done
criteria, and material collision risks. Wait for explicit approval of the complete enumerated map
and item set, record the human approval source, set its rows to `Approved`, rerun the validator, and
stop unless the same request explicitly says to approve and continue. Approval accepts the item
boundaries only. A later explicit continuation enters `orchestrate-work-items`; an ordinary worker
preflight is informative unless it discloses a material escalation trigger.

Return behavioral or public-contract change to `design-change`; return a changed item outcome, real
prerequisite, boundary, proof standard, or migration delivery to this skill for renewed plan
approval. Private files, symbols, algorithms, test organization, collision order, and edit sequence
do not require replanning when they remain inside the approved boundary.

Complete when the validator passes, the map has at least two necessary items, each item passes the
five-minute handoff test, every contract row has exactly one owner and credible primary proof, and
the user has approved the map or received the exact blocker.
