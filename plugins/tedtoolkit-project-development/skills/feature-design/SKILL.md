---
name: feature-design
description: >-
  Discover, specify, and design a new product or library feature before implementation. Use when a
  user asks to add, plan, scope, design, or estimate a feature; turn an issue or request into
  acceptance criteria; define APIs, behavior, migrations, risks, or a test strategy; or requests
  a feature design document. Use it for one independently reviewable and implementable delivery;
  when a request is an epic with multiple independent deliveries, invoke decompose-feature-epic
  before designing its work items. Produce an approved implementation-ready design and do not
  implement production code in this skill.
---

# Feature Design

Turn one delivery into a small, reviewable contract. A design is useful only when it tells an
implementer what observable behavior to build and how to prove it. Do not use a document to make a
simple local change look architectural, or to combine an entire programme of work into one design:
scale the detail to the risk and reversibility of the decision.

## Establish the planning level

Before drafting, decide whether the request is a feature or an epic.

- A **feature** has one coherent outcome, a bounded API or behavior surface, one reviewable test
  map, and can be implemented and rolled back without completing unrelated deliveries.
- An **epic** contains multiple independently valuable or mergeable outcomes, multiple API families
  or migrations, cross-cutting infrastructure plus consumers, or decisions whose uncertainty would
  block several later changes.

Do not disguise an epic as a feature merely by adding sections or a long implementation plan. When
the request is an epic, invoke `decompose-feature-epic`. That skill creates the delivery map and
work packages; return here only to design a selected work package. Put an enduring architecture or
technology decision in an ADR through `select-technology`, and link it instead of copying its
rationale into every work package.

## Inspect and clarify before drafting

1. Read repository guidance, the affected public API and its callers, relevant tests, architecture
   and documentation, dependency files, and recent adjacent changes when available.
2. State the user outcome, in scope work, explicit non-goals, compatibility expectations, and
   constraints. Ask about any missing point that would materially change behavior, public API,
   persistence, security, or rollout.
3. Identify the status quo and the smallest credible alternatives. Preserve established conventions
   when they meet the need.
4. Classify the change. A small, reversible internal feature may use a concise feature design.
   A public, cross-cutting, stateful, security-sensitive, or difficult-to-reverse change needs a
   fuller design with migration and rollback.

## Write the design package

Copy `assets/feature-design-template.md` to the repository's established documentation location.
Use the nearest existing feature-design convention when one exists. Name the document consistently
with its issue, ADR, or feature identifier; otherwise use `docs/features/<slug>.md`. For an epic
work package, follow the parent epic's `work-items/` convention and include its work-package ID.
Write in the user's requested language, or the nearest documentation language when none is
specified.

Fill only sections that affect a decision or implementation. The document must contain:

1. Problem, desired outcome, scope, and non-goals.
2. Observable acceptance criteria, including failure and boundary behavior where material.
3. The proposed design: affected components, data and control flow, public API or schema changes,
   and compatibility rules.
4. A behavior-first test plan that maps every acceptance criterion to one or more tests. Include
   test level, setup, observable assertion, and any required fixture or contract test.
5. Risks, operational concerns, migration, and rollback only when the change introduces them.
6. Open questions and decisions explicitly deferred from this feature.

For a work package, record the parent epic, prerequisite work packages, and linked ADRs or
architecture records. A prerequisite that is not approved is a planning blocker, not an invitation
to guess its behavior in this design.

Add a short documentation-disposition forecast when the design is likely to leave durable records.
State which current behavior belongs in code documentation or tests, which cross-cutting rule may
need an architecture record, which difficult-to-reverse choice may need an ADR, and whether the
design itself is likely to be deleted after implementation. This is a forecast for human reviewers,
not authorization to move, archive, or delete documents.

Use examples, sequence diagrams, or tables only when they remove ambiguity. Keep the design tied to
repository evidence; flag an unknown rather than inventing a dependency, API, performance target,
or operational guarantee.

## Handle technology decisions separately

When the feature needs a new package, framework, service, vendor, architectural layer, or another
enduring technical decision, stop treating it as an implementation detail. Invoke
`select-technology` to create the appropriate evaluation record and ADR, then link its decision
from the feature design. Do not select a technology on intuition alone.

## Approval gate

Before creating or editing production code, tests, packages, infrastructure, or project structure,
present the design draft with:

1. Scope and non-goals.
2. Acceptance criteria and their test mapping.
3. Proposed component/API changes and significant alternatives rejected.
4. Risks, migration or rollback, and unresolved questions.

Wait for explicit user approval. Approval makes the design an input to `implement-feature-tdd`; it
does not authorize unrelated changes. If implementation reveals a material mismatch, update the
design and obtain approval again before proceeding.
