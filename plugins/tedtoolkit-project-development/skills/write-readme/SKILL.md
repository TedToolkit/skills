---
name: write-readme
description: >-
  Write, review, or restructure README.md files in .NET repositories. Use when creating or improving
  a repository-root README, a README beside a .csproj project, or a README in an ordinary directory;
  when explaining installation, package usage, project architecture, or a focused subsystem without
  duplicating information owned by a parent README.
---

# Write README

Treat each README as the entry point for its directory's audience. Keep the scope narrow: a child
README adds information that its parent cannot express clearly, rather than retelling it.

## Inspect before drafting

1. Read the target directory, its nearest parent README files, root README, `CLAUDE.md`, `AGENTS.md`, and, for
   a project README, the `.csproj`, public API, package metadata, tests, samples, and consumer-facing
   configuration. For a library, inventory the public capabilities before choosing README sections;
   do not infer a feature solely from a project or folder name.
2. Identify the intended reader and their first task. Base every claim on repository evidence; flag
   missing decisions instead of inventing commands, compatibility, or release policy.
3. Propose the target README locations and a concise outline. Wait for explicit approval before
   creating or editing README files.

## Select the README level

- For the repository-root `README.md`, read [root-readme.md](references/root-readme.md). It is the
  GitHub façade: help a visitor understand and start using the repository.
- For a `README.md` in the same directory as a `.csproj`, read
  [csproj-readme.md](references/csproj-readme.md). It is the NuGet façade: give a consumer a
  complete, evidence-based map of the package's public capabilities, then help them install and use it.
- For every other directory `README.md`, read [directory-readme.md](references/directory-readme.md).
  It is code navigation: explain the responsibility and organization of that directory.

Use a root README alone for small repositories. Add a project README when a project has an independent
consumer journey or operational contract. Add a directory README only when orientation, ownership,
or local rules cannot be inferred from the name and files.

## Shared rules

- Write in the user's explicitly requested language. Otherwise, use the human language for README
  and code-comment prose declared in root `CLAUDE.md`. If it is absent, use the target directory's
  nearest existing README language and terminology; if that is unavailable, use the repository-root
  README. Ask before drafting when the language remains unclear. `AGENTS.md` is only a direct
  reference to `CLAUDE.md`, not an alternative language policy.
- Treat reference templates as structural examples, not fixed-language output. Translate headings,
  labels, explanatory prose, table headers, and placeholders into the selected language; preserve
  commands, identifiers, package names, file names, URLs, and code unless local documentation
  convention translates an established technical term.
- Start with a descriptive H1 and a one- or two-sentence purpose statement.
- Put the reader's first successful action near the top, using commands verified against the repository.
- Omit inapplicable sections rather than leaving template headings empty.
- Link downward to detail and upward to context using relative links. Keep one source of truth for each
  instruction: repository-wide rules at root, package contracts beside the `.csproj`, local rules in
  the directory.
- For repository documentation navigation, link to current architecture records, active migrations,
  and active epics when they help the reader's next task. Do not use a README as an archive index or
  link to `docs/history/` unless historical context is explicitly needed to understand a current ADR
  or migration.
- State material constraints only when evidenced by source or project metadata; never make
  unsupported marketing claims.

## Review

Before proposing the final change, verify links and commands, ensure headings follow a logical
outline, and remove duplicated or stale content. Re-read each README from its intended reader's
starting point: it should answer why this scope exists, what to do next, and where to find detail.
