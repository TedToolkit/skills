# Directory README: code map

Write for a maintainer entering a non-project directory. Explain the code boundary and the local
mental model; do not turn the README into a file catalogue. A directory README is valuable only when
it captures information a reader cannot derive quickly from names and source: a boundary, workflow,
invariant, or change-impact rule.

## Template

Translate all natural-language template text, including headings and table headers, into the output
language selected by `write-readme`. Preserve commands, code, identifiers, URLs, and product names.

```markdown
# `<relative/directory/path>`

<One sentence: the responsibility of the code in this directory.>

## Responsibilities

- <What belongs here>
- <What does not belong here, when useful>

## Organization

| Area | Responsibility |
| --- | --- |
| `<subdirectory or file group>` | <role in this boundary> |

## Dependencies and boundaries

<Allowed dependency direction, public entry points, generated-code rule, or ownership constraint.>

## Change impact

<Name the tests, generated outputs, consumers, or adjacent directories that must be considered when
this area changes.>

## Working here

<Local setup, test/build command, generation step, or change rule that differs from parent guidance.>

## Verify and clean up

<Expected result, focused verification command, cleanup command, or link to the parent workflow.>

## Related documentation

- [Parent context](<relative link>)
- <Project/API/design link>
```

## Writing points

- Explain why the directory exists and what change belongs here before naming subdirectories.
- Describe groups of code and dependency direction; mention individual files only when one is an
  entry point, generated artifact, compatibility boundary, or other non-obvious exception.
- Record local conventions that a contributor could otherwise violate: layering, generated files,
  ownership, test fixture placement, or integration boundary.
- State the change impact for a high-risk boundary: downstream consumers, generated artifacts,
  integration tests, or compatibility surfaces. This lets a maintainer choose the right validation.
- For a directory with a local workflow, provide the smallest command sequence plus the observable
  success condition. Add cleanup only when the workflow creates material local output.
- Link to the nearest parent README and only add commands that differ from parent or project guidance.

## Exclude

Do not restate repository installation, NuGet consumption, or generic coding rules. Do not document
every class or mirror the file tree; let the source and names carry ordinary detail. Do not add a
directory README merely because a directory exists.
