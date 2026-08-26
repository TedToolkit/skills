# Agent orchestration and context control

This reference is the shared policy for every project-development skill that coordinates agents.
Domain protocols may add delivery-specific rules, but must not redefine scheduling, context packets,
or handoff semantics.

Read [tool-state-layout.md](tool-state-layout.md) before materializing coordinator state, candidate
bundles, verification/review reports, or worktrees in the repository.

## Use agents only when they buy something

Keep one coordinator in the user-facing context. Add agents when at least two bounded tasks can
proceed independently, or when one bounded task requires a fresh context for role separation,
independent review, adjudication, or isolated implementation. Useful reasons include different
evidence areas, an independent review perspective, or collision-free work in separate Git worktrees.

Do not fan out when one short task owns the answer, the next step depends on a user decision, workers
would write the same artifact, isolation is unavailable, or startup and integration cost is likely to
exceed the saved time. Agent availability is capacity, not justification.

Use flat scheduling:

- reserve one slot for the coordinator;
- allocate remaining slots breadth-first across distinct ready tasks;
- do not let workers create their own scheduling trees;
- end a worker after its bounded handoff; use a fresh context for a different role or unrelated task;
- stop adding perspectives when existing evidence answers the decision or only user authority can
  resolve the remaining gap.

## Keep one authority per concern

The delivery owner owns user dialogue, approval interpretation, and lifecycle/status updates. For a
single delivery it is the user-facing implementation coordinator; for a multi-item change it is the
integration coordinator. A review coordinator owns only review routing, evidence synthesis, and the
merge-readiness conclusion. In compact mode both roles may share one user-facing context, but the
review phase remains read-only. In independent mode a fresh review context owns the judgments and
returns its conclusion to the delivery owner. A worker owns only its dispatched read or isolated
write boundary. `review-code` owns implementation-correctness findings; `review-tests` owns
test-adequacy findings; `verify-implementation` owns observed execution results; none of them
implements, fixes, approves, or updates lifecycle state.

For shared-workspace writes, assign disjoint explicit write sets and one writer per path. For code or
other overlapping delivery artifacts, use one branch and worktree per worker; otherwise serialize the
work. Do not add writer leases, receipts, or transaction state when an owner, write set, and baseline
identify the same boundary more directly.

Use one source of truth for mutable status. Human contract documents hold approved current truth;
orchestration state belongs in one coordinator-owned control artifact. Agent messages are evidence or
proposals, not durable authority. Keep that state in the user-facing context by default. When the
user requested persistent orchestration or approved local state, the delivery owner provisions
`.tedtoolkit/runs/<workflow-id>/` and persists only the minimum recovery material defined by the tool
state layout; specialist review and verification lanes remain read-only.

## Send minimum-sufficient context

Every dispatch contains:

```text
Objective and why this task exists
Role and one bounded question or delivery
Repository baseline or reviewed diff range
Exact artifact paths and governing decision IDs
Allowed initial read scope
Read-only, or explicit write set plus branch/worktree
Required evidence and handoff shape
Stop conditions and prohibited scope
```

Prefer paths and stable decision IDs over copied prose. Do not attach the full conversation, sibling
work, broad repository summaries, long source excerpts, or another worker's transcript by default.
When the packet is insufficient, the worker returns the missing path or decision and its impact; the
coordinator supplies only that addition.

Scale candidate binding to how the result will travel. Independent, cross-context, asynchronous, CI,
or integrated review needs one immutable identity: prefer a full Git commit SHA; when a candidate
commit was not authorized, freeze `HEAD` plus a cryptographic digest of the complete tracked diff and
every in-scope untracked blob. Give every participating context that exact bundle and stop stale if a
candidate input changes. Declare ordinary build/test output paths separately and exclude them from
the manifest. A path list or bare diff summary is not sufficient for a reusable cross-context result.

A synchronous compact review in the same workspace needs no commit or digest. Capture the baseline,
complete raw diff, and in-scope untracked contents before its serial code/test/execution checks;
compare that raw snapshot again before synthesis. The conclusion is immediate and non-reusable
outside that context. One binding is enough in either mode; do not add a local revision counter.

When independent concerns are split across contexts, give each fresh lane the same approved contract
and exact raw candidate, but not implementer narration, sibling findings, suspected defects, proposed
fixes, or a desired conclusion. This prevents contextual anchoring. One fresh reviewer covering
several concerns serially may retain its own evidence and judgments; it must still keep the
professional conclusions distinct. A verifier receives authoritative commands and expected
contract/risk purposes, not a claim that the candidate is already correct.

## Require compact, evidence-first handoffs

A read-only handoff contains:

```text
Task and baseline
Conclusion: complete | blocked | stale
Material findings with source paths and locations
Contradiction or decision needed, or None
Recommended next route
```

A writer handoff adds the branch/worktree, candidate SHA, actual changed artifacts, exact verification
commands and results, deviations or None, and remaining risks. The coordinator verifies the claimed
artifact or revision before using it. Do not forward one worker's prose as another worker's context
when the repository artifact or cited source is available.

## Scale independent review by risk

Use one of three explicit levels:

- `independent`: at least one fresh non-writing review context that did not implement the exact
  candidate owns all required judgments and the synthesis;
- `compact`: the coordinator performs the risk-relevant checks for bounded low-risk work and does
  not claim independence; or
- `not-established`: separation, candidate binding, or read-only ownership is insufficient.

Use a fresh independent review context for implementation that changes public or persisted
contracts, security, migrations, concurrency, shared cross-item boundaries, or other
difficult-to-reverse behavior. That reviewer may perform code and test judgments serially while
keeping their conclusions distinct, and may execute verification or reuse exact-revision CI.
Split lanes across additional contexts only for specialist expertise, excessive context size,
security/permission separation, contested findings, or materially different execution environments.
A delivery owner may perform compact checks for bounded low-risk items whose proof is direct and
whose diff does not cross a shared boundary.

Review the applicable bound input: immutable range/bundle for independent or reusable results, or
the before/after raw workspace snapshot for synchronous compact review. A worker's success message is
not review evidence, and a reviewer never grants human approval. If required independence cannot be
established, the aggregate review is Not ready.

Resolve lane disagreement from primary artifacts, never votes. Command failure is an observed fact;
command success cannot overrule weak test coverage. If the coordinator implemented the candidate or
cannot resolve a material specialist conflict, dispatch one fresh narrow adjudication context with
the disputed claim and raw artifacts, not sibling conclusions. Contract ambiguity returns to the
contract owner.

## Recover from repository evidence

Resume from Git status, applicable candidate binding, the authoritative control artifact, approved
contracts, and recorded verification. Candidate, baseline, or approved-contract changes make the
aggregate conclusion stale; code, test, configuration, or result changes invalidate their affected
lanes. Re-dispatch only the affected bounded task. If an agent result targets an obsolete baseline,
replay or re-review it; do not reconstruct hidden conversations or invent approval.
