# Scalable testing and proof strategy

This reference separates **why proof exists** from **how it executes**. Every approved behavior
or preserved invariant needs credible proof, but small projects do not need Unit, Integration, and
Acceptance suites for every change.

Keep three artifacts conceptually separate:

- a **proof definition** names the test, assertion, command, or bounded procedure expected to
  demonstrate a contract;
- a **verification result** records what actually ran, on which exact candidate and environment,
  with observed counts and limitations; and
- **traceability** maps the approved contract through implementation and proof definition to that
  result and states whether the proof is adequate.

Test source is usually part of the proof definition. It is not a historical run result: do not write
"passed" counts, candidate SHAs, or transient execution status into long-lived tests. Use CI/test
artifacts, a candidate-bound delivery record, or another repository-approved result location, then
let `review-implementation` synthesize traceability.

## Three independent dimensions

### Proof role

Role describes how evidence contributes to the delivery decision:

- **Primary** directly demonstrates one approved contract row. Every contract row has exactly one
  primary proof definition.
- **Conditional** addresses an additional risk that applies to the change, such as regression,
  compatibility, migration, security, structure, or a deployed journey.

Role is not purpose: a regression can be the primary proof for a bug fix, while a boundary check can
be conditional evidence for the same contract.

### Proof purpose

| Purpose | Question | Required when |
| --- | --- | --- |
| Acceptance | Does the implementation directly demonstrate the approved observable result or invariant? | Every behavior-changing, bug-fix, refactor, or migration contract. |
| Regression proof | Will the observed defect or preserved behavior remain protected? | Bug fixes and material existing behavior touched by the change. |
| Boundary proof | Do real components, protocols, persistence, serialization, DI, filesystem, network, or external services cooperate? | The change crosses or modifies that real boundary. |
| Structural verification | Do builds, analyzers, architecture rules, generators, packages, and repository structure remain valid? | The affected artifact or repository policy requires it. |
| Journey proof | Does a critical deployed user or system journey work end to end? | Failure across the deployed path is material and narrower proof is insufficient. |
| Decision evidence | Does a bounded experiment answer its approved question against representative evidence? | Experiments. |

### Execution shape

Use the narrowest reliable shape that can observe the required result:

- **Unit** for deterministic behavior through a stable callable boundary;
- **Component** for several in-process collaborators with controlled infrastructure;
- **Contract** for public API, serialization, schema, or protocol compatibility;
- **Integration** for real process or infrastructure boundaries;
- **End-to-end** for a critical deployed journey; and
- **Benchmark** for repeatable measurement whose environment, dataset, warmup, sampling, and
  thresholds are part of the evidence contract; and
- **Manual procedure** only when automation is disproportionate or cannot observe the result.

Acceptance is a proof purpose, not a mandatory project or execution shape. A TUnit test calling
a public value-object API may be both Unit-shaped and the primary Acceptance proof. One test may
serve several purposes when the mapping is explicit; do not duplicate its assertion just to fill
layers.

## Scale proof by workflow profile

| Profile | Minimum evidence |
| --- | --- |
| Fast maintenance | The affected build, format, analyzer, documentation, or existing regression command; no invented test for evidenced no-behavior work. |
| Fast bug fix | One narrow reproduction that fails for the root cause, then the affected regression gate. |
| Standard | One primary proof per approved behavior or invariant, plus only conditional proof demanded by the actual boundary or risk. |
| Controlled | Primary proof for every contract row; boundary, compatibility, migration, security, and broader regression evidence where those concerns apply. |
| Controlled multi-item | Each item owns narrow credible proof; verified integration runs the union of affected gates and a proportional change-level regression gate. |

Default to one test project for a small repository. Split Unit, Integration, Contract, or
Acceptance projects only when execution environment, resources, lifecycle, runtime, cadence,
isolation, or ownership differs materially. Folder names do not create stronger evidence.

## Use the loop that matches the change kind

- **Behavior change:** primary-proof Red → smallest inner Red/Green when useful → refactor → primary
  proof Green.
- **Bug fix:** reproduce the root cause Red → smallest Green → affected regression Green.
- **Behavior-preserving refactor:** establish characterization/invariant Green → refactor in small
  steps → keep Green. Do not manufacture a failing test for unchanged behavior.
- **Maintenance:** verify relevant state → make the mechanical change → verify again.
- **Migration:** establish old/new compatibility or transition proof → implement transition → verify
  migrated and recovery paths.
- **Experiment:** run isolated evidence gathering; do not treat a successful spike as production
  approval or regression coverage.

Use repository conventions and authoritative commands. With TUnit, invoke `tunit-testing` when it
is available for layout, lifecycle, isolation, parallelism, data sources, assertions, and mocks.
When that cross-plugin specialist is unavailable, preserve the repository's documented TUnit
conventions and report which framework-specific mechanics were not independently checked.

## Change format 3

New profile-aware change records use stable, language-independent markers:

```md
<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: bug-fix -->
<!-- change-status: draft -->
<!-- delivery-shape: single -->
```

Visible headings and prose may use the repository language. Deterministic scripts parse markers,
not translated headings. Legacy format-2 change records may complete under their approved
contracts; revise a material change contract into format 3. Work-item format 2 remains the current
item schema and is not a legacy change format.

### Behavior-changing contracts

Describe observable deltas with markers:

```md
<!-- section: behavior-contract -->
<!-- behavior-change: OB-01 -->
```

Use one stable acceptance marker per principal result. Gherkin remains useful when it makes an
observable success, failure, or boundary result clearer; do not require it for a behavior-preserving
refactor or mechanical maintenance.

````md
<!-- acceptance-case: AC-01 -->
### AC-01 — <title>

```gherkin
Scenario: <title>
  Given <observable precondition>
  When <one observable action occurs>
  Then <one pass-or-fail result is visible>
```
````

The case must avoid private algorithms, fixtures, mocks, test files, and work-item sequencing.

### Behavior-preserving contracts

State observable invariants instead of inventing a delta:

```md
<!-- preserved-invariant: INV-01 -->
- Public normalization results remain unchanged for all currently supported inputs.
```

### Maintenance contracts

Mechanical maintenance states the observable target repository or artifact state rather than
mislabeling a changed structure as a preserved invariant:

```md
<!-- section: structural-contract -->
<!-- structural-outcome: STR-01 -->
- STR-01: The documentation link checker reports no broken local links.
```

### Experiment contracts

Experiments prove or disprove a decision-relevant claim and never authorize production behavior:

```md
<!-- section: experiment-contract -->
<!-- experiment: EXP-01 -->
- Decision question or hypothesis:
- Evidence method and representative boundary:
- Success or falsification signal:
- Stop condition and expiry:
- Owner and downstream decision:
```

Do not invent `AC-*` behavior results for an experiment. If the evidence supports a product or
library behavior change, route that behavior through a separate approved change.

### Proof plan

Every Standard change and Controlled delivery maps its contract to evidence:

```md
<!-- section: proof-plan -->
<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
| Contract | Role | Proof purpose | Execution shape | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- | --- | --- |
| AC-01 | Primary | Acceptance and regression | Unit through public API | Valid input returns the expected value | Repository test command |
```

Use one stable `primary-proof` marker for each contract row so deterministic validation does not
depend on translated headings or table labels. Normalize marker values to lowercase identifiers.
Marker purposes are `acceptance`, `regression`, `boundary`, `structural`, `journey`, or `decision`;
execution shapes are `unit`, `component`, `contract`, `integration`, `end-to-end`, `benchmark`, or
`manual`. Keep `Primary` as the stable proof-row Role value and provide an observable assertion plus
an actual command or bounded procedure.
Conditional rows need no marker unless another automation contract explicitly defines one.

The execution shape is chosen for reliability, not status. Do not require Integration when no real
boundary exists, Unit when there is no nontrivial deterministic behavior to isolate, or End-to-end
when a narrower proof credibly demonstrates the result.

## Work-item ownership

For a multi-item Controlled change, reference parent `AC-<number>`, `INV-<number>`, or
`STR-<number>` IDs without
copying their prose. Each contract row has exactly one final owner; supporting items name the
verified input they supply. Every owning item records a primary proof. Conditional boundary or
migration evidence belongs to the item that changes that risk.

## Verification results

Record observed results against the exact candidate revision:

- contract ID and proof purpose;
- execution shape;
- command or approved bounded manual procedure;
- observable assertion;
- discovered, passed, failed, or skipped counts when available;
- resource or environment prerequisites; and
- result.

A broad build alone is insufficient for a behavior contract, but it may be the complete result for a
mechanical build or repository-structure change whose approved outcome is exactly that build state.
A passing result does not establish that the proof definition covered every material behavior
partition; `review-tests` judges adequacy and `review-implementation` owns the final traceability.
