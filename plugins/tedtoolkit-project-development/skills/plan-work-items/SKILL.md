---
name: plan-work-items
description: >-
  Slice one approved change design into independently verifiable work items. Use when an approved
  behavioral contract needs delivery boundaries, logical prerequisites, verification plans,
  definitions of done, estimates, or a delivery map while preserving private implementation freedom.
---

# Plan Work Items

Create the smallest set of **slices** that can each deliver and prove one outcome. This skill
owns work-item outcomes, logical prerequisites, authorized delivery boundaries, verification
criteria, estimates, and definitions of done. It does not redefine the change or design the private
implementation.

Read [change-development-workflow.md](../../references/change-development-workflow.md) before
classifying target delivery artifacts, work items, or operational handoffs. Its terms and lifecycle
are authoritative; this skill adds only the concrete planning steps below.

## Establish the planning boundary

1. Read repository guidance, the approved `change.md`, governing records pinned by it, affected
   code, callers, tests, documentation, dependencies, and adjacent changes.
2. Require an approved change with one explicit change goal, observable behavior cases, and
   completion criteria. If it is Draft, incomplete, ambiguous, or names multiple goals, return it
   to `change-design`; do not infer missing behavior.
3. Record a material conflict between repository evidence and the approved contract as a change
   design deviation. Stop for a revised approval before writing work items.
4. For each candidate item, make a planning-boundary inventory before drafting prose: affected
   observable behavior or public contracts, expected delivery area, current-behavior evidence,
   repository consumers or generated outputs, explicit non-goals, and known unknowns. Make a public
   API, protocol, persistence format, or other externally visible contract exact when the approved
   change requires it. Treat an expected internal file or private symbol as non-binding evidence,
   not an exhaustive authorization list.
5. Establish whether the candidate can start from completed prerequisites and finish with its own
   evidence. Its essential behavior must not wait for a later item to be implemented or verified.
   Split the candidate or return an unresolved design dependency to `change-design` when this is
   not possible.
6. Inspect code only far enough to validate the boundary, feasibility, dependency, and verification
   strategy. Do not solve local algorithms, private type structure, method decomposition, or exact
   edit sequence during planning. An unknown that changes observable behavior, a public contract,
   or the ability to verify the outcome is a blocker; an internal implementation choice is not.

## Split into minimal work items

Use the smallest number of work items that keeps independently deliverable outcomes separate. Each
item has exactly one independently observable outcome and must be small enough for one implementer
to start after its stated prerequisites, make the bounded change, run its verification, and decide
complete or incomplete without starting another item. A work item is not independent merely because
its files are separate: it needs a bounded delivery area, explicit expected behavior, and evidence
that proves its own outcome.

Do not create an item whose only outcome is investigation, review, coordination, approval, or a
decision. Resolve that uncertainty before planning. Do not create an item for an unchanged artifact:
when the approved design proves that no target delivery artifact modification is required, record
that conclusion in the change design and create no delivery plan.

Split an item if it contains more than one independently deliverable outcome, separately reversible
change, foundation beyond its smallest proving consumer, later design choice, or separate
verification strategy. Do not split merely by behavior-case row, source directory, class, or person.
Put the smallest proving consumer with a foundation when that is required to verify the foundation;
do not create a foundation item whose only proof is deferred to a later item.

## Create the delivery brief

Create `work-items/<ID>-<slug>.md` from `assets/work-item-template.md` under the parent change.
Append the delivery map from `assets/delivery-map-template.md` to the parent `change.md`. For every item:

1. Copy the approved change goal, applicable behavior cases, and governing constraints without
   changing them.
2. State one bounded outcome, scope, non-goals, expected affected delivery area, and any exact public
   contract authorized by the approved change. An item outcome contributes to the parent goal; do
   not label it a goal. Do not require an exhaustive internal file or private-symbol inventory.
3. Record only logical prerequisites that supply a concrete input or guarantee. Use a recommended
   order only when it helps coordination; do not invent a total serial order for independent items.
   A later item may consume an earlier result, but may not be needed to prove that earlier outcome.
4. State delivery constraints: observable behavior, compatibility, security, migration, governing
   rules, and adjacent behavior that must remain unchanged. Do not prescribe an algorithm, private
   type structure, method decomposition, or line-by-line edit sequence.
5. Map every applicable behavior case to its proof intent, observable assertion, and appropriate
   test level or bounded manual procedure. Name a stable repository command when known, but leave
   the exact test file, fixture organization, and focused command to implementation when they depend
   on the chosen code structure. A broad final build alone is insufficient, and a later item cannot
   be the only verification for this item.
6. Define done with objectively checkable behavior, passing evidence, required documentation or
   migration state, and any prerequisite output supplied to dependent items. Completion evidence
   records the actual changed artifacts; a difference from a non-binding expected area is not a
   deviation unless it expands scope or violates a stated constraint.
7. Give each item a range estimate, confidence, assumptions, exclusions, migration or rollback when
   material, and material risks with an owner or next decision.

Do not use placeholders such as "update implementation", unknown expected behavior, generic links
that replace item-specific constraints, or verification delegated to a later item. Record a
behavioral, public-contract, dependency, or verification unknown as a blocker. Leave ordinary
private implementation choices for `implement-change-tdd`. Preserve every
`<!-- work-item: ... -->` and `<!-- delivery-map -->` marker from the templates unchanged; they are
language-independent inputs to the delivery-boundary validator, not user-facing prose.

## Approval gate

Before presenting the plan, run
`bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-work-items.sh <parent-change-directory>`. Resolve
every reported error by clarifying, splitting, correcting dependencies, or returning the missing decision to
`change-design`; do not waive an error because a reader could infer the answer from another file.

Before implementation, present the delivery map and every work item with its outcome, prerequisites,
verification, definition of done, estimate, and blockers. Wait for explicit approval.
Approval authorizes `implement-change-tdd` to implement one selected work item only. A material
change to the approved behavioral contract returns to `change-design`; a material change to an
item's outcome, scope, real prerequisite, public contract, verification standard, definition of
done, estimate, or migration requires renewed work-plan approval. A different internal file, private
symbol, algorithm, test organization, or edit sequence within the approved boundary does not.

Complete when the validator passes, every approved behavior case maps to proof in at least one
independently completable slice, each item proves its own outcome, and the user has approved the
delivery map or received the exact blockers.
