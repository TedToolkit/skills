---
name: maintain-career-profile
description: >-
  Create or update one person's local plain-text Markdown career-profile knowledge base from supplied resumes,
  notes, project evidence, education, learning, and activities. Use for recording, correcting,
  organizing, or importing career history, including detailed company-and-project records that will
  support later resume writing. Do not use for final resume copy, job matching, resume critique, or
  interview materials.
---

# Maintain Career Profile

Maintain a factual, reusable source for later career materials. Read
[career-integrity.md](../../references/career-integrity.md) and
[career-profile-schema.md](../../references/career-profile-schema.md) before writing.

This skill owns profile creation, structure, import, and general maintenance. Route requests to
question the candidate one item at a time and update only explicitly selected existing project
records after each answer to `interview-career-project`. This skill emits no resume,
`# Resume Review`, `# Job Match`, `# Interview Preparation`, or `# Interview Plan` unless separately
requested. Do not store a person's data inside the plugin directory.

## Establish the profile

Identify the person, the supplied sources, and the exact profile root. Keep different people in
separate roots. When the user names an absent root and directly asks to create it, proceed there.
When no location is supplied, propose the schema default and obtain confirmation before writing.

Inspect an existing profile before modifying it. A direct request to update that identified profile
authorizes the smallest changes needed to record the supplied facts; it does not authorize deletion,
unrelated restructuring, or changes to another profile.

## Write only plain-text Markdown

This skill may read supplied resumes, documents, webpages, repositories, or other evidence formats,
but every file it creates or modifies must have the `.md` extension and contain UTF-8 plain-text
Markdown. Do not create or modify JSON, YAML, XML, databases, images, PDFs, DOCX files, binary
attachments, extensionless state, caches, or temporary helper files. Treat every existing non-Markdown
file as read-only. When provenance must be retained, reference the supplied source directly in the
owning work, education, or personal record; never copy the source into the profile tree.

## Build the factual ledger

Read all supplied career-relevant material and classify each fact under the shared provenance rules.
Capture work, education, personal projects, learning, activities, demonstrated skills, outcomes, and
current states even when they are not useful for the current job target. Classify employment,
contracts, volunteering performed for an organization, and their projects under `work/`. Classify
degrees, courses, certifications, research, self-study, and their projects under `education/`.
Classify independent, open-source, hobby, and other self-directed projects under `personal/`. Do not
turn the profile into one polished narrative or discard facts merely because they do not fit a
current resume.

Make each project record independently understandable to a later resume writer who has not read the
source repository or internal notes. Preserve the facts needed to explain what the project was, why
it existed, what the person was responsible for, what they actually did, what was delivered or
changed, and what remains unknown. Do not equate concision with sparsity: retain distinct factual
details when they establish scope, ownership, technical work, chronology, or results.

Group work by the supplied company or organization, education by the supplied school or institution,
and personal projects by their supplied personal brand, open-source organization, or project family.
Every Markdown file below `work/` or `personal/` represents exactly one project; split bundled
project material before writing and do not create role-summary files there. A standalone personal
project with no umbrella may use `personal/independent/`. If an employment project's company or an
education record's institution is unknown, ask the user before creating or moving the affected
record. Never invent an organization or institution or use an `unknown` directory.

Assign every fact one canonical owner before writing it. Person-level identity facts belong in
`profile.md`; applied experience and its projects belong in one `work/` record; education and its
projects belong in one `education/` record; self-directed work belongs in one `personal/` record. Do
not create timeline, skill, project, activity,
learning, evidence, or source indexes. If adding or changing an experience would require rewriting
a supposed "stable career fact" in `profile.md`, that fact belongs in the relevant record instead.

For every material record, preserve:

- dates and useful milestones, or an explicit unknown state;
- organization, role, engagement, project context, objective, and intended deliverable when supplied;
- personal ownership and responsibility boundaries separately from team or company work;
- concrete systems, modules, workflows, integrations, or problems handled by the person;
- deliverables, supported scope, outcomes, adoption, or truthful current state;
- methods, technologies, and material operating constraints;
- support class and, only when useful, inline source provenance; and
- unresolved gaps or contradictions.

The profile records are the canonical facts once the user confirms them. Omit routine source
metadata for confirmed facts. Preserve a sanitized source path or description inside the owning
record only when a fact is imported, still unconfirmed, automatically corroborated, or involved in
a conflict. Never create a central evidence or source registry.

Write specific, self-contained factual bullets or short factual paragraphs. Explain private project
names and internal terms in plain domain language when the supplied evidence permits it. Do not add
a professional summary, inferred theme, evaluation, recommendation, praise, criticism, marketing
language, or repeated capability description merely to make the profile read like a resume. Do not
turn implementation breadth, commit counts, lines changed, or technical difficulty into an
unsupported claim of quality, seniority, productivity, or business impact.

When a record has missing, uncertain, or conflicting facts, add a locale-appropriate section such
as `## To Confirm` containing short, answerable bullets for the reader. Do not put placeholders in
factual sections, and omit the section when nothing remains unresolved.

Ask one focused question only when identity, destination, conflicting facts, or a high-impact missing
value makes the requested update unsafe. Otherwise record the gap without inventing an answer.

## Plan and write the update

For a planning-only request, show the proposed root and file changes and stop. For an authorized
creation or update, write only the necessary Markdown files using the shared schema:

1. create or update category records;
2. place every work project under `work/<organization>/`, every education record under
   `education/<institution>/`, and every self-directed project under `personal/<group>/`;
3. keep any necessary source pointer inside its owning record;
4. update `profile.md` only when stable person-level identity facts changed; and
5. keep sensitive resume-submission data isolated in `private/contact.md`.

When the user wants a complete resume-ready private profile, request the supplied resume name,
phone, email, city or broad location, and an existing portrait-photo path. Record only values the
user provides. Because this skill writes only Markdown, store the portrait as a path and optional
usage note in `private/contact.md`; never copy, generate, edit, or embed the image. Missing private
values do not block factual work or justify placeholder facts, but must be reported as unresolved.

Do not create empty category trees, duplicate an existing role record, overwrite unrelated notes,
or silently resolve conflicting sources. Warn before writing personal data into a tracked or shared
repository.

## Verify and report

Re-read every changed record and verify person isolation, dates, attribution, support class, source
pointers where retained, absence of duplicate or invented facts, and that every created or modified
file is UTF-8 plain-text Markdown with a `.md` extension. Verify that experience records exist only
under a supplied organization, institution, or personal group within `work/`, `education/`, or
`personal/`, that every work or personal file is one project, and that no derived index was created.
For each project record, verify that it preserves every available fact needed to understand its
context, the person's responsibility boundary, concrete work, deliverable or current state, and
supported outcomes; put missing high-value result facts under `To Confirm` instead of inventing them.
Report the exact created or updated paths, the facts recorded, and the smallest set of unresolved
questions. Do not add resume-style claims or career advice to the profile update unless separately
requested.
