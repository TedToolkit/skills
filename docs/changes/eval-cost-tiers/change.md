# Add explicit static, smoke, and full eval tiers

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

The eval runner offers predictable `static`, `smoke`, and `full` cost tiers without changing its
legacy default. Today callers can select names and filters, but cannot request a reviewed bounded
smoke set or all offline scenarios without manually knowing the suite layout.

<!-- section: scope -->
## Scope and non-goals

- In scope: `--tier`; explicit smoke membership; deterministic composition with plugin, positional
  name, and filter selectors; invalid/empty errors; runner self-tests and README commands.
- Non-goals: redesign assertions or fixtures, infer smoke membership from order/name/time, change
  scenario semantics/timeouts/archives, or make full confidence optional when another change
  requires it.
- Preserved: no `--tier` equals `--tier full`; current selectors and full discovery retain their
  meaning; static scenarios make no Codex call.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Eval scenario selection | No cost tier exists | `static` selects only offline scenarios, `smoke` selects static plus an explicit bounded model set, and `full` selects all otherwise-selected scenarios | Existing selector, execution, assertion, archive, timeout, and exit rules |

<!-- acceptance-case: AC-01 -->
### AC-01 — Run only offline scenarios in static tier

```gherkin
Scenario: Codex is unavailable
  Given selected eval groups contain static and model-backed scenarios
  When the runner receives --tier static
  Then it runs only static scenarios and skips Codex availability and plugin-install preflight
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Run the explicit bounded smoke set

```gherkin
Scenario: Request smoke confidence
  Given selected groups declare reviewed smoke members
  When the runner receives --tier smoke
  Then it runs all selected static scenarios plus exactly those smoke members
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Preserve full and legacy selection

```gherkin
Scenario: Compare legacy and explicit full discovery
  Given the same plugin, name, and filter selectors
  When one discovery omits --tier and the other uses --tier full
  Then both select the same complete scenario set in the same deterministic order
```

<!-- acceptance-case: AC-04 -->
### AC-04 — Compose selectors or fail without widening

```gherkin
Scenario: Tier composition is invalid or selects nothing
  Given an unknown tier or a valid tier combined with selectors that match no scenario
  When discovery runs
  Then it exits non-zero with an actionable message and never widens to another tier or selector set
```

## Constraints and risks

- Smoke membership is explicit reviewable source data; static execution never invokes Codex.
- Tier filtering occurs in a documented order and cannot turn a typo into a costly full run.
- A change's own proof contract decides whether smoke is sufficient; tier availability does not
  downgrade required full evidence.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target area: tier-aware eval discovery, explicit smoke metadata, runner self-tests,
  and `tests/README.md`.
- Other start conditions: Python 3.10 with PyYAML; Codex is not required for runner-selection tests.
- Likely touchpoints (non-binding): `tests/run_evals.py`, `tests/test_run_evals.py`, eval metadata, and
  testing documentation.
- Private choices left open: smoke-tag representation and discovery-helper decomposition.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=boundary shape=component -->
<!-- primary-proof: AC-02 purpose=acceptance shape=component -->
<!-- primary-proof: AC-03 purpose=regression shape=component -->
<!-- primary-proof: AC-04 purpose=boundary shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Static selection excludes every model scenario and never enters Codex/plugin preflight | `py -3.10 tests/test_run_evals.py` with a Codex-fail sentinel |
| AC-02 | Primary | Synthetic groups select all static plus exactly explicit smoke members | Same runner self-test suite |
| AC-03 | Primary | Default and explicit full discovery match for representative selector combinations | Same runner self-test suite plus bounded real-repository discovery comparison |
| AC-04 | Primary | Unknown and empty selections fail non-zero and never widen | Same runner self-test suite |

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-04 pass on the exact candidate; static is model-free, smoke is explicit and bounded,
legacy default equals full, selectors compose deterministically, invalid/empty selections fail
closed, and existing scenario execution/result behavior remains unchanged.
