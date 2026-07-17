# ADR-<number>: <Decision title>

> Template language is not output language. Translate every heading, label, and prose placeholder
> to the selected document language; preserve commands, file names, identifiers, and product names.

- Status: Proposed | Accepted | Superseded | Rejected
- Date:
- Decision owner:
- Decision scope: what system boundary, capability, or time horizon this governs.
- Applicable principles: relative links to `docs/principles/`, or None. State any deliberate
  exception and why it is justified.
- Related change or work packages:
- Supersedes: ADR-<number> or None
- Superseded by: ADR-<number> or None

## 📌 Decision at a glance

State the decision in one precise sentence. A reader should understand the chosen direction without
reading the rest of the record.

## 🧭 Context and decision question

Describe the current situation and the concrete question this ADR resolves. Include only context
that changes the decision; link detailed change plans instead of copying them.

## 🎯 Decision drivers and constraints

List the hard constraints first, then the desired qualities used to compare options. State how each
will be evaluated and distinguish facts from assumptions.

| Type | Driver or constraint | Evidence or source | Priority |
| --- | --- | --- | --- |
| Hard constraint / decision driver |  |  | Must / High / Medium |

## 🔎 Options and evidence

Include the status quo. Give only decision-relevant evidence; label it Measured, Documented, or
Assumed so a future reader can assess confidence.

| Option | Evidence and confidence | Meets drivers | Decisive trade-off | Outcome |
| --- | --- | --- | --- |
| Status quo |  |  |  | Rejected / Selected |

## ✅ Decision

State the selected option, its version or boundary when material, and what is explicitly not being
chosen.

## 💡 Why this decision now

Connect the decision to the applicable principles, drivers, and evidence above. Explain why rejected
options are unsuitable now, including any deliberate principle exception, and name the changed
evidence, constraint, or product need that would justify reconsideration.

## 🔗 Evidence and links

Link benchmark raw results, matrix, PoC, source documentation, and issue or PR records.
For an evidence-backed ADR, keep reproducible BenchmarkDotNet reports beneath
`evidence/benchmark/` and link the Markdown summary and JSON report here. Record the benchmark
project path, command, selected TFMs, runtime/SDK, hardware and operating system so a reader can
judge whether the result applies.

For an ADR-specific benchmark, keep source in the sibling `benchmark/` directory and record its
entry in `docs/adr/Benchmark.slnx`. That catalog is for opening benchmark projects only; it is not
part of the main solution or default CI build.

Use `evidence/README.md` as the index for every evidence-backed ADR. Link `api-analysis.md`,
`ecosystem-analysis.md`, or `poc/README.md` only when those records materially support the decision.

## ⚖️ Consequences and accepted trade-offs

State the positive outcomes, costs, limitations, and obligations that follow from this decision.
Include compatibility, security, operations, licensing, vendor lock-in, and maintenance only when
material.

## 🛠️ Implementation handoff

Link the affected change and work packages. State only the implementation constraints imposed
by this decision; do not duplicate their designs or test plans.

## 🔄 Rollout, rollback, and exit

Include only when the decision changes deployment, state, public compatibility, or introduces a
service or dependency that needs an exit path.

## 📅 Follow-ups and review triggers

| Item | Owner | Due date or objective trigger | Status |
| --- | --- | --- | --- |
|  |  |  | Open |

State objective conditions that require reassessment, such as a cost threshold, scale change,
security issue, required platform change, or sustained SLO failure. When this ADR is superseded,
update its status and link the replacement instead of rewriting its decision rationale.
