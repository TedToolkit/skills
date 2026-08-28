# Calibrate quality policy to repository rules and representative evidence

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: bug-fix -->
<!-- change-status: candidate-ready -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: commit:fba90f30bec6182226002df68226a17e4a518950 -->

<!-- section: goal-rationale -->
## Goal and rationale

Project-development guidance honors an explicit repository Cognitive Complexity threshold and
selects performance evidence that represents the real system boundary. Today it silently overrides
a repository threshold above `15` and requires BenchmarkDotNet even when the decision concerns a
service, database, network, or distributed-system boundary that an in-process microbenchmark cannot
credibly measure.

<!-- section: scope -->
## Scope and non-goals

- In scope: Cognitive Complexity policy precedence and no-policy fallback; consistent implementation
  and review wording; performance-evidence selection in architecture design; BenchmarkDotNet's
  applicability boundary; positive and near-miss evals for both policy branches.
- Non-goals: setting a threshold for any consumer repository, adding or configuring analyzers,
  creating a universal load-test framework, removing BenchmarkDotNet support, changing existing
  ADR decisions, or treating performance evidence as a substitute for compatibility, security, or
  operational constraints.
- Compatibility or deliberately preserved behavior: repository analyzers and CI remain the source
  of measured complexity results; no score is invented without tooling; performance-sensitive
  decisions still require representative evidence; existing valid BenchmarkDotNet projects,
  manifests, reports, and ADR catalog behavior remain supported.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Quality-policy and performance-evidence selection | A repository threshold above 15 is overridden, and any decision-shaping performance claim requires BenchmarkDotNet | Explicit repository policy is authoritative in either direction; without one, 15 is advisory; measurement shape follows the real boundary | Evidence remains reproducible, attributable, and proportionate to the decision |

<!-- acceptance-case: AC-01 -->
### AC-01 — Explicit repository complexity policy is authoritative

```gherkin
Scenario: A repository configures its own Cognitive Complexity threshold
  Given the authoritative analyzer, quality profile, repository guidance, or CI gate specifies a threshold stricter or looser than 15
  When implementation or review evaluates an in-scope callable
  Then it applies the repository threshold without imposing a separate 15 limit and cites the authoritative source and measured result
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Fifteen is advisory when no repository policy exists

```gherkin
Scenario: No authoritative Cognitive Complexity threshold is configured
  Given the repository provides no numeric complexity policy or measurable analyzer gate
  When implementation or review assesses changed control flow
  Then it may use 15 as an advisory starting point, reports any unverified measurement limitation, and does not invent a score or a mandatory repository exception
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Use BenchmarkDotNet for a representative managed microbenchmark

```gherkin
Scenario: An architecture choice depends on isolated managed-code cost
  Given equivalent in-process operations can represent the decision-relevant CPU, throughput, or allocation boundary
  When measured performance can change the option selection
  Then the architecture workflow may require a reproducible BenchmarkDotNet experiment with representative inputs, environment, distributions, and validity limits
```

<!-- acceptance-case: AC-04 -->
### AC-04 — Measure service and infrastructure performance at the real boundary

```gherkin
Scenario: An architecture choice depends on service, database, network, or distributed behavior
  Given queuing, remote dependencies, concurrency, failure rate, capacity, or end-to-end latency can determine the result
  When performance evidence is planned
  Then the workflow selects representative load, tail-latency, resource, profiling, or production-telemetry evidence and does not create a BenchmarkDotNet project merely because performance matters
```

## Constraints and risks

- Repository authority must be explicit and traceable. If analyzer configuration, repository
  guidance, and CI disagree, report the conflict as a policy blocker instead of choosing the most
  convenient threshold.
- Advisory `15` guides maintainability discussion only when no repository policy exists. It must not
  silently become analyzer configuration, a hard completion gate, or an exception record the
  repository never adopted.
- Choose the evidence shape from the observable bottleneck and decision threshold. BenchmarkDotNet
  is suitable only when an isolated managed in-process workload represents the claim; it may be one
  supporting measurement but cannot replace real-boundary evidence for remote or distributed
  behavior.
- Preserve raw results, environment, workload, distributions, limitations, and confidence for every
  chosen measurement shape. A single fastest run, unit-test duration, or handwritten loop timer is
  not decision evidence.
- Do not begin implementation while the current feasibility-preflight work owns uncommitted changes
  in `implement-change/SKILL.md`. Wait until that work is completed and its working-tree ownership is
  released, then reconcile this change against the resulting candidate. This is a runtime write-set
  collision, not a semantic dependency, because this change consumes none of its contract outcomes.
- A newly required repository-wide quality policy, maintained performance platform, production load
  operation, credential use, or externally impactful test is an escalation requiring its own
  authorization boundary.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Contractually ready from approved baseline
`d3ddb70db54ba3d78a848e995b940f944a6cc7d6`; implementation remains serialized behind the current
feasibility-preflight writer collision described above.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: project-development code-quality references, implementation and
  review guidance, architecture performance-evidence references, and focused model evals express
  one repository-governed evidence policy.
- Other real start conditions or resource prerequisites: the feasibility-preflight writer releases
  `implement-change/SKILL.md`; the implementer re-reads the exact post-collision file before edits;
  model evals use hermetic repositories with explicit stricter, looser, and absent policy fixtures.
- Likely touchpoints (non-binding): `references/code-quality/cognitive-complexity.md`,
  `implement-change`, `review-code`, `architecture-design`, its technology-selection,
  evidence/metrics and BenchmarkDotNet references, and their focused eval fixtures.
- Private implementation choices left open: wording layout, fixture organization, how synthetic
  repository policy is represented, and whether non-microbenchmark evidence guidance is co-located
  or disclosed through an additional reference.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=regression shape=component -->
<!-- primary-proof: AC-02 purpose=acceptance shape=component -->
<!-- primary-proof: AC-03 purpose=regression shape=component -->
<!-- primary-proof: AC-04 purpose=boundary shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Positive and near-miss fixtures with stricter and looser explicit thresholds both select the repository value and cite its source | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development implement-change review-code` |
| AC-02 | Primary | A no-policy fixture describes 15 as advisory, reports missing mechanical evidence, and creates no analyzer rule or mandatory exception | Same focused implementation and review eval command |
| AC-03 | Primary | The existing isolated serialization comparison still selects BenchmarkDotNet and produces the approved ADR-local evidence shape | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development architecture-design` |
| AC-04 | Primary | Service, database, network, and distributed near-miss prompts choose representative outer-boundary evidence and do not generate BenchmarkDotNet scaffolding | Same focused architecture eval command |

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-04 pass with both positive and negative evals, existing architecture-design,
implement-change, and review-code regressions remain green, and all references present one
consistent precedence and measurement-selection rule. Implementation began only after the
feasibility-preflight writer collision cleared, the candidate receives proportionate review, no
consumer repository configuration or external performance environment is modified, and no durable
documentation extraction or operational handoff remains.
