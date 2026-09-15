---
name: maintain-hiring-workspace
description: >-
  Create or update a company-scoped hiring workspace containing roles, canonical candidates,
  normalized resume records, and explicit role applications. Use for organizing supplied hiring
  evidence. Do not use for candidate assessment, interview plans, applicant tracking, candidate
  profile editing, or hiring decisions.
---

# Maintain Hiring Workspace

Organize supplied hiring facts without changing their sources. Read
[hiring-integrity.md](../../references/hiring-integrity.md) and
[hiring-workspace-schema.md](../../references/hiring-workspace-schema.md).

This skill solely owns company, role, canonical candidate, normalized resume, and application
records. Route assessment to `assess-candidate` and interviewer-plan creation to `design-interview`.
Do not create candidate-facing career profiles or resume copy.

## Select the bounded records

Identify the selected root, company ID, and each requested role, candidate, resume record, or
application ID before reading or writing. Use `hiring-workspace/` as the proposed default root, but
wait for confirmation when the user has not selected a root. Treat another selected root as the
root itself; never add a second `hiring-workspace/` directory beneath it.

Map each requested record to its exact canonical path and ensure the user's request authorizes each
absent destination. Ask one focused question for a missing or ambiguous identifier, source, or
destination. Before overwriting any existing file, require authorization naming that exact path.

Read only the selected records and explicitly supplied source files. Never enumerate or inspect
sibling companies or candidates to infer missing facts. Treat all source resumes and personal
profiles as immutable.

## Normalize the supplied evidence

Create only the requested records using the schema. Keep one candidate record per company and link
it from any number of explicit role applications. A second role creates another application, not a
duplicate candidate. Keep assessments and interview plans out of canonical candidate records.
When the user authorizes newly supplied evidence for an existing application, update only that
application's exact `evidence` list; this bounded update must occur before assessment or interview
design uses the new source.

For an authorized normalized resume record:

- create a new dated Markdown file at the exact canonical destination;
- bind `source` to the exact immutable source named for this record in the request; never substitute
  another candidate's source or any canonical hiring record;
- retain only supported, job-related evidence with attribution and scope;
- exclude protected traits and unnecessary contact details; and
- stop rather than overwrite an existing destination without exact authorization.

Do not create derived indexes, status logs, databases, hidden state, or files outside the selected
root.

For each application, bind `evidence` to the exact ordered source selection authorized for that
application. Do not infer the selection from another application or from files merely present in
the workspace.

## Deliver

Report the exact created or updated paths, immutable sources consulted, excluded categories without
repeating sensitive values, and unresolved conflicts. Emit no candidate assessment, interview plan,
ranking, or final hiring verdict.
