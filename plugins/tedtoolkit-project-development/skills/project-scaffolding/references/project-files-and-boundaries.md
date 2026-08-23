# Project files and boundaries

## Required and conditional files

The repository root must contain `README.md`: explain purpose, supported workflows, and the quickest
way to build or test. Add a project-level `README.md` only when a project has independent setup,
execution, configuration, generation, integration, or package-consumption guidance.

| File | Rule |
| --- | --- |
| `<Project>.csproj` | Required for every SDK-style project. Keep it focused on project identity and project-specific behavior. |
| `GlobalUsings.cs` | Add at the project root only when several files need the same non-implicit namespaces. Do not use it to hide local dependencies. |
| `AssemblyInfo.cs` | Add only for assembly attributes that belong in source, such as `InternalsVisibleTo`; prefer MSBuild properties for ordinary assembly/package metadata. |
| `README.md` | Required at repository root; conditional at project root as described above. |
| `Directory.Build.props` / `.targets` | Use at repository root or a deliberately inherited directory scope; follow the props rules. |
| Generated source | Generate under `obj/` by default. Do not commit generated output into the project source tree unless it is a reviewed source artifact. |

Keep a project-root file only when it applies to that project as a whole. Place feature-specific
files inside their owning feature directory. Do not create `Helpers`, `Utilities`, or `Common`
directories as an escape hatch for unclear ownership.

## Project naming

Use `<Product>` or `<Organization>.<Product>` as a stable prefix. The project name should normally
also be the assembly name, root namespace, and NuGet package ID; document any intentional difference.

| Responsibility | Name |
| --- | --- |
| Consumer-facing library or facade | `<Product>` |
| Public extension points intended for third-party implementations | `<Product>.Abstractions` |
| Concrete provider or implementation | `<Product>.<Provider>` such as `.SqlServer` or `.OpenXml` |
| Command-line application | `<Product>.Cli` |
| Build orchestration | `<Product>.Build` |
| Roslyn analyzer, source generator, or code fix | `<Product>.Analyzers`, `.Generators`, or `.CodeFixes` |
| Test suite | `<Subject>.Tests[.<Profile>]`; omit `.Unit`, and add a profile only for a distinct test execution boundary |
| Shared test support | `<Subject>.TestKit`; create it only for support used by more than one test project |
| Performance measurement | `<Project>.Benchmarks` |

Choose either `.Abstractions` or `.Contracts` for the entire repository; do not use both for the
same concept. Avoid `.Common`, `.Shared`, and `.Core` unless the project has a concrete, documented
dependency boundary. Use `.TestKit`, not `.Tests.Shared`, for shared test-only support so it cannot
be mistaken for an executable test suite.

## Split-project decision

Create another `.csproj` only when the code needs a separate package/API boundary, target framework,
runtime asset, build behavior, dependency boundary, or test execution boundary. Otherwise prefer a
directory and namespace within the existing project.

Before creating a project, state which of those boundaries it creates and which projects may depend
on it. Do not split solely for a namespace, a single type, or presumed future reuse.

## Dependency rules

```text
Contracts / reusable libraries  <- implementations, applications, tests
Implementations                 <- applications, tests
Test support                    <- test projects only
Benchmarks                      -> production projects only
```

- Production projects must not reference test or benchmark projects.
- Reusable libraries must not reference an application or a concrete implementation.
- Test-support projects must not be packed or referenced by production projects.
- Benchmark projects must not become correctness-test dependencies; keep them independently runnable.
- Prefer `ProjectReference` within one repository. Introduce a package dependency only when testing
  the published package or when the package is the real distribution boundary.

## Assets, output, and local state

- Version control test fixtures and required distributable assets in `assets/` or the owning project.
- Keep generated output, `bin/`, `obj/`, test results, profiler captures, caches, local settings, and
  external checkouts ignored unless the repository deliberately versions an artifact.
- Keep release, packaging, generation, and CI-support code under `build/` when it needs a maintained
  home; do not scatter it across source projects or the repository root.

## Validate before automating

Review the following manually while the convention is still evolving:

1. Every solution path resolves and every maintained project is represented appropriately.
2. Project names, folder names, and dependencies follow the rules above.
3. No generated or machine-local artifact is tracked accidentally.
4. Root and conditional project documentation explain the paths a contributor must use.

Automate these checks only after the team has used the rules across several repositories. A future
layout validator should report stale `.slnx` paths, omitted maintained projects, empty folders,
invalid naming, tracked output, and forbidden dependency directions; do not turn a new convention
into a CI gate before its exceptions are understood.
