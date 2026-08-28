# Technology selection and benchmark evidence

Use this reference only when an architecture decision compares technology options or needs
measured evidence. The ADR remains the decision record; this workflow supplies proportionate
evidence for it.

## Define the comparison

1. State the capability, boundary, and time horizon the technology must serve.
2. Inspect the runtime, licenses, deployment model, team conventions, current dependencies, and
   operational constraints.
3. Separate hard constraints from preferences and success criteria. Include interoperability,
   security, performance, deployment, ownership, migration, and support lifetime only when
   material.
4. List the status quo and credible alternatives. Eliminate an option only for a recorded
   hard-constraint failure.

Prefer the existing platform and conventions when they meet the need without material compromise.
Make the continuing cost visible: dependency or service count, runtime footprint, licensing,
upgrade cadence, lock-in, observability, and exit path.

## Evaluate all material dimensions

Compare the public API and integration model, compatibility with the affected TFMs, dependency and
transitive-dependency footprint, licensing, maintenance and release cadence, documentation,
community and vendor support, security response, observability, deployment, migration, operational
ownership, rollback, and vendor lock-in whenever they can change the decision. Link the primary
evidence for each material claim. For an evidence-backed ADR, copy
[api-analysis-template.md](../assets/api-analysis-template.md) or
[ecosystem-analysis-template.md](../assets/ecosystem-analysis-template.md) only when that analysis
materially affects the choice.

When performance determines which candidate is better, first identify the observable bottleneck and
decision threshold. Read [benchmarkdotnet.md](benchmarkdotnet.md) only for representative managed
in-process comparisons. For service, database, network, queue, or distributed behavior, select
representative load, tail-latency, throughput, error, resource, profiling, or production-telemetry
evidence instead. Do not let a faster microbenchmark override a hard compatibility, security, or
operational constraint.

## Plan a benchmark only when it can decide the issue

Create `benchmark-plan.md` from [benchmark-plan-template.md](../assets/benchmark-plan-template.md)
before an experiment. Record hypothesis, candidate versions, representative workload and data,
metrics and pass/fail thresholds, environment, commands, warm-up, repetitions, and validity risks.

Read [evidence-and-metrics.md](evidence-and-metrics.md) when selecting metrics, judging benchmark
validity, or assigning evidence confidence. Preserve the experiment's evidence in the ADR's
`evidence/` directory after it runs: command, configuration, seeds, raw output, reports, and charts.
Keep its executable source in the ADR's sibling `benchmark/` directory and list that project in
`docs/adr/Benchmark.slnx`. Report distributions,
error rate, throughput, and resource use when relevant; never select from one best run. Mark results
non-comparable when equivalent conditions cannot be established.

## Compare and recommend

Create `evaluation-matrix.md` from
[evaluation-matrix-template.md](../assets/evaluation-matrix-template.md) after collecting evidence.
Record hard constraints separately from weighted criteria. Define criteria, weights, scoring scale,
and thresholds before scoring; include only decision-relevant categories. A weighted score informs a
decision but does not override a hard-constraint failure or material operational risk.

Classify each material assertion as measured, documented, or assumed. Prefer reproducible internal
evidence, then primary documentation, then verified external experience. Give each assertion a
source and confidence level. Record every decision-shaping, low-confidence assumption with an owner
and due date.
