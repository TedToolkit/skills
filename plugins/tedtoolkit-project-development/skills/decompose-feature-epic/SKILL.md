---
name: decompose-feature-epic
description: >-
  Decompose a large approved-or-draft feature, epic, migration, or cross-cutting programme into
  independently reviewable delivery work packages, dependency order, and decision gates before
  implementation. Use when a feature document combines multiple API families, breaking migrations,
  infrastructure and consumers, broad implementation batches, or cannot be safely implemented in
  one reviewable TDD change. Do not implement production code, tests, or infrastructure in this
  skill.
---

# Decompose Feature Epic

Turn an unbounded delivery request into a map of small, safe implementation contracts. The purpose
is not to estimate by intuition or create a checklist of files: it is to make each later change
independently reviewable, testable, mergeable, and reversible where the product allows it.

## Inspect and classify

1. Read repository guidance, the supplied design or issue, related ADRs and architecture records,
   the relevant public APIs, tests, project structure, and existing documentation conventions.
2. State the intended outcome, explicit non-goals, compatibility constraints, and decisions that
   remain open. Do not infer an undecided public behavior from the current implementation or tests.
3. Confirm that decomposition is necessary. Use it when the input has multiple independently useful
   outcomes, API families, migration paths, architectural layers, or prerequisite decisions. Return
   a single small feature to `feature-design` instead of adding ceremony.
4. Separate material into four owners:
   - enduring cross-cutting system semantics belong in an architecture record;
   - difficult-to-reverse technical choices belong in an ADR through `select-technology`;
   - overall outcome, dependency map, and delivery status belong in the epic index;
   - one implementable behavior change belongs in a work package.

## Define delivery boundaries

Create work packages by observable outcome, not by source directory, class, or the person expected
to edit it. Each package must have:

1. One coherent outcome and explicit non-goals.
2. A bounded affected API and migration surface.
3. Acceptance criteria and a behavior-first test map that can be reviewed together.
4. Explicit prerequisites, including decisions, ADRs, and other work packages.
5. A rollback or compatibility strategy when its change is externally visible or destructive.

Split a package when it requires an unrelated prerequisite, makes an independently releasable
public change, would make the acceptance map unreadable, or mixes a cross-cutting foundation with
several consumers. Keep a foundation and its first smallest consumer together only when that is the
smallest way to prove the behavior end to end.

Do not create implementation tasks for unresolved semantics. Record them as decision gates, name
their owner or next decision, and leave dependent packages blocked.

## Write the delivery map

Use `assets/epic-index-template.md` for `docs/features/<epic-slug>/README.md` when the repository
has no established epic convention. Use `assets/work-item-template.md` for each
`docs/features/<epic-slug>/work-items/<ID>-<slug>.md`. Keep standalone features at
`docs/features/<slug>.md`; do not introduce an epic directory for a single delivery.

The epic index must contain:

- outcome, scope, non-goals, and links to the source request;
- architecture and ADR links without duplicating their rationale;
- a dependency-ordered work-package table with status and decision gates;
- criteria for declaring the epic complete.

Each work package must contain only the contract needed for its own implementation: parent epic,
prerequisites, scope, acceptance criteria, design, test map, migration/rollback, and open risks.
Use stable IDs such as `GEOM-001` so implementation, reviews, and pull requests can trace the same
delivery without relying on filenames.

When the epic closes, its final review must classify each document for human maintainers: retain the
short epic index, extract an enduring rule to architecture, retain a decision in an ADR, keep an
active migration guide, delete a process-only work package, or exceptionally preserve a superseded
record in `docs/history/`. Do not create an archive by default and do not move or delete documents
without explicit human approval.

## Approval gate

Before creating or editing production code, tests, packages, infrastructure, or project structure,
present the proposed document tree, dependency order, decision gates, and each work package's
outcome. Wait for explicit approval before writing the epic index or work-package documents.

Approval of an epic map does not approve its work packages for implementation. A selected work
package still needs an approved behavioral contract through `feature-design` before
`implement-feature-tdd` begins.
