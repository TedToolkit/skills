---
name: library-product-intent
description: >-
  Establish, review, or revise the durable product intent of a reusable software library. Use when
  creating a library, its purpose, target consumers, problem, value, or deliberate non-goals are
  unclear; when a proposed public API, audience, or scope may reposition a library; or when a team
  needs a product-intent record that informs design principles, architecture, and change designs.
  Do not use for a one-off feature, technical implementation choice, or README-only edit.
---

# Library Product Intent

Make the reason a library exists explicit before technical governance turns it into constraints.
Product intent answers who has which problem, what value the library provides, and what it will not
try to solve. It is a durable input to design principles, architecture records, and changes; it is
not a marketing plan, API reference, or feature backlog.

This skill owns only the library's purpose, consumers, value, and boundaries. Record downstream
implications, but hand recurring technical defaults to `design-principles`, enduring technical
choices to `architecture-design`, delivery behavior to `change-design`, and usage guidance to
`write-readme`.

## Inspect and classify

1. Read repository guidance, the root README, package metadata, public API, samples, consumer
   documentation, issues or requests in scope, and existing `docs/product/`, principles,
   architecture records, ADRs, and active changes.
2. Separate evidence from assumptions. Do not infer the intended audience or value solely from a
   project name or current code.
3. Copy the product-intent template immediately, mark it `Draft`, and write the available evidence
   and explicit unknowns. The Draft is a working record, not an approved product commitment.
4. For a missing target consumer, problem, differentiating value, non-goal, or success evidence,
   ask one highest-impact question at a time. Explain why it affects the record and recommend an
   answer with its main trade-off. On the user's answer, immediately update the Draft's
   **Clarification and decision log** and all affected sections before asking the next question.
   Continue until no material uncertainty remains.
5. Classify the requested record correctly:
   - Durable library purpose and boundary belong in `docs/product/README.md`.
   - First-use instructions and public capability navigation belong in `README.md` or a project
     README; they link to product intent rather than duplicate it.
   - Recurring technical trade-offs belong in `docs/principles/`.
   - Current system boundaries and quality constraints belong in `docs/architecture/`.
   - A difficult-to-reverse technical decision belongs in an ADR; a planned delivery belongs in a
     change design.

## Complete the product-intent record

Continue the Draft created from [product-intent-template.md](assets/product-intent-template.md) at
`docs/product/README.md`. Keep it short enough to guide a design review. Include only claims that
change a decision:

1. A one- or two-sentence positioning statement.
2. Target consumers and the situations in which they use the library.
3. The problem, its evidence or stated assumption, and the value the library supplies.
4. Explicit non-goals, alternatives, and boundary commitments.
5. Observable success evidence and review triggers.
6. The resulting constraints or questions for principles, architecture, and active changes.

Do not choose a technology, promise unmeasured performance, or turn every existing capability into
a commitment. Record an unknown as an assumption with a validation owner or trigger.

## Keep the product record small

Start with `docs/product/README.md` as the single entry point and source of truth. Do not create a
product-document tree merely because these files are available. Split only when a distinct content
set has a different audience, owner, or revision cadence:

```text
docs/product/
  README.md       # always: positioning, problem, value, boundaries, success evidence
  audiences.md    # optional: distinct consumers or situations no longer fit clearly in README
  evidence.md     # optional: research, usage data, and alternative analysis cited by README
  roadmap.md      # optional: durable outcome direction, not an implementation-task backlog
```

Keep `README.md` as a concise index and link to optional records. Put technical decisions in
`docs/adr/`, delivery requirements in `docs/changes/`, API guidance in README files, and obsolete
product-process documents in Git history rather than `docs/product/history/` or a decision log.

## Govern revisions and downstream use

Treat an approved product-intent revision as the product baseline. Revisit it when the intended
audience, primary problem, value proposition, deliberate non-goal, or success measure changes; do
not revise it merely to justify one feature.

- `design-principles` derives recurring technical defaults from the approved intent.
- `architecture-design` derives boundaries and quality attributes from it.
- `change-design` reads it when a change affects public positioning, scope, target users, or a
  stated boundary. Pin the approved revision and restate its implementation-facing constraint in
  the work package; ordinary internal fixes need not cite it.
- `write-readme` may summarize the positioning statement and link to this record, but must not keep
  a competing full copy.

## Approval gate

Present the positioning statement, target consumers, problem and evidence, non-goals, success
evidence, resulting downstream implications, and unresolved assumptions. The `Draft`
`docs/product/README.md` may be created and revised during clarification; wait for explicit approval
before marking it `Approved`, creating or revising design principles, architecture records, ADRs,
or production code.
