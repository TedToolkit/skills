# Repository-root README: GitHub façade

Write for a visitor deciding whether to trust, adopt, or contribute to the repository. Lead with
value and a path to first success; treat the README as navigation, not a full manual. A source
repository and its released product are different things: make that relationship explicit when it
hosts more than one package, application, or release channel.

## Template

Translate all natural-language template text, including headings and table headers, into the output
language selected by `write-readme`. Preserve commands, code, identifiers, URLs, and product names.

```markdown
# <Repository name>

<One sentence: what it provides, for whom, and the distinguishing outcome.>

<Optional build/package/license badges that are maintained and actionable.>

## What it is for

- <Capability or problem solved>
- <Capability or constraint that differentiates it>

## Choose a starting point

| I want to… | Start here |
| --- | --- |
| <Use the released package or application> | [<consumer guide>](<relative or canonical link>) |
| <Evaluate a working example> | [<sample>](<relative link>) |
| <Build or contribute to source> | [Development](#development) |

## Quick start

<Smallest verified installation, build, or first-use sequence.>

## Packages and components

| Component | Purpose | Documentation |
| --- | --- | --- |
| `<name>` | <one responsibility> | [README](<relative link>) |

## Support and compatibility

- Supported runtime/platforms: <link to the authoritative support policy or state a concise rule>
- Release status: <stable, preview, nightly, or other evidence-based status>
- Security: [report a vulnerability](SECURITY.md)

## Development

### Prerequisites

- <Pinned SDK, runtime, or tool>

### Build and test

```sh
<verified commands>
```

## Contributing

<Link to contribution guidance, issue process, and local conventions.>

## Getting help

<Link each audience to the right channel: usage questions, bug reports, feature proposals, or
discussions.>

## License

<License name and link.>
```

## Writing points

- State the problem and intended audience before listing features.
- Make the quick start independently runnable; distinguish a consumer's first step from a
  contributor's clone/build/test flow.
- Give visitors an explicit route for the common intents: consume, try an example, contribute, or
  report a problem. Large repositories use this routing to keep the landing page short.
- Summarize components by responsibility and link to their own README; do not embed each package's
  API guide here.
- Include only badges with a maintained source and a decision-making purpose. Omit decorative badges.
- State release maturity and support boundaries only when the repository has an authoritative source.
  Link to `CONTRIBUTING`, security guidance, roadmap, and full documentation instead of duplicating
  them. Describe licensing precisely.

## Exclude

Do not include a recursive directory listing, detailed internal architecture, every package API,
release notes, or commands that only apply to one project. Move those details to project or directory
README files.
