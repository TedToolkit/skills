# Change-development workflow

This reference defines the path from one raw development request through a scoped change set and
risk-scaled delivery. It
also defines the human handoff boundary: workflow records must help a developer act without reading
the originating conversation.

Read [testing-strategy.md](testing-strategy.md) when a change defines behavior or proof.
Read [requirements-clarification.md](requirements-clarification.md) when user intent is incomplete.
Read [agent-orchestration.md](agent-orchestration.md) whenever agents are considered.

## Human-readable delivery records

`change.md` and work-item files are written for human developers. They contain the current approved
truth, not the transcript or machinery that produced it.

- Include only information that affects implementation, verification, review, release, or risk.
- Omit agent scheduling, writer leases, receipts, transaction envelopes, repeated rationale,
  superseded answers, and empty template sections from the main document.
- Keep machine-readable profile, kind, status, section, and identity markers stable even when the
  visible headings are translated. Put detailed orchestration state in a preparation or other
  separate control artifact.
- Give likely code or component touchpoints when evidence supports them and label them non-binding;
  a human should not need to rediscover the whole repository, but remains free to choose private
  files, types, algorithms, and test organization inside the approved boundary.
- Prefer the shortest record that preserves the contract. Length is a review signal, not a hard
  validator limit: a Standard change normally fits in roughly 40–100 lines and a focused work item
  in roughly 40–80 lines.

Apply the **five-minute handoff test**. A developer who has not seen the conversation must be able to
identify, without consulting agent history:

1. why the change exists and what outcome completes it;
2. current, expected, and deliberately preserved behavior;
3. scope and non-goals;
4. public contracts, governing constraints, and material risks;
5. real prerequisites and supplied inputs;
6. the primary proof and required conditional proof; and
7. which private implementation choices remain open.

If information is missing, add the smallest decision-relevant statement. If the answers are buried
in process tables, remove or relocate the process detail.

## Scope the request in `scope-changes`

`scope-changes` is the default routing owner for a new development request whose change boundaries
have not already been established. It maps every material part of the request exactly once to zero,
one, or several candidate changes, an explicit deferral, or an evidenced no-change disposition.

It asks only questions that can change candidate count, ownership, independence, dependency,
priority, release/recovery grouping, or partition authorization. One coherent candidate takes the
no-artifact fast path directly to `design-change`; several candidates use partition control only
when it adds material value. Detailed behavior and proof questions belong to `design-change`.

## Classify one change in `design-change`

`design-change` owns exactly one coherent candidate. It decides the profile and delivery shape from
repository evidence and contract clarification. Never ask the user to choose Fast, Standard, or
Controlled. Classify before creating a workflow document and state the profile, change kind,
evidence, artifacts, approval gate, and escalation triggers. Choose the lightest profile whose
conditions are evidenced; uncertainty about a material risk moves upward, never downward.

| Profile | Use when | Main artifact | Required gate |
| --- | --- | --- | --- |
| Fast | One local, reversible outcome; no public contract, persistence, security, migration, architecture, or external-operation risk; verification is known. | No `docs/changes/` record by default. | One concise pre-write plan and explicit approval. |
| Standard | One goal and one independently implementable, bounded, reversible delivery of any change kind; no Controlled trigger. | One concise `change.md` with an embedded delivery brief. | One approval authorizes that contract and its bounded implementation. |
| Controlled | Public API/protocol/data-format compatibility, security/compliance, migration/rollback, difficult reversal, cross-cutting delivery, material architecture, or two or more necessary delivery boundaries. | Full `change.md`; work items only when more than one delivery is required. | Independent design review; separate plan approval only for a multi-item map. |

Profile expresses delivery risk, not agent count. After classification, select a separate delivery
shape:

- `single`: one Fast plan or one embedded Standard/Controlled delivery;
- `multi-item`: one Controlled change with two or more necessary independently verifiable items.

Several independently valuable changes form a change set owned by `scope-changes`; they are not a
delivery shape of one change.

One delivery coordinator owns every approved multi-item Controlled change through authoritative
integration, even when only one item is ready. Execution is sequential by default.
`multi-item-parallel` is an optional wave strategy only when at least two dependency-ready,
collision-free items and isolated workers provide material benefit. It never changes the workflow
profile, approval contract, status owner, or integration path. Serialize a one-item wave, collisions,
or environments without isolation; do not route them around the coordinator.

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

| Term | Meaning | Not this |
| --- | --- | --- |
| Change set | The zero, one, or several coherent changes that exactly cover one source request and its explicit dispositions. | One umbrella change, a cross-change work-item map, or a reason to create orchestration state. |
| Change design | One approved goal, behavior, invariant, or experiment contract, scope, constraints, proof, and completion boundary. | An agent transcript, exhaustive file list, or task sequence. |
| Embedded delivery brief | The one Standard or single-delivery Controlled implementation boundary inside `change.md`. | A hidden second work item or multi-delivery map. |
| Work item | One independently verifiable delivery inside one Controlled change, with a bounded outcome, real prerequisites, constraints, primary proof, and done criteria. | Research, approval, external operation, or private implementation script. |
| Delivery owner | The user-facing implementation coordinator for one delivery, or integration coordinator for a multi-item change; the only role that updates lifecycle/status. | The review coordinator or a specialist reviewer. |
| Proof definition | The contract-bound test, command, assertion, or bounded procedure expected to demonstrate one approved behavior, invariant, experiment claim, or risk. | A claim that it already ran or passed. |
| Proof role | `Primary` directly demonstrates one approved contract row; `Conditional` addresses an additional applicable risk. | A proof purpose or execution shape. |
| Proof purpose | Acceptance, regression, boundary, structural, journey, or decision evidence: why the evidence exists. | Primary versus conditional role. |
| Execution shape | Unit, Component, Contract, Integration, End-to-end, Benchmark, or Manual: how the evidence runs. | A status hierarchy. |
| Verification result | The observed command/procedure outcome, counts, environment, and limitations bound to one exact candidate. | Test source, an unbound worker success message, or a claim that the scope was sufficient. |
| Traceability | The review mapping from approved contract through implementation and proof definition to the candidate-bound verification result. | A requirement to embed temporary change IDs or run results in long-lived test source. |
| Review independence | `independent`, `compact`, or `not-established`, based on fresh context, implementation separation, read-only ownership, and exact revision binding. | The number of agents used or a reviewer calling itself independent. |
| Workflow escalation trigger | New or changed observable behavior or invariant, scope, public or persisted contract, security, migration or recovery, real dependency, concurrency or shared boundary, difficult reversal, enduring technical direction, destructive action, or external side effect. | A private file, symbol, algorithm, test organization, collision order, or edit-sequence choice inside the approved boundary. |
| Target delivery artifact | Version-controlled code, test, configuration, build, or user/maintainer documentation changed to achieve the goal. | Change records, work-item status, approvals, or review reports. |
| Operational handoff | Release, deployment, permission, manual production configuration, or stakeholder communication tracked with an owner and closure evidence. | A development work item. |

## Gates and lifecycle

`approval-source` plus lifecycle status records explicit human authorization. Candidate, baseline,
integration, commit, or diff identities bind technical inputs for reproducibility only; no Git SHA,
blob, or digest proves that a human approved a change.

1. `scope-changes` investigates the source request and repository evidence, asks only material
   boundary questions, and routes zero, one, or several coherent candidates. One candidate creates
   no preparation artifact by default.
2. `design-change` investigates one candidate, owns its contract clarification, classifies the
   profile and kind, and presents the proposed artifacts, proof, risks, and escalation triggers.
3. Fast stops at a concise pre-write plan; after approval it hands implementation directly to the
   applicable implementation skill without creating a change record.
4. Standard creates one concise `change.md` from the current truth. Its single human approval
   authorizes the described bounded implementation; it does not authorize later scope expansion.
5. Controlled creates a full contract and receives independent `review-change-design` review. If
   one embedded delivery can implement it, approval may authorize implementation directly. If it
   needs several deliveries, `plan-work-items` creates and validates the smallest map and obtains a
   separate plan approval.
6. Multi-change investigation or authoring under `scope-changes` uses parallel workers only when at
   least two bounded lanes are ready and coordination provides material value. Parallel work-item
   execution remains coordinated for every approved multi-item Controlled map. Parallelize a wave
   only with at least two ready, isolated tasks whose expected benefit exceeds coordination cost;
   otherwise run the wave serially under the same coordinator.
7. `implement-change` chooses private implementation and concrete proof. Its local preflight is
   informative after implementation authorization; another approval is required only when it
   discloses new scope, behavior, public contract, security, migration, dependency, architecture,
   destructive action, or external side effect.
8. `review-implementation` coordinates code-correctness, test-adequacy, and candidate-bound
   verification lanes, then issues the only aggregate conclusion for one delivery candidate or the
   integrated parent change. It uses fresh, non-writing SubAgents only when independence or context
   separation materially improves confidence. Public/persisted contracts, security, migration,
   concurrency, shared cross-item boundaries, difficult reversal, and other material Controlled
   risks require `independent`; a coordinator may perform a `compact` review for bounded low-risk
   items. Missing required independence is Blocking.
9. The user-facing delivery owner advances lifecycle state. A single delivery uses
   `Draft → Approved → In progress → Implemented → Completed`. A multi-item map uses
   `Draft → Approved → In progress → Implemented → Verified`; only `Verified` supplies a
   prerequisite to another item.
   `Implemented` means an exact candidate has candidate-bound verification plus the required review,
   but has not yet passed authoritative integration verification. Any candidate, approved-contract,
   or relevant baseline change makes the prior conclusion stale. `Superseded` is terminal and never
   supplies a prerequisite unless the map names a verified replacement.
10. A change becomes `Completed` only after the applicable final review is ready, proof and required
   operational handoffs pass, durable documentation disposition is complete, and the delivery owner
    records the transition.

Legacy `change-format: 2` is a deprecated read/execute-only compatibility path. It accepts only an
explicitly versioned, already-approved record whose scope, contract, proof, and embedded map remain
unchanged. Drafts, renewed approval, or material edits migrate to format 3. Validators and schedulers
must enter compatibility explicitly and emit a deprecation notice; unversioned Markdown never enters
it heuristically. Remove the path in the next declared breaking plugin release after maintained
repositories have no active format-2 changes.

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
records, and active migration or operations procedures to their owning guide. Apply the repository's
document-retention policy to remaining temporary records. When no policy exists, retain them and
report that disposition; ask about deletion only when the user requests cleanup. Git history supplies
process recovery, so durable records and human handoffs do not retain superseded conversation history.
