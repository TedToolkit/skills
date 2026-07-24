---
name: plan-work-items
description: >-
  Turn one approved change design into small, sequential, independently verifiable work items. Use
  when a user asks to break down an approved change, create work items, create a delivery plan,
  sequence implementation, define implementation steps, verification plans, or definitions of done.
  Do not change the approved outcome, scope, behavior cases, or governing constraints; return a
  mismatch to change-design.
---

# Plan Work Items

Translate one approved behavioral contract into an executable delivery contract. This skill owns
work-package boundaries, logical prerequisites, recommended serial order, implementation steps,
verification plans, estimates, and definitions of done. It does not redefine the change.

## Establish the planning boundary

1. Read repository guidance, the approved change README, governing records pinned by it, affected
   code, callers, tests, documentation, dependencies, and adjacent changes.
2. Require an approved change with one explicit change goal, observable behavior cases, and
   completion criteria. If it is Draft, incomplete, ambiguous, or names multiple goals, return it
   to `change-design`; do not infer missing behavior.
3. Record a material conflict between repository evidence and the approved contract as a change
   design deviation. Stop for a revised approval before writing work items.

## Split into minimal work items

Prefer too many work items to one that bundles independent work. Each item has exactly one
independently observable outcome and must be small enough for one implementer to start after its
stated prerequisites, make the bounded change, run its verification, and decide complete or
incomplete without starting another item.

Split an item if it contains more than one independently verifiable behavior, distinct failure mode,
separately reversible change, foundation beyond its smallest proving consumer, later design choice,
or separate verification strategy. Do not split merely by source directory, class, or person.

## Create the delivery contract

Create `work-items/<ID>-<slug>.md` from `assets/work-item-template.md` under the parent change.
Append the delivery map from `assets/delivery-map-template.md` to the parent README. For every item:

1. Copy the approved change goal, behavior cases, and governing constraints without changing them.
2. State current behavior and one bounded outcome, scope, and non-goals. An item outcome is a
   delivery result that contributes to the parent goal; do not label it a goal.
3. Record logical prerequisites separately from a unique recommended sequence number. The sequence
   is a total order: it names exactly one next item. Retain facts about possible parallelism in
   prerequisites, but use deterministic serial order unless parallel execution is material.
4. Write dependency-ordered implementation steps. Every step names its prerequisite, exact artifact
   or command, bounded action, and observable check required before the next step.
5. Map every behavior case to an executable command or bounded manual procedure, setup, observable
   assertion, and expected result. A broad final build alone is insufficient.
6. Define done with objectively checkable deliverables, passing evidence, documentation or migration
   state, and status update that unlocks the next sequence row.
7. Give each item a range estimate, confidence, assumptions, exclusions, and material risks.

Do not use placeholders such as "update implementation", implied files, unstated setup, unknown
expected results, or verification delegated to a later item. Record an unknown as a blocker instead.

## Approval gate

Before implementation, present the delivery map and every work item with its outcome, prerequisites,
sequence, verification, definition of done, estimate, and blockers. Wait for explicit approval.
Approval authorizes `implement-change-tdd` to implement one selected work item only. A material
change to the approved behavioral contract returns to `change-design`; a delivery-only refinement
requires renewed work-plan approval.
