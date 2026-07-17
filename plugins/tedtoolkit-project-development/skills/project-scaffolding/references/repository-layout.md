# Repository layout

Choose folders by responsibility; do not require a particular tree. The following names are team
conventions, not mandatory paths.

```text
repo/
  build/                         # optional release/build orchestration and validation
    <Product>.StructureCheck/     # optional executable repository-layout validator
  src/                           # optional grouping for product code
    <Product>.Core/              # example product-library boundary
  tests/                         # optional grouping for automated tests
    <Product>.Core.Tests/        # default unit tests for <Product>.Core
    <Product>.StructureCheck.Tests/ # focused tests for the layout validator
    <Product>.IntegrationTests/  # only when real-boundary tests are needed
    <Product>.ContractTests/     # only when a public contract needs protection
    <Product>.EndToEndTests/     # only for critical deployed-system paths
  benchmarks/                    # optional repeatable performance measurements
  playground/                    # optional manual developer experiments
  assets/                        # versioned test/input assets only
  docs/                          # optional durable documentation
    changes/                     # approved change designs, when present
    adr/                         # architecture decision records, when present
  Directory.Build.props
  Directory.Packages.props
  global.json                    # optional SDK pin
  nuget.config                   # optional package-source policy
  <Product>.slnx
  README.md
  CLAUDE.md                       # source of truth; states implementation and prose languages
  AGENTS.md                       # single direct reference to CLAUDE.md
```

## Contributor guidance

Keep repository-wide contributor guidance in `CLAUDE.md`. It must explicitly name both the
implementation language(s) and the human language to use for README and code-comment prose, because
these decisions govern all documentation and comments produced in the repository. `AGENTS.md` must
be a single direct `CLAUDE.md` reference, matching this repository; it is a compatibility entry
point, not a second source of guidance.

## Folder and file responsibilities

| Item | Responsibility | Add it when | Do not add it when |
| --- | --- | --- | --- |
| Root | Solution-wide controls and contributor guidance | The file affects most projects or all contributors | It only affects one project area |
| `src/` | Groups product projects | Several product projects benefit from a common view | One small project is clearer at the root |
| `tests/` | Groups automated test projects | Tests are separate projects or need a stable solution area | Tests are intentionally colocated and the team prefers it |
| `benchmarks/` | Hosts repeatable performance measurements | Performance has a baseline, regression risk, or release decision | The need is a one-off diagnosis or ordinary correctness testing |
| `build/` | Runs release, packaging, generation, or multi-step validation | `dotnet build` alone cannot represent the workflow | A script or CI definition is sufficient |
| `playground/` | Hosts manual, disposable developer experiments | A runnable example or investigation must be kept outside product and test boundaries | The example is a documented consumer scenario, a benchmark, or an automated test |
| `assets/` | Versioned input fixtures and distributable assets | An asset is required to build, test, or publish | It is generated output, a cache, or a local download |
| `docs/` | Durable design, decision, architecture, user, or operational documentation | Records must remain discoverable after the implementing work closes | A short README or colocated project README fully serves the reader |
| `docs/changes/` | Approved change designs and their behavior/test plans | A feature, fix, refactor, migration, or other change has a design record that implementation and review must share | A transient issue comment is sufficient, or the repository uses another established location |
| `docs/adr/` | Architecture Decision Records (ADRs) | A technology, architecture, dependency, or operational decision is enduring or difficult to reverse | The choice is small, reversible, and documented adequately in the change design, issue, or pull request |
| `docs/history/` | Exceptional superseded or rejected records with continuing audit or explanatory value | A human decides Git history alone is insufficient and every retained record links to its replacement | A document is merely complete, old, or potentially useful someday |

## Test layout and naming

Mirror meaningful production-library boundaries before separating tests by level. The default test
project for `src/<Library>/` is `tests/<Library>.Tests/`; for example:

```text
src/MyProduct.Core/                 # domain behavior
tests/MyProduct.Core.Tests/          # fast deterministic tests of that behavior
```

`<Library>.Tests` is normally the unit-test home. Do not append `.Unit` unless the repository has
already established that convention; the `Tests` suffix is sufficient when the project contains only
fast, isolated tests. Add a separately named project only when it differs in more than the test
author's preference:

| Test need | Project name | Use when | Do not create it when |
| --- | --- | --- | --- |
| Focused unit behavior | `<Library>.Tests` | The library has observable deterministic behavior | The library is intentionally trivial or fully covered through a higher-level boundary |
| Real component boundary | `<Product>.IntegrationTests` | Verification needs persistence, DI, serialization, filesystem, network, or multiple real components | A unit test can prove the behavior without those dependencies |
| Public/external compatibility | `<Product>.ContractTests` | A public API, event, or external protocol has a contract worth protecting | The only consumer is internal and ordinary integration coverage is enough |
| Critical user journey | `<Product>.EndToEndTests` | The deployed-system path has failure modes lower layers cannot expose | A lower, faster test reliably proves the behavior |
| Shared test-only helpers | `<Product>.Tests.Shared` | More than one test project shares meaningful fixtures, builders, or generators | A helper is used once or duplication is still minor |

Do not create physical `Unit/`, `Integration/`, `Contract/`, or `EndToEnd/` folders merely to group
one project each. Let the project names and solution folders express the boundary; add an additional
directory only after it improves navigation for several related projects.

## Project boundaries and dependency direction

```text
Tools ──build-time──> product projects
Implementations ────> contracts / reusable code
Applications ───────> reusable code / implementations
Tests ──────────────> production projects / test support
Build ──────────────> solution projects and packaging outputs
```

Contracts and reusable projects must not reference a concrete implementation or application.
Test-support projects are test-only and must not flow into production packages. A public facade may
reference concrete implementations only when composing them is part of its explicit responsibility.

| Need | Suggested group | Naming |
| --- | --- | --- |
| Public data or contracts | product code | `<Product>.Data` or `<Product>.Contracts` |
| Consumer-facing facade | product code | `<Product>` |
| Swappable implementation | product code | `<Product>.<Implementation>` |
| Native interop source | product code | `<Product>.<Implementation>.Cpp` |
| Generator/analyzer/code fix | tooling group | `<Product>.<Purpose>` |
| Default unit tests for a library | test group | `<Library>.Tests` |
| Reusable test support | test group | `<Product>.Tests.Shared` |
| Integration, contract, or end-to-end boundary tests | test group | `<Product>.IntegrationTests`, `<Product>.ContractTests`, or `<Product>.EndToEndTests` |
| Focused regression or interop tests | test group | `<Product>.Tests.<Purpose>` when a named suite has distinct execution or ownership |
| Repository-layout validator | build group | `<Product>.StructureCheck`, with tests in `<Product>.StructureCheck.Tests` |
| Manual developer experiment | playground group | `<Product>.Playground` |

## Common choices

| Situation | Preferred solution |
| --- | --- |
| One library and one test project | Keep both at the root or use `src/` and `tests/`; choose the view the team already uses. Do not add artificial subgroups. |
| Several libraries with different consumers | Separate by package/API boundary; use project references from consumers to reusable libraries. |
| Multiple implementations of one contract | Put the contract in a reusable project and give each implementation its own project. Never reverse the dependency. |
| Shared fixtures or custom test data sources | Create a test-only shared project after duplication becomes meaningful. |
| A library needs its first behavior tests | Create `<Library>.Tests` beside its source boundary under `tests/`; begin with the behavior cases that are cheapest to prove deterministically. |
| Tests need a database, filesystem, DI container, real serialization, or multiple components | Create or extend `<Product>.IntegrationTests`; do not place slow environment-dependent tests in the default unit-test project. |
| A public API, event, or external protocol must remain compatible | Create `<Product>.ContractTests` only if ordinary integration tests do not make the contract explicit and stable enough. |
| A critical user journey crosses the deployed-system boundary | Add a small `<Product>.EndToEndTests` suite; keep its cases few and reserve it for failures lower layers cannot reveal. |
| A hot path needs repeatable measurement | Create `<Product>.Benchmarks` under `benchmarks/`, keep benchmarks separate from correctness tests, and record a stable baseline before using results as a gate. |
| A single slow run needs investigation | Profile it first; do not create a benchmark project unless the scenario is expected to recur. |
| Regression for a fixed defect | Add it to a dedicated regression suite or tag/category only when that distinction helps execution and ownership. |
| Source generator or analyzer consumed from the solution | Keep it in a tooling project and model its build dependency in `.slnx`. |
| Native runtime assets | Isolate interop/build rules in an implementation project; keep runtime packing rules project-specific. |
| A project has only one special MSBuild setting | Keep it in that `.csproj`; do not introduce a shared `.props` file. |
| Layout rules must be checked repeatedly in local development and CI | Put the validator in `build/<Product>.StructureCheck`, test it in `tests/<Product>.StructureCheck.Tests`, and version its rules with the repository. Keep the validator visible in the solution but out of the default build. |
| A manual experiment needs a project | Put it in `playground/<Product>.Playground`; it is visible for discovery but excluded from the default solution build. Promote repeatable measurements to `benchmarks/` and automated assertions to `tests/`. |
| SDK selection must be reproducible across developers and CI | Add `global.json`; otherwise omit it. |
| The repository needs custom feeds, package-source mapping, or source policy | Add `nuget.config`; otherwise omit it. |
| A change needs an approved behavior contract, API sketch, or TDD test map | Add `docs/changes/<type>-<slug>.md` using the repository's change-design convention. Link the issue or pull request; do not use the document as a changelog. |
| A change is an epic with several independent deliveries | Add `docs/changes/<epic-slug>/README.md` for the outcome, decision gates, dependency order, and status; put one implementation contract per file in `docs/changes/<epic-slug>/work-items/`. Use this only after `decompose-change-epic` establishes that the deliveries are genuinely independent. |
| A change introduces a durable technical choice | Put the change-specific behavior in `docs/changes/` and the decision rationale in `docs/adr/`. Link the two records instead of duplicating their content. |
| The team needs a stable explanation of system boundaries or cross-cutting semantics | Add a focused document directly under `docs/` or an established `docs/architecture/` subtree. Link it from affected epics and work packages; do not copy its rationale into them or create a category directory for one short note. |
| A completed design has exceptional historical value | Ask for a human decision during feature review. If retained, place it in `docs/history/`, mark it `Superseded` or `Rejected`, explain why Git history is insufficient, and link its current replacement. Do not create an archive for ordinary completed work. |
| A deployed system needs operator instructions | Add a focused runbook under `docs/` or the repository's established operations location; keep executable deployment automation in `build/` or CI, not in prose. |

Do not make a project for a namespace alone. Create one when it has an independently meaningful
dependency, package, target framework, runtime asset, build behavior, or test execution boundary.

## Documentation ownership and links

For a genuinely multi-delivery epic, the documentation layout is:

```text
docs/
  architecture/
    <topic>.md                         # enduring cross-cutting semantics
  adr/
    ADR-<number>-<slug>.md             # difficult-to-reverse decisions
  changes/
    <epic-slug>/
      README.md                         # outcome, decision gates, dependency map
      work-items/
        <ID>-<slug>.md                  # one implementation contract
```

The epic index links to architecture records and ADRs rather than repeating their rationale. Each
work item links back to its epic and prerequisites, and owns only its own acceptance criteria and
test plan. Do not use this layout for a single ordinary feature.

If `docs/history/` is justified, keep it out of normal navigation and add a short `README.md` that
states it is not a source of current implementation or review behavior. Every retained document
must have a status and a relative link to the ADR, architecture record, active migration, or other
current source that replaced it.

Use the smallest durable location that lets readers find a record from the repository root:

| Record | Owner location | Link from |
| --- | --- | --- |
| Repository purpose and first-use path | Root `README.md` | Project READMEs and relevant docs |
| Package-specific consumer contract | README beside its `.csproj` | Root README when the package is public |
| Change scope, behavior cases, acceptance criteria, and test plan | `docs/changes/<type>-<slug>.md` | Issue or pull request, and ADR when relevant |
| Epic outcome, delivery order, decision gates, and work-package status | `docs/changes/<epic-slug>/README.md` | Root README or issue; each work package |
| One epic work package's scope, acceptance criteria, and test plan | `docs/changes/<epic-slug>/work-items/<ID>-<slug>.md` | Parent epic, implementation change, and review |
| Enduring decision and trade-offs | `docs/adr/ADR-<number>-<slug>.md` | Related change design and architecture documentation |
| Architecture boundary or cross-cutting mechanism | `docs/` or `docs/architecture/` after the category earns its place | Root README, related ADR, and affected epics |
| Exceptional superseded or rejected record | `docs/history/<slug>.md` | Only its replacement record; keep out of ordinary README navigation |
| Operational procedure or migration guide | `docs/` or established operations location | Deployment/release instructions |

Do not duplicate a document merely to make each folder self-contained. Link to the source of truth:
change designs describe the behavior being delivered; ADRs explain enduring choices; README files
help a reader navigate and start.
