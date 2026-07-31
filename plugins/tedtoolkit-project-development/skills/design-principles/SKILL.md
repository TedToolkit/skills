---
name: design-principles
description: >-
  Govern recurring architecture and engineering trade-offs with repository design principles. Use
  when a stable default, rationale, strength, scope, review trigger, or exception route must be
  created, revised, retired, or distinguished from a one-off architecture decision.
---

# Design Principles

Keep principles **few** and durable enough to decide a real recurring trade-off. Principles are the highest-level
technical governance source: they must conform to approved product intent, architecture design must
follow them, and later layers may only make them more concrete. A principle is a default for a
recurring trade-off, not a retrospective description of code and not a substitute for an ADR.

This skill owns recurring technical defaults. Read
[change-development-workflow.md](../../references/change-development-workflow.md) before
classifying another concern. Its governing dependency direction is authoritative; re-establish
every principle from durable evidence. Invoke `architecture-design` for a one-off enduring
technical decision and `change-design` for a bounded delivery contract.

## Inspect and classify

1. Read repository guidance, `docs/product/README.md` when it exists, `docs/principles/`, applicable
   architecture records, related ADRs, representative current code, and durable repository evidence.
2. Copy the principle templates immediately, leave their status as `Draft`, and record the known
   evidence and unknowns. These Drafts support discussion only; they do not activate a principle.
3. State the recurring decision, governed scope, owner, and the long-term cost the principle should
   protect against. For each missing point that could change the rule, ask one highest-impact
   question with why it matters and a recommended answer plus its main trade-off. When the user
   answers, immediately update the Draft's **Clarification and decision log** and affected
   principle fields, then continue with the next question. Repeat until no material ambiguity
   remains.
4. Classify the record before writing it:
   - A recurring default with a stable rationale belongs in `docs/principles/`.
   - Current component boundaries or cross-cutting behavior belong in `docs/architecture/`.
   - A material, durable, or difficult-to-reverse choice and any approved exception belongs in an ADR.
   - A change-specific behavioral contract or delivery boundary belongs in `docs/changes/`; private
     implementation design does not.
5. Do not create a principle for a one-off preference, an executable formatting rule, or an
   unexamined generalization from one change.

## Write the principle set

Complete the following three Draft files created from the provided assets. The index states scope,
precedence, principle index, owner or review trigger, and the exception route; the two topic files
hold the principles themselves:

```text
docs/principles/
  README.md          # scope, precedence, exception route, index
  architecture.md    # boundaries, dependency direction, evolution
  engineering.md     # testability, compatibility, observability, operations
```

Use [principles-readme-template.md](assets/principles-readme-template.md),
[architecture-principles-template.md](assets/architecture-principles-template.md), and
[engineering-principles-template.md](assets/engineering-principles-template.md). Remove a blank
principle block rather than leaving a placeholder in an approved document.

For each principle, record a stable ID, status (`Draft`, `Active`, or `Retired`), strength, default
direction, rationale, practical implications, and exception route. The status is the principle's
governance lifecycle, not a delivery or Git lifecycle: write exactly one allowed value, never a
compound label such as "approved, pending commit". `Active` means approved and currently in force;
whether its documentation has been committed is outside the principle documents. Use only these strengths:

- `Required`: deviation needs an accepted ADR before implementation, except an explicitly stated
  emergency process.
- `Default`: explain the deviation in the change design; create an ADR when it is durable or hard to
  reverse.
- `Advisory`: reviewers may request a rationale, but no durable exception record is required.

External hard constraints and security or compliance obligations take precedence. An accepted ADR
may define a narrower exception; it does not silently rewrite the principle. Architecture design
must link the principles it follows or intentionally overrides. Link durable ADRs and architecture
records rather than copying their rationale. Never link a change or delivery artifact from a
principle document.

## Govern changes and exceptions

Treat a proposed deviation as a design question, not a rule violation to hide:

1. Confirm the applicable principle and its strength.
2. Decide whether the change conforms, needs clarification, or needs an exception.
3. Stop for an accepted ADR when a `Required` principle is materially or durably exceeded. For a
   `Default` principle, record the rationale in the change design and escalate to an ADR when the
   exception becomes enduring or difficult to reverse.
4. Amend a principle only when the recurring default has changed; do not amend it merely to justify
   a single implementation.
5. Retire a principle when it no longer governs current decisions. Preserve links to related ADRs;
   do not rewrite historical decisions.

## Approval gate

Present the proposed principle or revision with its scope, alternatives, strength, practical effect
on delivery work, and exception route. Draft principle files may be created and revised during the
clarification loop; wait for explicit approval before changing any principle to `Active`, creating
an architecture record or ADR, or changing production code.

Complete when each principle governs a recurring choice, has one rationale and exception route,
depends only on durable evidence, and is either explicitly activated by the user or remains a Draft
with its unresolved decisions recorded.
