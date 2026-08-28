# Repair the project-development release and invocation contract

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: completed -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: workspace:d3ddb70db54ba3d78a848e995b940f944a6cc7d6:sha256:ce77fc287164deb74e752cdb2cc282f2ac73d801da5b33233c70d3709628b30f -->

<!-- section: goal-rationale -->
## Goal and rationale

Release one uniquely versioned `tedtoolkit-project-development` plugin whose canonical workflow
entries, deprecated explicit aliases, continuation entry point, and specialist review lanes expose
one consistent invocation contract. The repository has materially changed since the published
`0.3.0` package while both manifests still identify the current content as `0.3.0`; two historical
skill names are absent, `continue-change` has no Codex interface metadata, and current UI prompts or
implicit-selection policy can bypass the intended coordinator ownership.

<!-- section: scope -->
## Scope and non-goals

- In scope: check the authoritative release channels and synchronize both project-development
  plugin manifests on the next unoccupied version; add explicit-only compatibility aliases
  `prepare-change` → `scope-changes` and
  `implement-change-work-items` → `orchestrate-work-items`; add the missing
  `continue-change/agents/openai.yaml`; correct orchestration and aggregate-review UI prompts; make
  `review-code`, `review-tests`, and `verify-implementation` explicit-only; add deterministic
  static contract checks and focused trigger/near-miss evals.
- Non-goals: change canonical workflow semantics, lifecycle rules, approval gates, delivery or
  review ownership, plugin-cache contents, marketplace membership, or any production project;
  edit `implement-change/SKILL.md` or `tests/tedtoolkit-project-development/implement-change/**`;
  remove existing compatibility aliases; or publish/install the plugin.
- Preserved: `scope-changes`, `design-change`, `implement-change`, `continue-change`,
  `orchestrate-work-items`, and `review-implementation` remain the canonical workflow owners;
  explicit specialist requests and coordinator dispatch can still invoke all three review lanes;
  aliases contain no duplicated canonical rules.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Published plugin identity and Skill invocation | Materially different content reuses `0.3.0`; two old explicit names disappear; metadata can route ordinary work around canonical coordinators | The release uses an authority-checked unoccupied version, old explicit names complete through canonical replacements, and ordinary requests select canonical owners | Canonical workflow semantics, explicit specialist access, approval gates, and installed caches remain unchanged |

<!-- acceptance-case: AC-01 -->
### AC-01 — Publish under an unoccupied identity

```gherkin
Scenario: Select the project-development release version
  Given the authoritative release channels and repository manifests have been inspected
  When the changed plugin is prepared for release
  Then both manifests use the same next unoccupied version and the supporting source and check time are recorded
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Preserve legacy explicit invocations

```gherkin
Scenario: Invoke a renamed workflow by its published old name
  Given the user explicitly invokes prepare-change or implement-change-work-items
  When the compatibility Skill runs
  Then it announces the canonical replacement, completes the original request through that replacement, and ordinary unprefixed prompts never select the alias
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Expose the persisted-change router

```gherkin
Scenario: Continue an explicitly identified format-3 change
  Given the user references its change.md and asks to continue
  When Skill selection occurs
  Then continue-change is presented and derives one phase from repository state without asking the user to choose an internal Skill
```

<!-- acceptance-case: AC-04 -->
### AC-04 — Keep orchestration and review ownership coherent

```gherkin
Scenario: Route multi-item execution and implementation review
  Given either a Controlled change with at least two approved items or a general implementation-review request
  When Skill selection and coordination occur
  Then orchestrate-work-items retains ownership even for a one-ready-item serial wave, review-implementation owns aggregate review, and specialist lanes run only through explicit calls or coordinator dispatch
```

## Constraints and risks

- The release version is a public package identity: both manifests must change atomically and
  remain equal. Select it only after checking the authoritative release channels; do not rewrite or
  delete any installed cache to hide the `0.3.0` collision.
- Compatibility aliases are explicit invocation shims only. Each names one replacement, links to
  and follows its canonical `SKILL.md`, performs the original request, and owns no copied workflow
  policy. Existing `change-design` and `implement-change-tdd` aliases remain unchanged.
- `allow_implicit_invocation: false` is limited to deprecated aliases and the three specialist
  lanes. Canonical intake, continuation, orchestration, and aggregate review remain autonomously
  discoverable according to their descriptions.
- Static checks must parse manifests and YAML, validate directory/frontmatter/link integrity,
  assert alias and specialist policies, and fail on version or UI-contract drift. Trigger evals
  must include both explicit calls and unprefixed near-miss prompts so a passing alias test cannot
  mask incorrect autonomous routing.
- The delivery is designed against Git baseline
  `d3ddb70db54ba3d78a848e995b940f944a6cc7d6`. Escalate before changing another plugin, canonical
  workflow semantics, marketplace membership, cache state, or the excluded implementation skill
  and eval.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. The single delivery starts after this contract receives independent design review, explicit
approval, and continuation on the stated baseline with unrelated worktree changes preserved.

Release-channel evidence for AC-01: fetched `https://github.com/TedToolkit/skills.git` on
`2026-08-26T06:26:26Z`; `origin/main` resolved to
`8fbad2edc0e2c254764187beb9fcb6f4883b61c5`, no release tags existed, and reachable manifest
history contained `0.1.2`, `0.2.0`, `0.2.1`, and `0.3.0`. The selected next unoccupied version is
`0.4.0`.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: one project-development packaging and invocation-contract
  behavior-change delivery covering manifests, compatibility shims, Codex interface metadata, and
  regression proof.
- Other real start conditions or resource prerequisites: Python 3.10 with PyYAML, the repository
  eval runner, and Codex CLI only for the focused trigger scenarios.
- Likely touchpoints (non-binding): project-development manifests; the two alias skill directories;
  `continue-change`, `orchestrate-work-items`, `review-implementation`, `review-code`,
  `review-tests`, and `verify-implementation` interface metadata; project-development eval fixtures.
- Private implementation choices left open: static-check script location, fixture decomposition,
  exact UI wording, and whether focused scenarios extend existing eval files or use dedicated
  contract suites.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=boundary shape=component -->
<!-- primary-proof: AC-02 purpose=regression shape=component -->
<!-- primary-proof: AC-03 purpose=acceptance shape=component -->
<!-- primary-proof: AC-04 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | An authority record identifies the checked channels and time, and both parsed manifests expose the same selected unoccupied version | Bounded release-channel inspection plus project-development static contract eval through `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development plugin-contract` |
| AC-02 | Primary | Static policy checks pass, explicit legacy prompts route through the replacements, and unprefixed prompts select only canonical skills | Static contract eval plus focused `prepare-change` and `implement-change-work-items` trigger evals |
| AC-03 | Primary | Parsed `continue-change` UI metadata exists and its focused persisted-change routing scenarios remain green | Static contract eval plus `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development continue-change` |
| AC-04 | Primary | Prompts encode serial coordinator and aggregate-review ownership; explicit specialist calls work while general prompts use canonical owners | Static contract eval plus focused orchestration and review trigger evals |

Conditional proof: `py -3.10 tests/test_run_evals.py`, JSON/YAML parsing, local Markdown-link
validation, and complete candidate diff inspection. Missing credentials may be reported as a
limitation, but cannot replace the model-backed primary results or allow candidate-ready/completion.

Implementation evidence on 2026-08-26:

- AC-01: the offline plugin-contract eval passed 1/1 at
  `tests/.results/20260826-181759-507530-cabc4513`. Its seven unit cases parse alias frontmatter,
  resolve canonical Markdown-link targets, and include negative version, alias-policy,
  missing-target, orchestration-owner, and specialist-policy mutations.
- AC-02: the isolated explicit alias batch passed 2/2 at
  `tests/.results/20260826-182525-629575-17af989e`; the isolated ordinary canonical-routing batch
  passed 3/3 at `tests/.results/20260826-180138-803346-9c38f9ed`, including the `scope-changes`
  and `orchestrate-work-items` near misses. Explicit headless scenarios copied the exact isolated
  plugin and read the already-selected alias Skill; ordinary scenarios received no Skill-file
  injection and exercised autonomous routing.
- AC-03: the isolated Draft continuation passed 1/1 at
  `tests/.results/20260826-183844-634736-eada06bc`; isolated approved cross-conversation
  implementation, proof, candidate binding, and review stop passed 1/1 at
  `tests/.results/20260826-185223-568079-8c7f3bfe`. The fixture uses a quoted heredoc so its
  Markdown contract is preserved literally, and the review-stop oracle accepts equivalent English
  or Chinese wording.
- AC-04: the ordinary batch above selected `orchestrate-work-items` and
  `review-implementation`; the isolated explicit specialist batch passed 3/3 at
  `tests/.results/20260826-175206-390283-cf219750`, covering code correctness, test adequacy, and
  candidate-bound verification while excluding aggregate ownership, test execution, and fixes.
- Isolation: a clean clone of baseline `d3ddb70db54ba3d78a848e995b940f944a6cc7d6` received only
  the 21 candidate files. Those files matched the main workspace byte-for-byte before this
  evidence-only record update, both copies produced normalized bundle digest
  `8feefaefcd2292f70fe30f8a0b72f2f8b2ff3bdae351c6e86160702a83717d7b`, and the excluded
  `implement-change/SKILL.md` and `implement-change/eval.yaml` remained clean against the baseline.
- Conditional gates: the eval harness passed 6/6; the format-3 validator reported the handoff
  structurally complete; and `git diff --check` reported no errors. No plugin cache, marketplace
  entry, production project, migration, publication target, or temporary/debug artifact is part of
  the candidate.

For workspace review, the bundle digest covers exactly 21 files: this `change.md`; both plugin
manifests; both files in each new alias directory; the new `continue-change` agent metadata; the
five edited orchestration/review agent metadata files; the continuation eval and setup fixture; both new
alias eval files; all three files in the new plugin-contract eval directory; and the review-routing
eval file. Sort their
repository-relative UTF-8 paths ordinally, then hash each path, a NUL byte, the eight-byte
big-endian content length, and the raw content bytes with SHA-256. Normalize only this change's
`candidate-binding` marker to `none` before hashing so the binding is non-recursive.

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-04 pass their primary proof, existing canonical and compatibility scenarios show
no routing regression or deprecation noise, both plugin manifests remain synchronized, the complete
candidate receives the Controlled independent implementation review, and no cache, excluded
implementation file/eval, unrelated worktree content, or canonical workflow rule is changed.
