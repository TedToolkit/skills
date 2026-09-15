# Career Profile Schema

Use this schema when creating or reading a local Markdown career profile. The profile is a factual
source for later career materials, not a resume draft.

## Location and isolation

Use the exact root selected by the user. When no location is supplied, propose
`career-workspace/` in the active workspace and obtain confirmation before writing. This selected
root is itself person-bound: never add another person identifier or another `career-workspace/`
directory below it. Never place personal records inside the installed plugin or its source
directory.

An explicitly supplied legacy `career-profiles/<person-id>/` root remains readable and writable in
place under the same factual and authorization rules. Do not move, copy, rewrite, or wrap it merely
to adopt the new default. Each selected root contains one person; do not infer identity from
unrelated workspace data.

```text
career-workspace/
├── profile.md
├── work/
│   └── <organization-id>/
│       └── YYYY-MM--YYYY-MM-<project-slug>.md
├── education/
│   └── <institution-id>/
│       └── YYYY-MM--YYYY-MM-<record-slug>.md
├── personal/
│   └── <group-id>/
│       └── YYYY-MM--YYYY-MM-<project-slug>.md
├── private/
│   └── contact.md
├── companies/
│   └── <company-id>/
│       └── company.md
└── applications/
    └── <company-id>/
        └── <role-id>/
            ├── role.md
            ├── match.md
            ├── resume.md
            └── interview-preparation.md
```

`work/` owns employment, contracts, organizational volunteering, and projects performed in those
contexts. `education/` owns degrees, courses, certifications, research, self-study, and projects
performed for learning. `personal/` owns independent, open-source, hobby, and other self-directed
projects. These are the only experience categories. Create only files and category directories that
contain supplied facts.

Use one stable directory per supplied company, organization, school, institution, personal brand,
or project family. Use its supplied display name as the directory name after only the filesystem
sanitization that is necessary. The directory is the canonical parent fact; do not repeat that name
in every child record. Every Markdown file below `work/` or `personal/` is exactly one project. Group personal projects by a
supplied personal brand, open-source organization, or project family; a standalone project with no
umbrella may use `personal/independent/`. Do not create role summaries, company index files,
multi-project files, or `unknown` organization directories. If an employment project's company or
an education record's school is unknown, stop before writing that record and ask the user for the
missing parent.

`companies/` owns externally researched facts about target employers. `applications/` owns one
identified company's one identified role plus derived candidate artifacts for that target. These
trees never own candidate employment facts. Read [target-research-schema.md](target-research-schema.md)
before creating or using either tree.

## File format

Every file created or modified by this skill must be UTF-8 plain-text Markdown and end in `.md`.
This applies to profile records, private contact data, notes, and any execution helper or
temporary output. Do not write JSON, YAML, XML, databases, images, PDFs, DOCX files, binaries,
extensionless state, caches, or sidecar metadata. Markdown frontmatter inside a `.md` file is
allowed. Supplied non-Markdown evidence remains read-only. When its provenance must be retained,
reference it directly from the owning work, education, or personal record; never copy it into the
profile root. Preserve existing non-Markdown files without modifying or deleting them.

## Root profile

`profile.md` identifies the person with only supplied, durable person-level facts that are not owned
by another record. Suitable facts include a preferred name, a stable
public professional handle, or supplied languages. Do not put project-derived capabilities,
experience duration, current focus, professional summaries, target directions, record lists, or
contact data in `profile.md`. A new experience should not normally require this file to change.
Keep mutable goals and preferences outside the stable profile unless a future schema gives them a
dedicated canonical record. Do not create timeline, skill, project, activity, learning, evidence, or
source index files; derive those views from the canonical records when a later task needs them.

## Category records

Use Markdown files whose names begin with their period:

- `YYYY-MM--YYYY-MM-<slug>.md`
- `YYYY-MM--present-<slug>.md`
- `undated-<slug>.md` when the period is genuinely unknown

Use one record per work or personal project. For education, use one record per program, course,
certification, research effort, self-study period, or education project. Split a record when its
organization, institution, project, context, or support boundary materially changes.

Use this frontmatter and omit fields that are neither applicable nor supported:

```md
---
id: <stable-id>
kind: work | education | personal
record_type: project | degree | course | certification | research | self-study
start: YYYY-MM | unknown
end: YYYY-MM | present | unknown
role: <supplied value when applicable>
engagement: employment | contract | volunteer | independent | open-source | personal
support: candidate-asserted | corroborated | derived
sources:
  - <optional sanitized path, URL, or source description>
updated: YYYY-MM-DD
---

# <Record title>
```

### Project record content

A work or personal project record is a factual dossier for later resume writing, not resume copy.
It must be detailed enough that a later writer can understand the project and select defensible
claims without reopening the original repository or notes. Use the following headings when the
available facts justify them, translate headings consistently to the record's language, combine
overlapping sections, and omit empty sections:

```md
## Context and Objective
## Role and Responsibility Boundaries
## System and Work Performed
## Deliverables and Outcomes
## Evidence
## Timeline
## Technologies
## To Confirm
```

Capture the following facts without requiring one bullet per item:

- `Context and Objective`: the domain workflow or problem, intended users or customer when supplied,
  why the project existed, and whether the expected deliverable was an application, service,
  library, report, research result, or another concrete form.
- `Role and Responsibility Boundaries`: the supplied role, whether ownership was sole or shared,
  personally owned components and responsibilities, integrations or handoffs, and material team
  responsibilities that must not be misattributed to the person.
- `System and Work Performed`: concrete architecture, components, capabilities, workflows,
  algorithms, integrations, data handling, reliability work, and operational constraints that the
  person implemented or handled. Preserve distinctions between implementation, integration,
  orchestration, maintenance, and original invention.
- `Deliverables and Outcomes`: what was released, delivered, accepted, deployed, adopted, reused,
  measured, or otherwise reached a supported state. Include supplied versions, dates, scale, quality
  measures, performance changes, or user impact. Name the actor and scope so a personal deliverable
  is not confused with a team, company, or customer outcome.
- `Evidence`: only useful verification facts or source-scoped observations, such as repository
  history, authorship boundaries, test or acceptance evidence, or a sanitized source pointer. State
  exactly what the evidence supports. Activity measures such as commits or lines changed are not
  outcomes and must not be interpreted as quality, productivity, seniority, or impact.
- `Timeline`: useful dated milestones that clarify sequence, duration, ownership, release, or later
  maintenance. Do not manufacture precision that the sources do not contain.
- `Technologies`: supplied languages, frameworks, platforms, protocols, tools, and technical domains
  materially used in the project. Do not add proficiency ratings or evaluative labels.
- `To Confirm`: short, answerable questions for missing or conflicting high-value facts, especially
  delivery or acceptance dates, deployment or adoption, scale, performance, accuracy, quality,
  time saved, reduced rework, and the boundary between personal and team work.

Use specific, self-contained factual bullets or short factual paragraphs. Explain internal names in
plain domain language when supported. Record only observed, candidate-asserted, corroborated, or
conservatively derived facts. Do not add evaluations, recommendations, inferred significance,
superlatives, or resume-style promotion. A project with no supported metric may still record a
concrete deliverable or truthful current state; place desirable but unknown result facts under
`To Confirm` rather than inventing them.

For non-project education records, a compact `## Facts` section is sufficient when it preserves the
program or activity, institution, dates, status, work performed, results, technologies, and any
relevant responsibility boundary. Use `## To Confirm` for unresolved facts.

Store each fact once; do not repeat it under another heading. Keep personal contribution separate
from team outcomes. The frontmatter `sources` field is optional: omit it for facts the user has
confirmed, and retain only sanitized source pointers needed for imported, unconfirmed, automatically
corroborated, or conflicting facts. Do not create a central source registry. Never fill missing or
conflicting facts by inference, and omit `To Confirm` when there are no unresolved facts.

## Private resume-submission data

When the user asks to retain private resume-submission data, keep it in `private/contact.md`. Store
only supplied values: the name used on resumes, phone number, email address, city or broad location,
public professional links used for applications, and a local path to an existing portrait photo.
An optional note may describe whether the portrait is intended for a resume and any supplied crop
or usage preference.

The portrait remains outside the profile tree. Because the skill writes only Markdown, never copy,
generate, edit, inspect, embed, or otherwise write the image. Treat the path as sensitive and do not
read private data for matching, review, or interview tasks that do not need it. Missing private
values are reported to the user and never represented as invented placeholders. Do not store
government identifiers, credentials, secrets, compensation, health data, precise home addresses, or
unrelated protected traits. Warn before placing private data in a tracked or shared repository.

## Updating

Inspect the existing profile and records before writing. Update the smallest relevant set of files,
preserve stable IDs and inline source pointers, and move existing records only when the user
authorizes a schema migration. Do not update `profile.md` for ordinary experience changes. Do not
create duplicate records for the same project and context or recreate removed derived indexes. Do
not move a work or education record until its supplied organization or institution is known. Move a
self-directed project to `personal/` instead of representing it as employment.
Before reporting completion, enumerate every created or modified path and fail verification if any
path does not end in `.md` or its content is not UTF-8 plain text.
