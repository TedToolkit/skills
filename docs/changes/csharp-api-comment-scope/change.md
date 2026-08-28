# Keep C# API comments inside the requested surface

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: in-progress -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

The C# API comment Skill documents the declarations the user or repository policy actually places in
scope and adds examples only when they teach a non-obvious caller contract. Its current blanket rules
can expand a bounded request to every public, protected, and internal member and require examples for
routine calls, creating noisy changes that were never authorized.

<!-- section: scope -->
## Scope and non-goals

- In scope: scope resolution, requested-surface inventory, repository-policy precedence, proportional
  examples, and focused positive/negative eval scenarios.
- Non-goals: changing XML tag correctness, annotation package APIs, bulk-documenting a repository, or
  weakening an explicit repository-wide documentation policy.
- Preserved: evidence-based caller contracts, proposal-before-write approval, complete tags for each
  declaration that is actually in scope, and specialized annotation routing.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Comment proposal for a bounded API request | The Skill may inventory and document unrelated public, protected, and internal declarations and add routine examples by default | The proposal covers only the explicit request plus declarations required by the nearest repository policy; examples appear only when they clarify usage, lifecycle, effects, or likely misuse | Every in-scope declaration receives accurate XML structure and no undocumented fact is invented |

<!-- acceptance-case: AC-01 -->
### AC-01 — Respect an explicitly bounded request

```gherkin
Scenario: Document selected declarations in a larger file
  Given the user names one type member and no repository policy requires broader coverage
  When the Skill drafts XML documentation
  Then it documents that member and omits unrelated declarations from the proposal
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Honor an explicit broader repository policy

```gherkin
Scenario: Repository policy requires complete API documentation
  Given the nearest repository guidance requires all public API in the changed surface to be documented
  When the Skill drafts XML documentation for a change in that surface
  Then it includes the policy-required declarations and explains why they entered scope
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Add examples only when they change caller understanding

```gherkin
Scenario: Compare routine and non-obvious invocations
  Given one method is self-evident and another has lifecycle or misuse risk
  When examples are proposed
  Then the routine method has no forced example and the non-obvious method has a small usable example
```

## Constraints and risks

- Scope derives from the user's request and nearest applicable repository guidance; implementation
  visibility alone does not create authority to edit.
- Tightening the default must not remove documentation required for a changed declaration to remain
  accurate or XML-complete.
- Negative evals must include unrelated declarations in the same file so omission is observable.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: `write-csharp-api-comments` scope/example rules and its focused
  annotation-plugin eval fixture.
- Other real start conditions or resource prerequisites: none beyond the existing eval harness.
- Likely touchpoints (non-binding): the Skill's inventory, Rules, Examples, and review sections plus
  `tests/tedtoolkit-annotations/annotation-skills`.
- Private implementation choices left open: whether comment-scope scenarios remain in the shared
  annotation eval file or receive their own fixture directory.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=boundary shape=component -->
<!-- primary-proof: AC-02 purpose=acceptance shape=component -->
<!-- primary-proof: AC-03 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | The named member is documented and unrelated declarations present in the fixture are absent | `py -3.10 tests/run_evals.py --plugin tedtoolkit-annotations annotation-skills` with a bounded-surface scenario |
| AC-02 | Primary | A fixture-local policy expands the proposal only to its stated surface | Same focused command with a policy-required scenario |
| AC-03 | Primary | A routine member has no example while the non-obvious lifecycle/misuse case has a usable one | Same focused command with paired members and deterministic output assertions |

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-03 pass from the exact candidate, existing XML completeness checks remain green,
unrelated declarations stay untouched in the bounded case, policy-driven expansion remains explicit,
and independent implementation review finds no scope or approval regression.
