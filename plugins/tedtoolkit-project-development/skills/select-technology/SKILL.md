---
name: select-technology
description: >-
  Evaluate and document traceable technology selections for any project, including languages,
  frameworks, libraries, databases, architecture, hosting, build tools, test frameworks,
  dependencies, and vendors. Use when comparing viable alternatives, planning or running a PoC or
  benchmark, or creating an ADR, evaluation matrix, and reproducible decision record.
---

# Select Technology

Choose technology to serve a concrete product and maintenance need, not novelty or hypothetical
scale. Prefer the smallest proven option that fits the repository, team capability, and explicit
constraints. Treat adding a dependency, service, or architectural layer as a continuing cost.

Produce a decision record rather than only a recommendation. Copy the three templates in `assets/`
to the repository's existing documentation location: a benchmark plan, an evaluation matrix, and an
ADR. For small reversible decisions, record the comparison and rationale in the issue or pull
request; do not impose ADR ceremony.

## Choose the output language

Write every deliverable in the user's explicitly requested language. Otherwise, use the language of
the nearest existing documentation and its intended audience. Ask before drafting if neither makes
the language clear. Treat all template text as structure: translate headings, labels, instructions,
and prose into the selected language; preserve code, commands, file names, identifiers, product
names, and established technical terms unless the audience convention calls for a translation.

## Define the decision before collecting results

1. State the decision in one sentence: the capability, boundary, and time horizon it must serve.
2. Inspect the existing repository, deployed environment, SDK/runtime constraints, licenses,
   operational model, team conventions, and current dependencies. Ask for the missing constraint
   when it would change the recommendation.
3. Separate hard constraints from preferences and success criteria. Include interoperability,
   security, performance, deployment, ownership, migration, and support lifetime only when material.
4. List the status quo and credible alternatives. Eliminate an option only for a recorded
   hard-constraint failure.
5. Create `benchmark-plan.md` from `assets/benchmark-plan-template.md` before an experiment. Record hypothesis, candidate versions,
   representative workload and data, metrics and pass/fail thresholds, environment, commands,
   warm-up, repetitions, and known validity risks.

Ask for missing workload, success criteria, or hard constraints before recommending when they would
materially change the choice. Do not infer a production workload from a toy benchmark.

## Collect comparable evidence

Read `references/evidence-and-metrics.md` when choosing metrics, evaluating benchmark validity, or
assigning evidence confidence.

- Use equivalent data, versions, capacity, duration, and warm-up conditions for every benchmark
  candidate. Preserve exact commands, configuration, seeds, raw output, and generated charts.
- Report distributions, such as P50/P95/P99, error rate, throughput, and resource use where
  relevant; do not select an option from a single best run.
- Mark results as non-comparable when equivalent conditions cannot be established.
- Classify each assertion as measured, documented, or assumed. Prefer reproducible internal
  evidence, then primary documentation, then verified external experience. Give each material
  assertion a source location and confidence: high, medium, or low.
- Record unvalidated low-confidence assumptions with an owner and due date.

## Evaluate and decide

Create `evaluation-matrix.md` from `assets/evaluation-matrix-template.md` after collecting
evidence. Include hard constraints separately from weighted criteria. Define criteria, weights,
scoring scale, and thresholds before scoring. Include only decision-relevant categories:
performance, reliability, cost, security/compliance, operability, ecosystem, and migration risk.

A weighted score is decision support, not an automatic answer. A hard-constraint failure or
material operational risk can override it; record why.

## Write the ADR

Create `ADR-<number>-<slug>.md` from `assets/adr-template.md` for a material or enduring decision.
Include:

1. Status, date, owner, decision question, constraints, and review trigger.
2. Considered options, including status quo, and the decisive reason each was rejected or selected.
3. The decision and links to the benchmark plan, evaluation matrix, raw results, PoC, and source
   documentation.
4. Consequences, accepted trade-offs, rollout plan, and rollback/exit path.

Write rejected alternatives for future human maintainers: state why each option was not selected now
and what changed evidence or constraint would justify reconsidering it. Keep this reasoning in the
ADR rather than in a superseded change document.

Use `proposed` before review and `accepted`, `superseded`, or `rejected` afterwards. Do not rewrite
an accepted ADR to conceal a changed decision; create a superseding ADR.

## Apply decision rules

- Prefer the existing platform, conventions, and skills when they meet the need without material
  compromise.
- Prefer standards, stable public APIs, ordinary tooling, and low operational burden over a more
  fashionable or abstract option.
- Reject an option that solves only speculative future needs, duplicates an existing capability, or
  introduces an unowned service, framework, or transitive dependency.
- Make cost visible: package/service count, runtime footprint, licensing, upgrade cadence, lock-in,
  observability, and rollback or exit path.
- Distinguish a reversible local choice from a cross-cutting or irreversible commitment. Require
  stronger evidence and an explicit owner for the latter.

## Present a decision draft

Before changing code, packages, infrastructure, or project structure, show:

1. Context and non-negotiable constraints.
2. Options considered, including the status quo, with decisive trade-offs.
3. Recommendation, why it wins now, and conditions that would invalidate it.
4. Evidence summary: benchmark result, source link, confidence, and any unvalidated assumption.
5. Consequences: migration, tests, documentation, operational ownership, and rollback plan where
   applicable.

Wait for explicit approval before implementing the selected option. Record material or enduring
decisions in the repository's existing ADR or documentation format.
