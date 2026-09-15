# ADR-001: Separate candidate and hiring workflows

- Status: Accepted
- Date: 2026-09-15
- Decision owner: Repository owner
- Decision scope: TedToolkit career and hiring plugins and their persisted Markdown workspace boundaries.
- Applicable product intent: None
- Applicable principles: Repository guidance in [`AGENTS.md`](../../AGENTS.md) and [`CLAUDE.md`](../../CLAUDE.md)
- Supersedes: None
- Superseded by: None
- Approval source: User approved the two-plugin direction and the breaking migration in the Codex conversation on 2026-09-15.

## Decision at a glance

Keep `tedtoolkit-career` as a single-candidate job-search plugin and create an independent
`tedtoolkit-hiring` plugin for company, role, candidate, application, assessment, and interviewer
workflows.

## Context and decision question

`tedtoolkit-career` currently combines workflows for one person maintaining career evidence and
preparing applications with workflows for an interviewer evaluating another person. The two
audiences have different data cardinality, privacy boundaries, output ownership, and installation
needs. The decision is whether to keep these capabilities in one plugin, group them in nested Skill
folders, or expose candidate and hiring workflows as separate installable plugins.

## Decision drivers and constraints

| Type | Driver or constraint | Evidence or source | Priority |
| --- | --- | --- | --- |
| Hard constraint | Skills remain direct children of `plugins/<plugin>/skills/`. | [`CLAUDE.md`](../../CLAUDE.md) | Must |
| Hard constraint | Codex and Claude marketplace manifests declare the same plugin set. | [`CLAUDE.md`](../../CLAUDE.md) | Must |
| Decision driver | Candidate workflows own one person's evidence across many target companies and applications. | Approved user direction; current career-profile schema | High |
| Decision driver | Hiring workflows own companies containing multiple roles, candidates, and applications. | Approved user direction | High |
| Decision driver | Candidate preparation and interviewer evaluation need distinct privacy, fairness, and output rules. | Current `prepare-for-interview` and `design-interview` contracts | High |
| Desired quality | Users can install only the persona-specific capability they need. | Approved user direction | Medium |

## Options and evidence

| Option | Evidence and confidence | Meets drivers | Decisive trade-off | Outcome |
| --- | --- | --- | --- | --- |
| Keep one flat plugin | Documented current state, high confidence | No | Preserves installation compatibility but keeps conflicting personas and policies together. | Rejected |
| Add nested candidate/interviewer Skill folders | Repository layout contract, high confidence | No | Visually groups Skills but violates the direct-child discovery convention. | Rejected |
| Create candidate and hiring plugins | User-approved model and current Skill boundaries, high confidence | Yes | Requires a breaking Skill migration and a second plugin manifest. | Selected |
| Create two persona plugins plus a shared career-core plugin | Assumed future reuse, low confidence | Partly | Adds installation coupling before shared executable capability exists. | Rejected |

## Decision

`tedtoolkit-career` remains the candidate-facing plugin. It owns one person's factual career
workspace, target-company and target-role research, requirement matching, targeted resume writing
and review, and candidate interview preparation.

`tedtoolkit-hiring` becomes the interviewer-facing plugin. It owns company-scoped roles,
candidates, applications, candidate assessment, and interviewer plan design. `design-interview`
moves to this plugin without a duplicate compatibility Skill in `tedtoolkit-career`.

The plugins may use similar evidence terminology, but neither requires the other to be installed and
neither reads or mutates the other plugin's persisted workspace by default.

## Why this decision now

The approved company and role research capability makes the existing persona ambiguity visible:
candidate-side company research supports one person's application, whereas interviewer-side company
organization manages many people's records and hiring decisions. Separating the plugins before
adding those persisted structures prevents one schema and one integrity policy from accumulating
incompatible ownership rules. Nested Skill folders are unavailable under the repository's current
plugin contract, and a shared third plugin would add dependency complexity without a demonstrated
shared runtime capability.

## Evidence and links

- [`tedtoolkit-career` manifest](../../plugins/tedtoolkit-career/.codex-plugin/plugin.json)
- [Candidate preparation Skill](../../plugins/tedtoolkit-career/skills/prepare-for-interview/SKILL.md)
- [Hiring interviewer-design Skill](../../plugins/tedtoolkit-hiring/skills/design-interview/SKILL.md)
- [Current career-profile schema](../../plugins/tedtoolkit-career/references/career-profile-schema.md)

## Consequences and accepted trade-offs

- Candidate and hiring installations, routing descriptions, tests, and privacy rules can evolve
  independently.
- Existing users of `design-interview` must install `tedtoolkit-hiring`; no duplicate compatibility
  entry remains in `tedtoolkit-career`.
- Candidate workspaces no longer need a person identifier below an already person-bound root, while
  target-company and application facts remain separate from employment history.
- Hiring workspaces require explicit company, role, candidate, and application ownership so one
  resume or assessment is not silently attributed to another candidate.
- Some evidence-integrity concepts may appear in both plugins, but persona-specific policies remain
  independently owned rather than coupled through an additional plugin.

## Downstream delivery constraints

- Both marketplaces expose the same two persona plugins and each plugin remains independently
  installable.
- Candidate Skills must not create interviewer assessments or hiring decisions; hiring Skills must
  not rewrite a candidate's source resume or personal career profile.
- Public company and role research distinguishes dated sourced facts from inference and unknowns.
- Candidate resume writing requires a concrete company-role target and supported personal evidence.
- Hiring data isolates candidates and keeps assessments under a specific company-role application.
- Persisted user data is never automatically moved, copied, or deleted during the plugin migration.

## Exit requirements

Merging the plugins again requires a superseding decision that preserves persona-specific data
ownership, installation choice, privacy, fairness, and Skill discovery without duplicate routing.

## Follow-ups and review triggers

| Item | Owner | Due date or objective trigger | Status |
| --- | --- | --- | --- |
| Reassess cross-plugin duplication | Repository owner | A required workflow cannot complete without both plugins, or a shared executable contract emerges. | Open |
| Reassess Skill layout | Repository owner | The plugin platform formally supports nested persona namespaces. | Open |

