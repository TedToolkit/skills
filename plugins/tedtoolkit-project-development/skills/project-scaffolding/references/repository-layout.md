# Repository layout

## Contents

- [Contributor guidance](#contributor-guidance)
- [Folder and file responsibilities](#folder-and-file-responsibilities)
- [Build entry points and automation](#build-entry-points-and-automation)
- [Test layout and naming](#test-layout-and-naming)
- [Project boundaries and dependency direction](#project-boundaries-and-dependency-direction)
- [Common choices](#common-choices)
- [Documentation ownership and links](#documentation-ownership-and-links)

Choose folders by responsibility; do not require a particular tree. The following names are team
conventions, not mandatory paths. The documentation entries show the recognized categories:
`principles/` states enduring decision heuristics, `changes/` is active work, `adr/` is durable
decisions, and `architecture/` is current cross-cutting semantics. Use Git history for obsolete
document recovery.

```text
repo/
  build/                         # optional release/build orchestration and validation
    Invoke-Build.ps1             # optional multi-step implementation behind a root entry point
    <Product>.StructureCheck/     # optional executable repository-layout validator
  props/                         # optional explicit imports shared across physical project groups
    analyzers.props              # one responsibility per file
    packaging.props
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
    principles/                  # enduring decision heuristics, when repository-wide guidance exists
      README.md                  # scope, precedence, exceptions, and principle index
    changes/                     # approved change designs, when present
    adr/                         # architecture decision records, when present
    architecture/                # current cross-cutting semantics, when navigation warrants it
  Directory.Build.props
  Directory.Build.targets
  Directory.Packages.props
  global.json                    # optional SDK pin
  nuget.config                   # optional package-source policy
  build.ps1                      # optional stable Windows build entry point
  build.sh                       # optional stable Unix build entry point
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
| Root build entry point | Gives contributors and CI one discoverable, stable command | A repository-wide workflow needs more than the normal `dotnet` command | The direct `dotnet` command is already short and complete |
| `props/` | Groups responsibility-specific explicit MSBuild imports shared across unrelated physical project groups | Several groups import the same maintained build behavior | A rule is automatic repository policy, belongs to one group, or serves only one project |
| `src/` | Groups product projects | Several product projects benefit from a common view | One small project is clearer at the root |
| `tests/` | Groups automated test projects | Tests are separate projects or need a stable solution area | Tests are intentionally colocated and the team prefers it |
| `benchmarks/` | Hosts repeatable performance measurements | Performance has a baseline, regression risk, or release decision | The need is a one-off diagnosis or ordinary correctness testing |
| `build/` | Owns supporting automation for release, packaging, generation, or multi-step validation | The workflow needs multiple scripts, shared functions, build projects, or substantial implementation | A direct command or one short root script is sufficient |
| `playground/` | Hosts manual, disposable developer experiments | A runnable example or investigation must be kept outside product and test boundaries | The example is a documented consumer scenario, a benchmark, or an automated test |
| `assets/` | Versioned input fixtures and distributable assets | An asset is required to build, test, or publish | It is generated output, a cache, or a local download |
| `docs/` | Durable design, decision, architecture, user, or operational documentation | Records must remain discoverable after the implementing work closes | A short README or colocated project README fully serves the reader |
| `docs/principles/` | Enduring design heuristics that guide future trade-offs | The repository has cross-cutting defaults that cannot be fully captured by individual ADRs or code conventions | The content is only a local implementation choice, one accepted decision, or an executable code-style rule |
| `docs/changes/` | Approved change designs, delivery dispositions, and later behavior/test plans | A feature, fix, refactor, migration, or other change has a design record that implementation and review must share | A transient issue comment is sufficient, or the repository uses another established location |
| `docs/adr/` | Architecture Decision Records (ADRs) | A technology, architecture, dependency, or operational decision is enduring or difficult to reverse | The choice is small, reversible, and documented adequately in the change design, issue, or pull request |

## Build entry points and automation

Do not add a build script when `dotnet build`, `dotnet test`, or another normal tool command already
expresses the complete workflow. When a repository-wide workflow needs a short discoverable command,
keep that single entry point at the repository root, such as `build.ps1` on Windows or `build.sh` on
Unix-like systems. A short root script may contain the whole workflow.

When the workflow grows, keep the root entry point stable and move supporting scripts, shared
functions, generation logic, release orchestration, and build projects under `build/`. Treat the
root script as a thin dispatcher once `build/` owns the implementation; contributors and CI should
normally invoke the root entry point rather than depend on internal script paths.

Add only the script formats required by the repository's supported developer and CI environments.
Do not duplicate build logic across `.ps1`, `.sh`, `.bat`, `.cmd`, and CI definitions. Choose one
canonical implementation and make any additional platform files thin forwarding wrappers. Keep CI
definitions in their provider-required locations, such as `.github/workflows/`, and have them invoke
the same canonical entry point or implementation.

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
| One physical project group needs a shared explicit import | Keep one responsibility-specific `.props` file in that group; create `<group>/props/` only after several such files make the directory useful. |
| Unrelated physical project groups share explicit MSBuild behavior | Put one file per responsibility under root `props/` and import each file only from applicable projects. |
| A subtree needs automatic MSBuild or package policy that differs from the repository default | Add a nested `Directory.Build.props`, `Directory.Build.targets`, or `Directory.Packages.props` only for that real scope boundary and explicitly preserve required parent behavior. |
| A repository-wide workflow needs one short script | Put the script at the repository root and name it for the workflow, such as `build.ps1`; do not create `build/` only to contain that file. |
| Build, test, packaging, or release automation has multiple steps or shared helpers | Keep one stable root entry point and put the implementation under `build/`; make CI call the same automation. |
| More than one shell must be supported | Keep one canonical implementation and add only thin platform wrappers; do not maintain parallel copies of the build logic. |
| Layout rules must be checked repeatedly in local development and CI | Put the validator in `build/<Product>.StructureCheck`, test it in `tests/<Product>.StructureCheck.Tests`, and version its rules with the repository. Keep the validator visible in the solution but out of the default build. |
| A manual experiment needs a project | Put it in `playground/<Product>.Playground`; it is visible for discovery but excluded from the default solution build. Promote repeatable measurements to `benchmarks/` and automated assertions to `tests/`. |
| SDK selection must be reproducible across developers and CI | Add `global.json`; otherwise omit it. |
| The repository needs custom feeds, package-source mapping, or source policy | Add `nuget.config`; otherwise omit it. |
| A change needs an approved behavior contract, API sketch, or TDD test map | Add `docs/changes/<P0-P3>-<change-slug>/change.md` for the outcome, planned approach, delivery disposition, design blockers, and status; after approval, let `plan-work-items` add the dependency map and put one bounded target-delivery brief per file in `docs/changes/<P0-P3>-<change-slug>/work-items/`. A brief states the outcome, constraints, real prerequisites, and proof without prescribing private files, symbols, algorithms, or edit steps. Never add a `README.md` under `docs/changes/`; the explicitly named change record already provides the context. The change and work-item documents themselves are workflow control records, not target delivery artifacts. Do not create work items for research, review, approval, or external operations. Link the issue or pull request; do not use the document as a changelog. |
| A change introduces a durable technical choice | Put the change-specific behavior in `docs/changes/` and the decision rationale in `docs/adr/`. Link the two records instead of duplicating their content. |
| The team needs stable defaults for recurring design trade-offs | Add `docs/principles/README.md`, then split independent topics into focused files only when they improve navigation. A principle states the default, its rationale, implications, and exception route; it does not record one decision's alternatives. |
| The team needs a stable explanation of system boundaries or cross-cutting semantics | Add a focused document directly under `docs/` or an established `docs/architecture/` subtree. Link it from affected changes and work items; keep its rationale in the durable record and create a category directory only when the category earns one. |
| A completed design no longer guides implementation or review | Delete it after merge. Preserve durable decisions as ADRs, current rules as architecture records, and active operational procedures as migration guides; use Git history for everything else. |
| A deployed system needs operator instructions | Add a focused runbook under `docs/` or the repository's established operations location; keep executable deployment automation in `build/` or CI, not in prose. |

Do not make a project for a namespace alone. Create one when it has an independently meaningful
dependency, package, target framework, runtime asset, build behavior, or test execution boundary.

## Documentation ownership and links

For a change with one or more work items, the documentation layout is:

```text
docs/
  principles/
    README.md                           # scope, precedence, exception route, principle index
    <topic>.md                          # an independent enduring decision heuristic, when needed
  architecture/
    <topic>.md                         # enduring cross-cutting semantics
  adr/
    Benchmark.slnx                    # ADR-benchmark navigation catalog; never main CI/build input
    ADR-<number>-<slug>.md             # ordinary difficult-to-reverse decision
    ADR-<number>-<slug>/                # only when durable evidence needs a home
      README.md                         # ADR
      benchmark/                        # ADR-specific benchmark source; cataloged by Benchmark.slnx
      evidence/
        README.md                       # evidence inventory and provenance
        benchmark/                      # BenchmarkDotNet manifest and reports, when applicable
        api-analysis.md                 # API/TFM compatibility evidence, when applicable
        ecosystem-analysis.md           # ecosystem evidence, when applicable
        poc/                            # PoC manifest and durable output, when applicable
  changes/
    <P0-P3>-<change-slug>/
      change.md                         # outcome, planned approach, blockers, delivery map
      work-items/
        <ID>-<slug>.md                  # one bounded repository-change contract
```

The change record links to applicable principles, architecture records, and ADRs rather than repeating
their rationale. Each work item links back to its change and prerequisites, and owns only its own
outcome, delivery constraints, and verification standard. It does not predesign private code. A work
item exists only for a bounded modification to version-controlled delivery artifacts; research,
reviews, approvals, and external operations belong to change design or an operational handoff. Use
this layout whenever a change needs an approved behavioral contract and delivery plan, including a
small change with one work item.

Use the smallest durable location that lets readers find a record from the repository root:

| Record | Owner location | Link from |
| --- | --- | --- |
| Repository purpose and first-use path | Root `README.md` | Project READMEs and relevant docs |
| Package-specific consumer contract | README beside its `.csproj` | Root README when the package is public |
| Repository-wide decision defaults and their rationale | `docs/principles/README.md` and focused topic files when navigation needs them | Root README, related ADRs, architecture records, and change designs |
| Change outcome, planned approach, and status; later delivery order | `docs/changes/<P0-P3>-<change-slug>/change.md` | Root README or issue; each work item |
| One bounded repository modification's outcome, scope, delivery constraints, and verification standard | `docs/changes/<P0-P3>-<change-slug>/work-items/<ID>-<slug>.md` | Parent change, implementation choices, and review |
| Enduring decision and trade-offs | `docs/adr/ADR-<number>-<slug>.md`, or `docs/adr/ADR-<number>-<slug>/README.md` when it owns durable evidence | Related change design and architecture documentation |
| ADR-specific benchmark source | `docs/adr/ADR-<number>-<slug>/benchmark/`, listed by `docs/adr/Benchmark.slnx` | Its ADR and evidence index; never the main solution or default CI |
| Architecture boundary or cross-cutting mechanism | `docs/` or `docs/architecture/` after the category earns its place | Root README, related ADR, and affected changes |
| Operational procedure or migration guide | `docs/` or established operations location | Deployment/release instructions |

Do not duplicate a document merely to make each folder self-contained. Link to the source of truth:
principles set default trade-offs; change designs describe the behavior being delivered; ADRs explain
enduring choices; architecture records explain current semantics; README files help a reader navigate
and start.
