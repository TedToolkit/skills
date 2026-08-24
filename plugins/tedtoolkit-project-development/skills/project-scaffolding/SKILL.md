---
name: project-scaffolding
description: >-
  Scaffold or reorganize .NET repositories, solutions, projects, dependency boundaries, MSBuild
  controls, and slnx views. Use when creating a library or solution, adding or splitting a project,
  selecting folders, reviewing shared build controls, or supplying an approved location needed by
  another project-development skill.
---

# TedToolkit Project Scaffolding

Build the smallest **coherent boundary**, guided by responsibility rather than a fixed directory tree.
`src`, `tests`, `benchmarks`, `build`, `playground`, and `docs` are optional groupings; introduce each only when it
improves a real responsibility, ownership boundary, or solution view. `docs` owns durable design,
decision, architecture, and operational records; add a README entry point only when that directory
needs reader orientation, and never under `docs/changes/`.

This skill owns repository and project structure only. Invoke `write-readme` when a new location
needs reader orientation, `architecture-design` for architecture records, and `design-change` for
delivery contracts.

## Inspect before changing

1. Read the root `README.md`, applicable agent-guidance files, solution file, root MSBuild files, and
   every existing `.csproj`. Preserve the repository's declared guidance precedence. Do not impose
   this marketplace's `CLAUDE.md`/`AGENTS.md` relationship on another repository.
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
Read [testing-strategy.md](../../references/testing-strategy.md) before mapping proof purposes
and execution shapes to physical test projects.
## Approval gate

Present the proposed responsibility boundaries, paths, project and package dependencies, MSBuild
controls, solution membership, migrations or public-path moves, and verification commands. Wait for
explicit approval before creating, moving, or editing repository structure.

## Choose the smallest suitable structure

Use the scenario table in [repository-layout.md](references/repository-layout.md) before creating
folders. When a multi-project layout is appropriate, create or reorganize it in dependency order:

1. Root controls: only the controls the repository uses, such as `global.json`, `.editorconfig`,
   `Directory.Build.props`, `Directory.Build.targets`, `Directory.Packages.props`, `nuget.config`,
   README, and agent guidance.
   Keep a short, stable, repository-wide build entry point at the root when discoverability matters;
   put supporting scripts and multi-step implementation under `build/`. Add neither when the normal
   `dotnet` command already expresses the workflow.
   When the approved scope includes agent guidance, state the project's implementation language(s)
   and the human language for README and code-comment prose in its existing source of truth. In a
   repository that explicitly follows this marketplace convention, keep `AGENTS.md` as a direct
   `CLAUDE.md` reference; otherwise preserve the repository's own convention.
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
home for fast, deterministic unit tests and any automated Acceptance evidence with the same
execution profile unless the repository already uses a different convention.

Use one naming grammar:

```text
<TestProject> = <Subject>.Tests[.<Profile>]
<TestSupport> = <Subject>.TestKit
```

`<Subject>` is the production project or product boundary under test. Omit the profile for the
default project; do not append `.Unit`. Add a profile only after its
execution environment, dependencies, runtime, speed, isolation, cadence, or ownership differs
materially:

- Use `<Subject>.Tests.Integration` for real persistence, serialization, DI, filesystem, network, or
  multi-component boundary verification that needs a separate project.
- Use `<Subject>.Tests.Acceptance` for approved observable outcomes that need a distinct outer-loop
  execution profile.
- Use `<Subject>.Tests.Contract` or `<Subject>.Tests.E2E` only when the compatibility boundary or
  deployed journey itself earns a separate execution profile. Contract and End-to-end are
  execution shapes; Acceptance may be the proof purpose they serve.
- Use `<Subject>.TestKit` only after fixtures, generators, or helpers are genuinely shared by
  more than one test project.

Do not pre-create a project or directory for each proof purpose or execution shape. Project size and test count alone do
not justify a split: a small repository normally starts with one `<Subject>.Tests`, and a large
repository keeps that default until a distinct execution profile earns another project. When
approved acceptance cases exist, ensure each owned case has Acceptance evidence without requiring a
separate Acceptance project. A test project may reference its production library and test-only
support; production projects must never reference a test project.

## File responsibilities

Keep repository-wide early compiler behavior in the root `Directory.Build.props`, late build
behavior in the root `Directory.Build.targets`, and centrally managed package versions in the root
`Directory.Packages.props`. Put responsibility-specific explicit imports shared across unrelated
project groups under root `props/`; keep a group-only props file in that physical group, and keep a
one-project setting in its `.csproj`. A nested `Directory.Build.props`, `Directory.Build.targets`,
or `Directory.Packages.props` is an exception for a real inherited configuration boundary, not a
convenience, and must deliberately preserve any required parent behavior. Read
[solution-and-msbuild.md](references/solution-and-msbuild.md) before adding an explicit import,
dedicated props directory, or nested automatic control file.

Enable central package management in root `Directory.Packages.props` when the repository already
uses it or when the approved multi-project package boundary benefits from one version source. Do not
introduce it merely because a `.slnx` exists. When enabled, place
`<ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>` in a `PropertyGroup`, never
in the `.slnx` file.

Use the file-responsibility rules and common solutions in both reference files. Keep generated
output, local configuration, and tool caches out of source control unless the repository explicitly
needs them.

## Documentation boundaries

Read the **Documentation ownership and links** section of
[repository-layout.md](references/repository-layout.md) before adding or moving documentation, and
read [principles.md](references/principles.md) before creating or revising `docs/principles/`.
Read [tool-state-layout.md](../../references/tool-state-layout.md) before adding or moving
TedToolkit-owned repository state under `.tedtoolkit/`.
Create only locations whose owning record already exists or has been approved by its owning skill.
Scaffolding supplies the location; `library-product-intent`, `design-principles`,
`architecture-design`, `design-change`, `plan-work-items`, and `write-readme` supply the content.

## Verification

After structural changes, confirm every `.slnx` path resolves, project references are acyclic, and
every maintained directory-scoped MSBuild control file is listed in the matching `.slnx` folder.
The solution must restore/build with the repository's pinned SDK. Run the smallest relevant test
project, then the full build when the change affects shared props, packages, analyzers, or solution
composition.

When the repository defines durable layout rules beyond `.slnx` paths and project references, make
them executable. Put a reusable structure-checking tool under `build/`, keep its focused behavior
tests under `tests/`, and version the rules it enforces with the repository. Run the checker after
structural changes and from CI. Treat `build/` orchestration or validation projects and
developer-only `playground/` projects as visible-but-not-default-build projects in `.slnx`; do not
exclude ordinary test projects from the default build.

Complete when every created path has one responsibility, every project and MSBuild dependency is
acyclic and intentional, every solution path resolves, the pinned-SDK restore/build passes, and all
applicable focused tests and structure checks pass.
