---
name: architecture-design
description: >-
  Create, review, or revise current architecture records and Architecture Decision Records (ADRs)
  for enduring architecture, technology, dependency, security, operational, or cross-cutting product
  decisions. Use when designing system boundaries, dependency direction, cross-cutting behavior, or
  quality attributes; when a decision needs durable rationale, alternatives, consequences, and an
  owner; or when technology selection or benchmark evidence informs architecture.
---

# Architecture Design

Architecture design turns applicable principles into the current system boundary and constraints that
later change designs must refine. Use `docs/architecture/` for current boundaries, dependency
direction, cross-cutting behavior, and quality attributes. Use an ADR only for a material, enduring,
or difficult-to-reverse choice; do not create one for an abandoned sketch or local implementation
detail.

## Inspect the architecture

1. State the architecture scope, governed system boundary, and time horizon in one sentence.
2. Inspect repository conventions, applicable design principles, current architecture, dependencies,
   deployment and operational constraints, relevant ADRs, and the status quo.
3. Separate hard constraints from preferences and list credible alternatives, including the status
   quo. Do not reject an option without recording the constraint or evidence that rules it out.
4. Ask for a missing constraint, decision owner, or success criterion when it could change the
   decision. Do not invent product workload, risk tolerance, or operational ownership.
5. Show how the proposed architecture conforms to each applicable principle, or identify the
   deliberate exception and its required ADR status.

## Write the architecture record

Create or revise `docs/architecture/<topic>.md` from
[architecture-record-template.md](assets/architecture-record-template.md). Record governing
principles, current boundaries and dependency direction, material flows, quality constraints, and
objective review triggers. Describe current intended architecture, not an implementation plan or a
history of alternatives.

Pin the record's full Git commit SHA from an approved revision when a later change design references
it. When the record changes while a dependent change is active, that change must reassess and gain
approval again before implementation continues.

## Choose evidence proportionately

Use the lightest evidence that can justify the decision. Existing code, incident data, primary
documentation, or a focused proof of concept may be enough. When the decision compares a language,
framework, library, database, service, vendor, build tool, or other technology, read
[technology-selection.md](references/technology-selection.md). Read
[benchmarkdotnet.md](references/benchmarkdotnet.md) before creating a benchmark project or running
BenchmarkDotNet.

When a performance claim, a performance-sensitive workload, or cross-TFM performance determines
which option is "better", a representative BenchmarkDotNet run is required evidence. Benchmark only
the affected consumer TFMs that every compared option supports; do not infer a production workload
from a toy benchmark. Performance evidence is unnecessary when it cannot change a decision governed
solely by another hard constraint, such as license or compliance.

## Record an ADR when needed

Create `ADR-<number>-<slug>.md` from [adr-template.md](assets/adr-template.md) in the repository's
existing ADR location. Keep ordinary ADRs as one file. When an ADR needs benchmark source, raw
results, a PoC, or another durable evidence set, use `ADR-<number>-<slug>/README.md` for the ADR and copy
[evidence-index-template.md](assets/evidence-index-template.md) to `evidence/README.md`. Add only
the evidence directories that the decision needs: `benchmark/`, `api-analysis.md`,
`ecosystem-analysis.md`, or `poc/`. Copy
[poc-manifest-template.md](assets/poc-manifest-template.md) to `evidence/poc/README.md` for every
retained PoC; the technology-selection reference selects the API and ecosystem templates. Do not
create a directory merely to hold a single Markdown file or duplicate the ADR's decision rationale
in evidence files. Keep executable benchmark source in the ADR's `benchmark/` sibling directory,
not in `evidence/`.

Include:

1. Status, date, owner, governing scope, decision at a glance, applicable principles, and related
   or superseded ADRs.
2. The context, precise decision question, drivers, and hard constraints.
3. Considered alternatives, including the status quo, with decision-relevant evidence and decisive
   trade-offs.
4. The selected direction, why it is justified now, and evidence or conditions that require
   reconsideration.
5. Consequences, accepted costs, implementation constraints, API compatibility, ecosystem and
   operational implications, and rollout, rollback, or exit path when material.
6. Evidence links, follow-up ownership, and objective review triggers.

Distinguish measured evidence, documented claims, and assumptions. Link raw results, proof-of-
concept work, evaluation matrices, source documentation, related architecture records, and change
designs rather than duplicating them. Do not call an option "best" or "simpler" without the driver
and evidence that make it so.

Use `Proposed` before approval and `Accepted`, `Rejected`, or `Superseded` afterwards. Do not rewrite
an accepted ADR to conceal a new choice: create a superseding ADR, link both records, and state the
changed evidence, constraint, or product need. Keep superseded ADRs in `docs/adr/`; use Git history
for obsolete process documents.

## Benchmark source and evidence

Keep ADR-specific executable benchmark projects beside their ADR, outside the product source tree:

- Use `docs/adr/ADR-<number>-<slug>/benchmark/` for every benchmark whose purpose is evidence for
  that ADR. Add or update its relative project path in `docs/adr/Benchmark.slnx`, the navigation
  catalog for ADR benchmarks; initialize it from
  [adr-benchmark-catalog.slnx](assets/adr-benchmark-catalog.slnx) when needed. Do not add either
  project to the main `.slnx` or default CI build.
- Promote a benchmark only when it becomes a maintained performance suite. Move it to
  `benchmarks/<Product>.<Area>.Benchmarks/`, keep it out of the main `.slnx`, and use a dedicated
  performance solution when the repository needs one.

`docs/adr/Benchmark.slnx` exists only to open ADR benchmark projects conveniently. It is not a
repository build entry point or a CI target; update it when an ADR benchmark project is added,
renamed, moved, or removed.

The ADR links to the benchmark project path and commit, and preserves the run manifest and selected
generated reports under `docs/adr/.../evidence/benchmark/`. Do not commit build output or the entire
`BenchmarkDotNet.Artifacts` directory.

## Present an architecture draft

Before changing code, packages, infrastructure, or project structure, show:

1. Scope, governing principles, current architecture baseline, and non-negotiable constraints.
2. Proposed architecture record changes: boundaries, dependency direction, and quality constraints.
3. Any ADR alternatives, evidence confidence, and conditions that invalidate the decision.
4. Consequences: affected change designs, implementation constraints, migration, tests,
   documentation, operational ownership, and rollback where applicable.

Wait for explicit approval before changing architecture records, ADRs, benchmark projects, code,
packages, or infrastructure. Record the approved architecture in `docs/architecture/` and any
approved enduring decision in the repository's ADR format.
