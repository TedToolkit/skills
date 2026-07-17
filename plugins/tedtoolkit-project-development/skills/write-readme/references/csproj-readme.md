# `.csproj` README: NuGet façade

Write for a consumer who has reached one project or NuGet package and needs to decide whether and how
to use it. Give them both a complete map of its public capabilities and a working first path. This
README may be shown on NuGet only when packaging includes it; verify `PackageReadmeFile`, packing
rules, and image/link behavior before claiming it is the package page.

## Build a complete capability inventory first

Before drafting, create a private, evidence-backed inventory. Treat this as the definition of
"complete": every supported **consumer-visible capability category** has a README home, an explicit
reason to omit it, or a link to its canonical documentation. Do not promise that the README lists
every public type or overload unless the project intentionally exposes a tiny API.

1. Read the `.csproj` and imported packaging properties for package identity, target frameworks,
   dependencies, generated assets, analyzers, content files, `PackageReadmeFile`, and conditional
   features.
2. Inspect public/protected API declarations, XML docs, public extension methods, options/configuration
   types, attributes, DI registrations, source generators/analyzers, and command-line or MSBuild entry
   points. Search the project rather than relying on a manually opened subset of files.
3. Read tests, samples, and existing docs to discover supported workflows, edge cases, and intended
   outcomes. Treat tests as evidence of behavior, not as a reason to document test-only helpers.
4. Group findings by what a consumer can accomplish, not by namespaces or source folders. Typical
   groups are primary workflow, alternatives, configuration, integrations, diagnostics, generated
   output, extensibility, and limitations. Record the evidence source and the README section/link for
   each group. Record its lifecycle status when the repository explicitly marks it as preview,
   deprecated, or replaced.
5. Reconcile the inventory after drafting. Search once more for public entry points and ensure each
   materially distinct workflow is represented. If a capability cannot be explained concisely, link to
   a focused document or sample; do not silently drop it.

Distinguish public API from supported features: document the latter in the README, and use API docs
for exhaustive type/member reference. Exclude obsolete, experimental, internal, test-only, or merely
incidental public surface unless repository evidence presents it as supported. Say when a feature is
conditional on a target framework, package, host, feature flag, or build property.

## Template

Translate all natural-language template text, including headings and table headers, into the output
language selected by `write-readme`. Preserve commands, code, identifiers, URLs, and product names.

```markdown
# <Package or project name>

<One sentence: the capability this package exposes and the consumer it serves.>

<Optional NuGet/version/compatibility badges with maintained sources.>

> <Optional one-line warning for preview status, required companion package, or an incompatible
> version boundary. Do not add a warning when there is none.>

## Install

```sh
dotnet add package <PackageId>
```

<If consumers normally select a provider, sink, or integration package, show the base package and the
one required companion package together, and link to the supported choices.>

## Use

```csharp
// <Small, compiling example showing the primary integration path.>
```

<State what the example does or produces, and link to a complete sample when initialization would
otherwise hide important setup.>

## Capabilities

| What you can do | How to start | Status | Notes / details |
| --- | --- | --- | --- |
| <Primary consumer outcome> | <minimal API, command, or link> | <Stable / Preview / Deprecated, when evidenced> | <constraint or sample link> |
| <Each other materially distinct supported capability> | <entry point or link> | <status, when evidenced> | <required package/configuration, if any> |

<For a compact library, replace the table with short capability-oriented subsections and examples.
Cover all inventory categories; do not turn this into a namespace or every-overload index.>

## Compatibility

- Target frameworks: <from `.csproj`>
- Runtime or platform requirements: <only if material>
- Package dependencies or integration constraints: <only if material>

| Consumer scenario | Package or integration |
| --- | --- |
| <Default scenario> | `<PackageId>` |
| <Provider/host scenario> | `<CompanionPackageId>` |

## Configuration and extension

<Required setup, configuration keys, DI registration, or extension points.>

## Upgrade and troubleshooting

<Breaking-version boundary, migration link, known integration pitfall, or a link to the support
channel. Omit this section when there is nothing package-specific to say.>

## Related documentation

- [Repository overview](<relative link>)
- <API, samples, or sibling integration links>

## Development

```sh
<project-specific restore, test, or run command if it differs from root guidance>
```
```

## Writing points

- Derive package identity, target frameworks, and package metadata from the `.csproj`; do not guess
  a package name when `IsPackable` or `PackageId` says otherwise.
- Build and reconcile the capability inventory before publishing the README. The `Capabilities`
  section must cover every materially distinct supported consumer workflow found in the public API,
  configuration, samples, tests, and package/build integration, or link to its canonical detail.
- Make capability names outcome-oriented and scannable. For each one, show its starting API, command,
  configuration, or sample and state any material dependency or limitation. Prefer a compact table or
  grouped subsections over a flat list of types.
- Show `Stable`, `Preview`, or `Deprecated` only when package metadata, API annotations, release notes,
  or maintained documentation support that status. Link a preview's limitation or a deprecated
  capability's replacement; do not invent a lifecycle label or add a noisy `Stable` column when every
  capability has the same implicit status.
- Keep the primary example small and compiling, but do not let it stand in for undocumented secondary
  workflows. Add focused examples only where the capability table cannot make correct usage clear.
- Make installation and the first example fit together. Include imports, registration, disposal, or
  async usage when a consumer needs them to succeed. State the meaningful result of the example.
- Keep a compact scenario-to-package table when the ecosystem contains providers, sinks, adapters, or
  hosting integrations. It prevents consumers from installing an arbitrary sibling package.
- Document observable compatibility and configuration contracts, not implementation internals.
- Put preview or breaking-change guidance immediately before installation, not at the end of the page.
- Link back to the root README for repository-wide prerequisites, contribution, license, and support.

## Publish gate

Before proposing the README change, compare the completed `Capabilities` section with the private
inventory. Verify that every supported consumer-visible capability discovered from public entry
points, configuration/options, package or MSBuild integration, samples, and behavior tests is either:

- explained in the README;
- represented by a concise capability row or subsection that links to canonical detail; or
- intentionally omitted with a recorded evidence-based reason (for example, obsolete, experimental,
  internal, or test-only).

Re-check conditional target-framework and companion-package features separately. Do not claim
coverage until this reconciliation is complete.

## Exclude

Do not copy the whole root README, explain sibling projects, list private source files, or publish
unverified performance/support claims. Do not force NuGet-oriented sections onto a non-packable
application or test project; explain its actual consumer journey instead. Do not use relative images
or links that a NuGet package page cannot resolve unless the package platform documents that behavior.
