---
name: project-scaffolding
description: >-
  Create or reorganize team .NET repositories, solutions, and project files using conventions for
  file responsibilities, dependencies, MSBuild, and .slnx layout. Use when creating a .NET library
  or solution, adding a project, selecting repository folders, or reviewing Directory.Build.props,
  Directory.Packages.props, and .slnx files.
---

# TedToolkit Project Scaffolding

Use this skill to establish a coherent .NET repository, not to impose a fixed directory tree.
`src`, `tests`, `benchmarks`, `build`, `playground`, and `docs` are optional groupings; introduce each only when it
improves a real responsibility, ownership boundary, or solution view. `docs` owns durable design,
decision, architecture, and operational records; a README remains the short entry point for its
directory.

## Inspect before changing

1. Read the root `README.md`, `CLAUDE.md`, and `AGENTS.md`, solution file, root MSBuild files, and
   every existing `.csproj`. Treat `CLAUDE.md` as the source of truth for contributor guidance;
   `AGENTS.md` must contain only a direct `CLAUDE.md` reference, as in this repository.
2. Identify the public package boundary, dependency direction, tooling, test categories, and
   build/release requirements. Also identify the project's implementation language(s) and the
   human language required for README and code-comment prose.
3. Preserve an established layout unless it prevents a clear dependency direction. Explain a proposed
   move before changing public project paths or solution organization.

Read [repository-layout.md](references/repository-layout.md) to choose folders and project
boundaries. Read [solution-and-msbuild.md](references/solution-and-msbuild.md) before creating or
editing `.slnx`, `Directory.Build.props`, `Directory.Packages.props`, or shared `.props` files. Read
[project-files-and-boundaries.md](references/project-files-and-boundaries.md) before naming or
splitting a `.csproj`, adding project-root files, or changing project dependencies.

## Choose the smallest suitable structure

Use the scenario table in [repository-layout.md](references/repository-layout.md) before creating
folders. When a multi-project layout is appropriate, create or reorganize it in dependency order:

1. Root controls: only the controls the repository uses, such as `global.json`, `.editorconfig`,
   `Directory.Build.props`, `Directory.Packages.props`, `nuget.config`, README, and agent guidance.
   When adding or normalizing agent guidance, `CLAUDE.md` must explicitly state the project's
   implementation language(s) and the human language for README and code-comment prose. Create
   `AGENTS.md` as a single direct `CLAUDE.md` reference; do not duplicate the guidance in both files.
   Add `docs/` when durable records need a discoverable home; do not create an empty documentation
   tree merely because a layout diagram includes one.
2. Contracts and reusable code before their consumers.
3. Optional implementations, integrations, or applications after their contracts.
4. Build-time tools before projects that load their compiled outputs.
5. Shared test support before focused test suites and benchmark projects.
6. Build orchestration only when a normal solution build cannot express the release pipeline.

Keep project references explicit and acyclic. Do not add a project to the solution merely because a
file is nearby; give it a build, package, runtime, or test purpose.

## Test project boundaries and names

Place test projects under `tests/` when the repository uses that grouping. For a production library
`src/<Library>/`, the default focused test project is `tests/<Library>.Tests/`: for example,
`src/MyProduct.Core/` is covered first by `tests/MyProduct.Core.Tests/`. Treat that project as the
home for fast, deterministic unit tests unless the repository already uses a different convention.

Do not pre-create `Unit`, `Integration`, `Contract`, and `EndToEnd` directories or projects. Split a
test project only when its execution environment, dependencies, runtime, speed, isolation, or
ownership differs materially:

- Use `<Product>.IntegrationTests` for real persistence, serialization, DI, filesystem, network, or
  multi-component boundary verification.
- Use `<Product>.ContractTests` for public APIs, events, or external protocols that need a stable
  compatibility contract.
- Use `<Product>.EndToEndTests` for a small number of critical user journeys that require the
  deployed-system path.
- Use `<Product>.Tests.Shared` only after fixtures, generators, or helpers are genuinely shared by
  more than one test project.

Choose the lowest reliable test level for each behavior case. A test project may reference its
production library and test-only support; production projects must never reference a test project.

## File responsibilities

Keep repository-wide compiler behavior in `Directory.Build.props`; keep centrally managed package
versions in `Directory.Packages.props`. Read [solution-and-msbuild.md](references/solution-and-msbuild.md)
before adding an explicit `.props` import or a nested `Directory.Build.props`. Keep project files
focused on identity, target frameworks, project-specific dependencies, and project-specific assets
or packing rules.

For every repository with a `.slnx` solution, the root `Directory.Packages.props` must enable
central package management; it must contain
`<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>` in a `PropertyGroup`.
This is an MSBuild property, so do not put it in the `.slnx` file itself.

Use the file-responsibility rules and common solutions in both reference files. Keep generated
output, local configuration, and tool caches out of source control unless the repository explicitly
needs them.

## Documentation boundaries

Use `README.md` for orientation and first-use instructions. Use `docs/` for records that remain
useful after the implementing pull request closes: feature designs, ADRs, architecture explanations,
runbooks, and migration or rollout plans. Read [repository-layout.md](references/repository-layout.md)
before adding a documentation subtree so the document has a clear owner and stable location.

For the feature-development workflow, use `docs/features/` for approved feature designs and
`docs/adr/` for durable technical decisions. Link a feature design to any related ADR; do not copy
the decision rationale into both files. Keep the tree shallow until the repository has a real
navigational need for another category.

When a feature is an epic with multiple independently implementable deliveries, use
`docs/features/<epic-slug>/README.md` as its index and put its work-package contracts in
`docs/features/<epic-slug>/work-items/`. Use `decompose-feature-epic` to establish those boundaries
before creating the tree. Keep cross-cutting, long-lived semantics in a focused architecture record
such as `docs/architecture/<topic>.md`; put difficult-to-reverse choices in `docs/adr/`. The epic
index links to those records and tracks dependencies, while each work package owns its acceptance
criteria and test plan. Do not create this hierarchy for one ordinary feature.

`docs/features/` is for active work. At completion, a human review decides whether to retain a short
epic index, extract current rules to `docs/architecture/`, retain a decision in `docs/adr/`, keep an
active migration guide, or delete a process-only design. Create `docs/history/` only when a
superseded document has concrete audit, legal, or explanatory value that Git history cannot serve.
Its README must say that it is not a current implementation or review source, and each historical
record must be marked `Superseded` or `Rejected` and link to its current replacement. Do not move or
delete documents automatically during scaffolding.

## Verification

After structural changes, confirm every `.slnx` path resolves, project references are acyclic, and
the solution restores/builds with the repository's pinned SDK. Run the smallest relevant test
project, then the full build when the change affects shared props, packages, analyzers, or solution
composition.

When the repository defines durable layout rules beyond `.slnx` paths and project references, make
them executable. Put a reusable structure-checking tool under `build/`, keep its focused behavior
tests under `tests/`, and version the rules it enforces with the repository. Run the checker after
structural changes and from CI. Treat `build/` orchestration or validation projects and
developer-only `playground/` projects as visible-but-not-default-build projects in `.slnx`; do not
exclude ordinary test projects from the default build.
