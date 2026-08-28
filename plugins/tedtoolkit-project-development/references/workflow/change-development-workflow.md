# Change-development workflow

This reference defines the path from one raw request through scoped, risk-scaled delivery. Records
must let a developer continue without the originating conversation.

Read [testing-strategy.md](testing-strategy.md) when a change defines behavior or proof.
Read [requirements-clarification.md](requirements-clarification.md) when user intent is incomplete.
Read [agent-orchestration.md](../orchestration/agent-orchestration.md) whenever agents are considered.
Read [tool-state-layout.md](../orchestration/tool-state-layout.md) before creating repository-local
TedToolkit state.

## Human-readable delivery records

`change.md` and work-item files contain current approved truth, not transcripts or workflow
machinery. Keep stable machine markers; put scheduling, leases, receipts, and other control state in
the prescribed tool-state artifact. Include only implementation-, proof-, review-, release-, or
risk-relevant facts. Likely touchpoints may be non-binding; private files, types, algorithms, and
test organization remain open. Prefer the shortest complete record: Standard changes commonly fit
40–100 lines and focused items 40–80, but completeness controls.

Apply the **five-minute handoff test**: a new developer can find the goal; current, expected, and
preserved behavior; scope/non-goals; contracts/constraints/risks; real prerequisites and supplied
inputs; primary and conditional proof; and open private choices. Add missing facts and remove or
relocate process detail that hides them.

## Scope the request in `scope-changes`

`scope-changes` owns new requests without established boundaries. It maps every material part
exactly once to candidates, explicit deferral, or evidenced no-change. Ask only what can change
candidate count, ownership, independence, dependency, priority, release/recovery grouping, or
partition authority. Route one coherent candidate directly to `design-change`; use partition
control for several only when useful. Detailed behavior and proof belong to `design-change`.

## Classify one change in `design-change`

`design-change` owns one candidate and classifies it from repository evidence; never ask the user to
choose a profile. State profile, kind, evidence, artifacts, gate, and escalation triggers before
creating the record. Choose the lightest evidenced profile; material uncertainty moves upward.

| Profile | Use when | Main artifact | Required gate |
| --- | --- | --- | --- |
| Fast | One local reversible result; known proof; no public contract, persistence, security, migration, architecture, external operation, or recovery requirement. | No record by default. | Concise plan, explicit approval, explicit continuation. |
| Standard | One bounded reversible delivery with no Controlled trigger, including otherwise-Fast work needing cross-context recovery. | Concise `change.md` with embedded delivery. | Approval records the contract; continuation starts work. |
| Controlled | Public API/protocol/data compatibility, security/compliance, migration/rollback, difficult reversal, cross-cutting delivery, material architecture, or at least two necessary delivery boundaries. | Full `change.md`; items only for multiple deliveries. | Independent design review and approval/continuation at each contract or map gate. |

Profile is risk, not agent count. Delivery shape is separately `single` (one Fast plan or embedded
delivery) or `multi-item` (one Controlled change with at least two necessary, independently
verifiable items). Several standalone changes remain a change set, not one umbrella delivery.

A cross-change prerequisite is valid only when the source retains independent value and supplies
one concrete completed contract. The dependent restates it with source path and contract ID;
priority, preferred order, or status alone is not dependency. Keep inseparable outcomes together.

One coordinator owns every multi-item Controlled change through integration. Execution is serial by
default; `multi-item-parallel` applies only to at least two ready, collision-free isolated items with
material benefit and never changes profile, approval, status owner, or integration path.

### Change kinds

Record one kind because it controls the proof and implementation loop:

- `behavior-change`: introduce or deliberately change observable behavior;
- `bug-fix`: restore an already evidenced expected behavior;
- `behavior-preserving-refactor`: change structure while preserving named observable invariants;
- `maintenance`: mechanical or configuration work with evidenced absence of production behavior
  change;
- `migration`: change a public, persisted, operational, or compatibility state through an explicit
  transition and recovery path; and
- `experiment`: isolated evidence gathering that cannot be shipped as production behavior.

An experiment produces evidence, not implementation authority. Its contract states a decision
question or hypothesis, method, falsification or success signal, stopping condition, and evidence
owner. Route an accepted resulting direction through a separate behavior-changing change.
Keep an experiment as one bounded delivery. If several evidence questions have independent value,
scope them as separate changes rather than creating experiment work items.

## Governing dependency direction

Use this one-way chain when the corresponding durable record exists:

```text
product intent
  → design principles
    → architecture records and ADRs
      → scope changes
        → design one change
          → optional work items
            → implementation
              → candidate-bound verification and specialist review
                → aggregate implementation review
```

Product intent, principles, architecture records, and ADRs are durable. Changes, work items,
preparation records, and review reports are temporary delivery control. A later record restates the
constraint it consumes instead of making a human reopen every upstream document.

## Terms

| Term | Contract |
| --- | --- |
| Change set | Complete partition of one request into standalone changes and explicit dispositions; never an umbrella change or cross-change item map. |
| Change design | Approved goal, behavior/invariant/experiment, scope, constraints, proof, and completion boundary—not a transcript or exhaustive task list. |
| Change prerequisite | One concrete `AC-*`, `INV-*`, `STR-*`, or `EXP-*` supplied by a standalone change on an explicit baseline—not priority, order, or status alone. |
| Embedded delivery | The sole Standard or single-delivery Controlled implementation boundary. |
| Work item | Independently verifiable delivery within one Controlled change; not research, approval, external operation, or private steps. |
| Delivery owner | User-facing implementation/integration coordinator and sole lifecycle writer; never a reviewer. |
| Proof definition/result | Definition is the expected contract-bound assertion/procedure; result is observed counts, outcome, environment, and limits on an exact candidate. |
| Proof role/purpose/shape | `Primary` directly proves one contract row; `Conditional` covers applicable extra risk. Purpose is why evidence exists; shape is how it runs. |
| Traceability | Mapping from approved contract through implementation and proof to candidate-bound result; never transient IDs/results embedded in long-lived tests. |
| Review independence | `independent`, `compact`, or `not-established`, based on fresh context, separation, read-only ownership, and exact binding—not agent count. |
| Workflow escalation trigger | New/changed behavior, invariant, scope, public/persisted contract, security, migration/recovery, real dependency, concurrency/shared boundary, difficult reversal, architecture, destructive action, or external effect—not private choices inside contract. |
| Target artifact / operational handoff | Versioned deliverable versus owned release, deployment, permission, production configuration, or stakeholder action. |

## Gates and lifecycle

`approval-source` plus lifecycle status records explicit human approval. Approval accepts the
current contract only; it does not itself start planning, implementation, review, external
operations, or closure. Each phase requires a current explicit `continue`, direct phase request, or
combined `approve and continue`. Candidate, baseline, integration, commit, or diff identities bind
technical inputs for reproducibility only; no Git SHA, blob, or digest proves human approval or
continuation.

1. `scope-changes` investigates the source request and repository evidence, asks only material
   boundary questions, and routes zero, one, or several coherent candidates. One candidate creates
   no preparation artifact by default.
2. `design-change` investigates one candidate, owns its contract clarification, classifies the
   profile and kind, and presents the proposed artifacts, proof, risks, and escalation triggers. A
   format-3 Draft declares exactly no cross-change prerequisite or complete `PRE-*` source outcomes;
   default validation proves graph structure but does not require planned sources to be complete.
3. Fast stops at a concise pre-write plan. Approval records that plan and stops unless the same
   request explicitly says to approve and continue; only then does it enter implementation without
   creating a change record.
4. Standard creates one concise `change.md` from the current truth. Approval records the described
   bounded contract; a later explicit continuation enters implementation and does not authorize
   scope expansion.
5. Controlled creates a full contract and receives independent `review-change-design` review. If
   one embedded delivery can implement it, explicit continuation after approval enters
   implementation directly. If it needs several deliveries, continuation enters `plan-work-items`,
   which creates the smallest map and stops for separate map approval and continuation.
6. Multi-change investigation or authoring under `scope-changes` uses parallel workers only when at
   least two bounded lanes are ready and coordination provides material value. Parallel work-item
   execution remains coordinated for every approved multi-item Controlled map. Parallelize a wave
   only with at least two ready, isolated tasks whose expected benefit exceeds coordination cost;
   otherwise run the wave serially under the same coordinator.
7. `implement-change` chooses private implementation and concrete proof after an explicit current
   implementation or continuation request. Its local preflight is informative; another approval is
   required only when it discloses new scope, behavior, public contract, security, migration, dependency, architecture,
   destructive action, or external side effect. Before lifecycle or target writes, it validates
   cross-change readiness against the exact implementation baseline SHA. A blocked prerequisite
   leaves the dependent change Approved.
8. `review-implementation` coordinates code-correctness, test-adequacy, and candidate-bound
   verification lanes, then issues the only aggregate conclusion for one delivery candidate or the
   integrated parent change. It uses fresh, non-writing SubAgents only when independence or context
   separation materially improves confidence. Public/persisted contracts, security, migration,
   concurrency, shared cross-item boundaries, difficult reversal, and other material Controlled
   risks require `independent`; a coordinator may perform a `compact` review for bounded low-risk
   items. Missing required independence or candidate-bound cross-change readiness is Blocking.
9. The user-facing delivery owner advances lifecycle state. A single delivery uses
   `Draft → Approved → In progress → Candidate ready → Implemented → Completed`. `Candidate ready`
   means target work and implementation-context proof are complete on an exact candidate, but the
   required candidate-bound review has not yet passed. Its `candidate-binding` marker records the
   committed SHA or frozen workspace binding needed to resume review without chat history. A multi-item map uses
   `Draft → Approved → In progress → Implemented → Verified`; only `Verified` supplies a
   prerequisite to another item.
   `Implemented` means an exact candidate has candidate-bound verification plus the required review,
   but has not yet passed authoritative integration verification. Any candidate, approved-contract,
   or relevant baseline change makes the prior conclusion stale. `Completed` and `Superseded` are
   terminal delivery states and cleanup candidates; `Superseded` never supplies a prerequisite
   unless the map names a verified replacement.
10. A change becomes `Completed` only after the applicable final review is ready, proof and required
   operational handoffs pass, durable documentation disposition is complete, and the delivery owner
    records the transition in response to an explicit continuation.

## Resume a persisted change

`continue-change` is the single user-facing router when a format-3 `change.md` is referenced or
@-mentioned. It reads the change and current map, validates their stable markers, and runs
`resolve-change-step.sh` to derive exactly one phase. It never asks the user to choose an internal
skill and never persists a duplicated `next-action` field.

`Draft` requests approval. Approved single delivery enters `implement-change`; approved multi-item
delivery enters `plan-work-items` until a map exists, then requests map approval or enters
`orchestrate-work-items`. `Candidate ready` enters `review-implementation`; `Implemented` enters
closure; `Completed` and `Superseded` enter eligibility-checked cleanup when explicitly continued.
`In progress` resumes its owning delivery path. Contradictory state fails closed rather than relying
on prior conversation.

Legacy `change-format: 2` is a deprecated read/execute-only compatibility path. It accepts only an
explicitly versioned, already-approved record whose scope, contract, proof, and embedded map remain
unchanged. Drafts, renewed approval, or material edits migrate to format 3. Validators and schedulers
must enter compatibility explicitly and emit a deprecation notice; unversioned Markdown never enters
it heuristically. Remove the path in the next declared breaking plugin release after maintained
repositories have no active format-2 changes.

An active format-3 record created before change-prerequisite markers may complete only through
`--allow-approved-prerequisite-legacy <known-approved-base-sha>`. The validator requires the same
tracked path and permits only lifecycle-status drift from that base, emits a deprecation notice, and
rejects Draft, untracked, or materially revised records. New and revised format-3 contracts use the
normal prerequisite declaration. Readiness additionally requires `--require-ready --baseline
<exact-sha>` and reads upstream contracts only from that Git tree.

A Fast plan is recoverable only in the user-facing context that presented and received approval for
its exact text. If that context or exact plan identity is unavailable, re-present the smallest plan
and obtain approval again. Use Standard instead when cross-context recovery is a known requirement.

## Route discoveries without ceremony

| Discovery | Route |
| --- | --- |
| Pure private file, symbol, algorithm, test organization, or edit-order change inside the approved boundary | Continue implementation and record the actual result. |
| Standard change needs a second independently implementable delivery | Upgrade to Controlled and invoke `plan-work-items`. |
| Public contract, persistence, security, migration, difficult reversal, or enduring decision appears | Upgrade to Controlled; use `architecture-design` when the direction needs an ADR. |
| Several approved items have useful safe concurrency | Extend Controlled with `orchestrate-work-items`. |
| A raw request has no established change boundary | Use `scope-changes`; take the no-artifact fast path for one candidate. |
| One source request exposes several independently valuable goals | Let `scope-changes` partition and coordinate them; keep each resulting change standalone. |
| No target delivery artifact must change | Record the evidence in the selected change when one exists, or close the Fast investigation without manufacturing a work item. |
| Delivery needs release, permission, deployment, or manual external configuration | Track an operational handoff with owner and closure evidence. |

Profile upgrades preserve already valid current truth and require approval only for the newly
expanded contract or risk. Do not force a downgrade mid-delivery merely because implementation
turned out easier than expected.

## Documentation lifecycle

At final review, extract enduring decisions to ADRs, current cross-cutting semantics to architecture
records, and active migration or operations procedures to their owning guide. `docs/changes/` is an
active-delivery workspace, not an archive. Absence of policy means cleanup: after a format-3 change
is terminal, its exact directory is present on the authoritative default-branch ref, durable
extraction and operational handoffs are complete, its subtree is clean, and no tracked change or
preparation record references it, delete that directory on an explicit cleanup request or explicit
continuation of the already terminal change. Completion, review, approval, or merge alone does not
authorize deletion.

Any remaining prerequisite marker that resolves to the target pins it regardless of the dependent
change's lifecycle status. Any tracked preparation containing its normalized repository-relative
path also pins it regardless of preparation status. Clean terminal referrers first. An explicit
repository retention policy may require an exception; absence of one never defaults to retention.
The cleanup caller passes that inspected policy disposition explicitly. `Completed` establishes
durable extraction through its lifecycle gate; `Superseded` requires a separate `captured` or `not
needed` extraction disposition before cleanup. Legacy records require separately inspected explicit
cleanup rather than automatic routing. Do not create a completed-change archive, tombstone, or
index: Git history supplies process recovery.
