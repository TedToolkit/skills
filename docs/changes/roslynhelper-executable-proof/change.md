# Verify RoslynHelper guidance through generated-code compilation

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: bug-fix -->
<!-- change-status: in-progress -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

`compose-roslyn-source` guidance and examples compile against TedToolkit.RoslynHelper `2026.7.15`
API, and its positive eval proves that emitted source also compiles. The current lexical eval can
accept invalid factory usage and its latest archived run is only 1/2 passing.

<!-- section: scope -->
## Scope and non-goals

- In scope: correct RoslynHelper `2026.7.15` examples; a buildable generator fixture; real source
  generation and consumer compilation; retained no-package negative routing; focused eval evidence.
- Non-goals: changing the RoslynHelper library, exhaustively covering Roslyn syntax, introducing the
  package when a target does not reference it, or relying on keyword presence as primary proof.
- Preserved: structural composition until one final emission, symbol-based type conversion,
  minimum use of custom syntax, repository conventions, and caller-owned formatting/verification.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Generated C# guidance and eval | Required API words can appear while example or emitted source is uncompilable | The documented composition path builds against RoslynHelper `2026.7.15` and generated source compiles without C# diagnostics | The Skill does not introduce RoslynHelper into projects that do not reference it |

<!-- acceptance-case: AC-01 -->
### AC-01 — Compile the supported composition path

```gherkin
Scenario: Compose source with RoslynHelper
  Given a generator project referencing TedToolkit.RoslynHelper 2026.7.15 and its locked Roslyn dependency
  When the Skill implements the requested generated type through the documented factories
  Then the generator builds, emits the type, and the generated source compiles with zero errors
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Preserve the no-package boundary

```gherkin
Scenario: RoslynHelper is not referenced
  Given a source-generation project without the RoslynHelper package
  When the user asks for generated C# guidance
  Then the Skill does not add or use RoslynHelper and leaves the worktree unchanged unless dependency adoption is separately authorized
```

## Constraints and risks

- The fixture must lock `TedToolkit.RoslynHelper` `2026.7.15` from package metadata commit
  `61a6947ff76dde981bd32c97cadfbafe31118292`; its declared `Microsoft.CodeAnalysis.CSharp` `5.0.0`
  dependency is authoritative. Unavailable cache or restore is reported rather than replaced by
  invented API stubs.
- Generator and consumer diagnostics are both authoritative; successful keyword assertions cannot
  overrule a failed build or generation result.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: RoslynHelper Skill/reference correctness and its eval fixture.
- Other real start conditions or resource prerequisites: RoslynHelper `2026.7.15`, its declared
  dependencies, and the repository's .NET SDK; network access only if the package is not already
  available.
- Likely touchpoints (non-binding): `compose-roslyn-source/SKILL.md`, its references, `eval.yaml`, and
  `setup_fixture.sh`.
- Private implementation choices left open: GeneratorDriver versus an equivalent compilation
  harness, exact generated sample type, and local package-feed layout.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=boundary shape=integration -->
<!-- primary-proof: AC-02 purpose=regression shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Generator Release build succeeds, generation runs, and consumer compilation reports zero errors | `py -3.10 tests/run_evals.py --plugin tedtoolkit-roslynhelper compose-roslyn-source` |
| AC-02 | Primary | The no-reference fixture contains no RoslynHelper dependency or API and remains unchanged | Same focused eval command |

<!-- section: completion-criteria -->
## Completion

AC-01 and AC-02 pass on the exact candidate, the old 1/2 failure is replaced by a current complete
result, Skill structure and links validate, package/version limitations are recorded, and the
implementation receives proportionate review.
