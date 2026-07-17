# Solution and MSBuild conventions

## Root controls

Keep root policy central only when it truly applies across projects. All of these files are optional:

- `global.json`: add it only to pin SDK selection across local development and CI.
- `Directory.Build.props`: shared language/compiler defaults and repository-wide analyzers.
- `Directory.Packages.props`: central package management and shared package versions.
- `nuget.config`: repository-specific package sources, package-source mapping, or source policy.
- `.editorconfig`: formatting and analyzer behavior.

Use a nearby `.props` file only for a coherent project group. Do not duplicate settings across child
projects, but do not create a props file for a single setting used once.

Every repository with a `.slnx` solution must use central package management. Add the following to
the root `Directory.Packages.props` (not to the `.slnx` file, which is not an MSBuild project file):

```xml
<PropertyGroup>
  <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
</PropertyGroup>
```

## Props organization

Use three scopes and name every explicit props file after its single responsibility:

```text
repo/
  Directory.Build.props          # automatic, whole-repository rules
  Directory.Build.targets        # automatic, whole-repository targets/items
  Directory.Packages.props       # automatic, central package versions
  props/                         # explicit imports shared across directories
    packaging.props
    analyzers.props
    native-assets.props
  tests/
    tests.props                  # explicit import for this physical group only
```

| Scope | Location | Import rule |
| --- | --- | --- |
| All projects | Root `Directory.Build.props` | MSBuild discovers it automatically. |
| Multiple unrelated physical groups | Root `props/<responsibility>.props` | Each applicable project imports it explicitly. |
| One physical project group | That group's `<group>.props` | Only projects in that group import it explicitly. |
| One project | Its `.csproj` | Keep the setting in the project; do not extract a props file. |

Never create `Common.props`, `Shared.props`, or a catch-all props file. A file such as
`packaging.props` contains only package metadata and packing behavior; `analyzers.props` contains
only analyzer wiring. Use `.targets`, not `.props`, for build targets, after-build actions, or item
changes that must occur after project evaluation.

Set a stable root path once in the root `Directory.Build.props`:

```xml
<PropertyGroup>
  <RepositoryRoot Condition="'$(RepositoryRoot)' == ''">$(MSBuildThisFileDirectory)</RepositoryRoot>
</PropertyGroup>
```

Then use it for explicit imports instead of fragile relative paths:

```xml
<Import Project="$(RepositoryRoot)props/packaging.props" />
<Import Project="$(RepositoryRoot)tests/tests.props" />
```

### Nested Directory.Build.props

MSBuild discovers only the nearest `Directory.Build.props`; it does not automatically merge parent
files. Prefer the root file plus explicit imports. When a directory-level automatic rule is genuinely
needed, its `Directory.Build.props` must import the parent before declaring local settings:

```xml
<Project>
  <Import Project="$([MSBuild]::GetPathOfFileAbove('Directory.Build.props', '$(MSBuildThisFileDirectory)..'))" />

  <PropertyGroup>
    <!-- Rules for this directory and its descendants only. -->
  </PropertyGroup>
</Project>
```

Do not add a nested `Directory.Build.props` merely to avoid two explicit imports. Verify that the
parent import resolves and that the nested rules do not unintentionally apply to unrelated child
projects.

## Project-file boundary

A normal project file should contain only:

1. its SDK/imports;
2. its target framework(s), output type, and project-specific description;
3. project-specific package/project references;
4. project-specific assets, analyzers, or packing rules.

Use `ProjectReference` for source dependencies. If a project consumes an analyzer built in the same
solution through `Analyzer Include=...bin...`, add a `.slnx` `BuildDependency` so a clean solution
build produces that DLL first.

## .slnx follows the filesystem

Treat the repository directories as the primary solution structure. A `.slnx` logical folder must
normally mirror an actual directory containing the listed projects or files. Do not create abstract
folders such as `/libraries/`, `/platform/`, or `/integrations/` when no matching directory exists.

The only standard virtual folder is `/SolutionItems/`, which contains root-level contributor and
solution controls. A project stored at the repository root stays at the solution root. Omit a
directory that contains no solution-relevant project or file.

```xml
<Solution>
  <Folder Name="/SolutionItems/">
    <File Path=".editorconfig" />
    <File Path="Directory.Build.props" />
    <File Path="Directory.Packages.props" />
    <File Path="README.md" />
  </Folder>
  <Folder Name="/src/">
    <Project Path="src/Example/Example.csproj" />
    <Project Path="src/Example.Analyzer/Example.Analyzer.csproj" />
  </Folder>
  <Folder Name="/tests/">
    <Project Path="tests/Example.Tests/Example.Tests.csproj" />
  </Folder>
  <Folder Name="/benchmarks/">
    <Project Path="benchmarks/Example.Benchmarks/Example.Benchmarks.csproj" />
  </Folder>
  <Folder Name="/build/">
    <Project Path="build/Example.Build.csproj">
      <Build Project="false" />
    </Project>
    <Project Path="build/Example.StructureCheck/Example.StructureCheck.csproj">
      <Build Project="false" />
    </Project>
  </Folder>
  <Folder Name="/playground/">
    <Project Path="playground/Example.Playground/Example.Playground.csproj">
      <Build Project="false" />
    </Project>
  </Folder>
</Solution>
```

Nest folders only when the physical directory is a meaningful grouping. For example,
`src/Compiler/Example.Generators` may use `/src/Compiler/`; do not add an extra folder solely to
repeat a project name. Use forward-slash paths relative to the repository root.

## Contents and synchronization

- Include every maintained `.csproj` that contributors need to build, test, benchmark, or develop.
  Exclude only generated, vendored, experimental, or intentionally standalone projects; document an
  exclusion when it is not obvious.
- Add root-level contributor files to `/SolutionItems/`. Add a group-specific `.props` file beside
  the projects it controls. Do not list generated output, local settings, external checkouts, `bin`,
  or `obj`.
- Add, move, rename, or delete the matching `.slnx` entry in the same change as a `.csproj` path
  change. Never leave stale paths or empty logical folders.
- Keep sibling entries in deterministic lexical order by path, except place a shared `.props` file
  before the projects it controls.
- Use `BuildDependency` only for a real build-order edge not represented by `ProjectReference`, such
  as an analyzer DLL loaded from another project's output. Do not duplicate ordinary project
  references as solution dependencies.
- Use explicit `<Build Project="false" />` for projects that must be visible but must not be part
  of the default solution build. This is the default for `build/` orchestration/validation projects
  and `playground/` projects. Do not apply it to ordinary test projects: tests must participate in
  the default build so compilation failures are caught before test execution.

## Common .slnx decisions

| Situation | Solution |
| --- | --- |
| A file is important to all contributors | Add it under `/SolutionItems/`. |
| A props file applies to one physical group | Add it to that group's matching folder, not `/SolutionItems/`. |
| A project exists only to orchestrate builds | Put it in `/build/` and set `Build Project="false"` if it must not build by default. |
| A repository-layout validator is implemented as a project | Put it in `/build/`, keep its tests in `/tests/`, and set `Build Project="false"` only on the validator project. |
| A manual Playground project exists | Put it in `/playground/` and set `Build Project="false"`. |
| A test console is useful locally but unsuitable for normal builds | Keep it under its actual directory and set an explicit build exclusion. |
| A benchmark project is part of the repository | Put it in `/benchmarks/`; exclude it from default builds if its dependencies or runtime are unsuitable for normal CI. |
| A project consumes an analyzer DLL from another solution project | Add `BuildDependency` to ensure a clean build orders them correctly. |
| A project path changes | Update the matching `.slnx` entry in the same change and verify all project references. |
