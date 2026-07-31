---
name: write-readme
description: >-
  Orient readers with evidence-based README files in .NET repositories. Use for a repository entry
  point, package consumer guide beside a csproj, or directory map that must explain first use,
  capabilities, responsibilities, or navigation, including orientation requested by another
  project-development skill.
---

# Write README

Make each README an **entry point** for its directory's audience. Keep the scope narrow: a child
README adds information that its parent cannot express clearly, rather than retelling it.

This skill owns reader-facing orientation and first-use guidance. Read the governing dependency
direction in [change-development-workflow.md](../../references/change-development-workflow.md)
before summarizing product, architecture, principle, or delivery content. Link the owning record;
invoke `library-product-intent`, `architecture-design`, `design-principles`, or `change-design`
when that source content is missing.

Keep `docs/changes/` on its explicit `change.md` and focused work-item files; place no README there.

## Inspect before drafting

1. Read the target directory, its nearest parent README files, root README, `CLAUDE.md`, `AGENTS.md`,
   and, for a library README, `docs/product/README.md` when it exists. For a project README, also
   read the `.csproj`, public API, package metadata, tests, samples, and consumer-facing
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
- Use emoji and Unicode symbols deliberately to make a README easier to scan. Prefer familiar markers
  such as `🚀` for a quick start, `💡` for a practical tip, `⚠️` for an important constraint, `✅` for
  verification, and `🧭` for navigation. Use them in short headings, callouts, and compact lists when
  they clarify the reader's next action; keep the accompanying text explicit, and do not put symbols
  inside commands, identifiers, paths, links, or code. Match a repository's established visual tone
  and avoid decorative clutter.
- Put the reader's first successful action near the top, using commands verified against the repository.
- Omit inapplicable sections rather than leaving template headings empty.
- Link downward to detail and upward to context using relative links. Keep one source of truth for each
  instruction: repository-wide rules at root, package contracts beside the `.csproj`, local rules in
  the directory.
- For repository documentation navigation, link to applicable design principles, current architecture
  records, active migrations, and active epics when they help the reader's next task. Do not use a
  README as an archive index; link to a principle, ADR, architecture record, or active migration only
  when it informs current work.
- State material constraints only when evidenced by source or project metadata; never make
  unsupported marketing claims.
- When approved product intent exists, summarize its positioning statement and link to
  `docs/product/README.md`; do not duplicate its audience, problem, value, and non-goals sections.

## Review

Before proposing the final change, verify links and commands, ensure headings follow a logical
outline, and remove duplicated or stale content. Re-read each README from its intended reader's
starting point: it should answer why this scope exists, what to do next, and where to find detail.

Complete when every claim has repository evidence, every command and link is verified, each fact
has one owning location, empty template sections are absent, and the intended reader can complete
their first task from the documented path.
