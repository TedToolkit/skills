# Separate candidate and hiring workflows into independently installable plugins

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: migration -->
<!-- change-status: approved -->
<!-- delivery-shape: multi-item -->

- Priority: P1
<!-- approval-source: User approved the complete contract and requested continuation in the Codex conversation on 2026-09-15. -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

Give job seekers and interviewers independently installable, persona-correct workflows: one
candidate can research multiple companies and create role-targeted materials without a redundant
person namespace, while a hiring workspace can isolate multiple companies, roles, candidates, and
applications. The current combined plugin mixes these ownership, privacy, and routing models, and
the approved research expansion would otherwise deepen that ambiguity.

<!-- section: scope -->
## Scope and non-goals

- In scope:
  - retain `tedtoolkit-career` as the candidate plugin and introduce `tedtoolkit-hiring`;
  - add candidate-side company and company-role research with dated, attributable Markdown facts;
  - make final resume writing depend on supported candidate evidence and a concrete company-role
    target;
  - define a one-person candidate workspace and a company-scoped multi-candidate hiring workspace;
  - move `design-interview` to hiring, rename the candidate project-debrief entry to
    `enrich-career-project`, and update routing, manifests, marketplace entries, repository guidance,
    and evals;
  - add hiring workspace maintenance and candidate-assessment Skills with privacy and fairness
    boundaries.
- Non-goals:
  - applicant tracking, hiring workflow automation, messaging, calendar integration, final hiring
    decisions, or employment-law advice;
  - automatic migration, copying, deletion, or reorganization of existing user data;
  - storing scraped webpage copies, secrets, protected-trait data, or unnecessary contact details;
  - PDF or DOCX resume generation and external service integrations.
- Compatibility or deliberately preserved behavior:
  - existing explicitly supplied career-profile roots remain readable; only the default proposed
    layout changes to a person-bound `career-workspace/`;
  - existing factual-integrity, artifact-write authorization, and unsupported-claim protections
    remain in force;
  - `design-interview` and `interview-career-project` are removed from `tedtoolkit-career` without
    duplicate aliases; migration guidance names `tedtoolkit-hiring/design-interview` and
    `tedtoolkit-career/enrich-career-project` respectively;
  - existing user files remain untouched unless a later user explicitly authorizes a bounded
    workspace update.
  - paired `tedtoolkit-career` manifests advance from `0.3.0` to `0.4.0`; the new paired
    `tedtoolkit-hiring` manifests start at `0.1.0`.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Plugin installation and Skill discovery | One career plugin exposes candidate and interviewer Skills. | Marketplace users can install candidate and hiring plugins independently, with each Skill owned by exactly one persona plugin. | Skills remain direct children of one plugin's `skills/` directory and both marketplace manifests agree. |
| OB-02 | Candidate research and application workspace | Personal facts use a multi-person root convention and target-company facts have no canonical owner. | One person-bound workspace separates career facts, target companies, and company-role applications without a nested person identifier. | A supplied existing profile root remains readable and no user data is migrated automatically. |
| OB-03 | Targeted resume writing | `write-resume` can emit a general resume when no target exists and parses only an optional raw job description. | Final resume copy requires supported candidate evidence plus requirements attributable to one identified company and one identified role, using an internal evidence match before writing. Generic, role-only, or company-unattributed requirements block final copy. | Resume claims remain factual, source-bounded, Markdown-only, and separately authorized. |
| OB-04 | Hiring data and interviewer workflows | Interview plans live beside candidate self-preparation and there is no canonical multi-candidate workspace. | Hiring Skills organize companies, roles, canonical candidate records, role applications, assessments, and interview plans with candidate isolation and job-related fairness. | Hiring Skills do not rewrite source resumes, modify personal career profiles, infer protected traits, or make the final hiring decision. |

### Persisted workspace ownership

| Persona | Canonical owner | Default canonical path |
| --- | --- | --- |
| Candidate | Stable person facts | `career-workspace/profile.md` |
| Candidate | Employment, education, personal work, and private contact facts | `career-workspace/work/`, `education/`, `personal/`, and `private/` using the existing record rules |
| Candidate | One researched target company | `career-workspace/companies/<company-id>/company.md` |
| Candidate | One company-role target and its application artifacts | `career-workspace/applications/<company-id>/<role-id>/role.md`, `match.md`, `resume.md`, and `interview-preparation.md` |
| Hiring | One hiring company | `hiring-workspace/companies/<company-id>/company.md` |
| Hiring | One company role | `hiring-workspace/companies/<company-id>/roles/<role-id>/role.md` |
| Hiring | One canonical candidate within that company | `hiring-workspace/companies/<company-id>/candidates/<candidate-id>/candidate.md` |
| Hiring | Authorized normalized resume records for that candidate | `hiring-workspace/companies/<company-id>/candidates/<candidate-id>/resumes/<YYYY-MM-DD>-resume.md` |
| Hiring | One candidate's application to one company role | `hiring-workspace/companies/<company-id>/applications/<role-id>/<candidate-id>/application.md`, `assessment.md`, and `interview-plan.md` |

`career-workspace/` and `hiring-workspace/` are default selected roots, not directories added below
another selected root. A user-selected replacement root owns the listed relative contents directly.
The candidate root itself is person-bound and therefore has no nested person ID. An explicitly
supplied legacy `career-profiles/<person-id>/` root remains readable in place, but no Skill moves or
rewrites it merely to adopt the new default. Source resumes and personal profiles are read-only
evidence; creating a normalized hiring resume record requires explicit authorization for that exact
destination and never overwrites or edits its source.

<!-- acceptance-case: AC-01 -->
### AC-01 — Persona plugins install and route independently

```gherkin
Scenario: Install candidate and hiring capabilities
  Given the repository marketplace manifests and both plugin directories
  When the release contracts and persona-specific invocation evals run
  Then both marketplaces expose the same independently valid plugins and every migrated or new Skill is owned by exactly one intended plugin
```

<!-- acceptance-case: AC-02 -->
### AC-02 — A candidate researches a target and receives only a supported targeted resume

```gherkin
Scenario: Build one person's company-role application
  Given supported personal evidence and current sourced information for a target company and role
  When the candidate research, matching, and resume Skills are invoked
  Then they keep personal, company, role, match, and resume facts in their canonical scopes and the resume contains no unsupported or target-free claims
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Missing target requirements block final resume writing

```gherkin
Scenario: Request final resume copy without a company-role target
  Given supported candidate evidence but only generic, role-only, or company-unattributed requirements
  When final resume copy is requested
  Then `write-resume` requests or routes to company-role research and emits no resume artifact
```

<!-- acceptance-case: AC-04 -->
### AC-04 — Hiring records remain candidate- and application-scoped

```gherkin
Scenario: Organize candidates who may apply to more than one role
  Given one company with multiple roles and candidate resumes
  When hiring workspace, assessment, and interview-design Skills are invoked
  Then each candidate has one canonical company-scoped record and each assessment or interview plan belongs to one explicit role application without cross-candidate leakage
```

<!-- acceptance-case: AC-05 -->
### AC-05 — Hiring assessment preserves privacy, source integrity, and human decision ownership

```gherkin
Scenario: Assess and prepare an interview from supplied candidate evidence
  Given an immutable supplied resume containing job-related evidence and a protected-trait detail
  When hiring assessment and interview-design Skills are invoked for one explicit application
  Then they exclude the protected trait, do not mutate the resume or personal profile, and emit no final hiring verdict
```

<!-- acceptance-case: AC-06 -->
### AC-06 — Breaking entry points have explicit migration guidance

```gherkin
Scenario: Find a removed Skill after upgrading
  Given a user knows the former `design-interview` or `interview-career-project` capability
  When they read the marketplace and repository guidance
  Then the replacement plugin or Skill name is explicit and no duplicate deprecated Skill competes for automatic routing
```

## Constraints and risks

- Governing decision: [`ADR-001`](../../adr/ADR-001-separate-candidate-and-hiring-plugins.md) requires
  independent candidate and hiring plugins, direct-child Skills, no mandatory cross-plugin runtime
  dependency, and no automatic persisted-data migration.
- Both root marketplace manifests must expose an identical plugin set; each plugin's Codex and
  Claude manifests must agree on name, version, description, and Skill root. Career uses `0.4.0`
  and hiring uses `0.1.0`.
- Current public company and job information is time-sensitive. Research outputs must identify the
  source, retrieval date, confidence, inference, contradiction, and unknown state; lack of public
  evidence must not become an invented company or role claim.
- Hiring workspaces contain third-party personal data. Reads and writes must be explicitly bounded
  to the selected company, candidate, role, and application, with sensitive values minimized and
  protected traits excluded from assessment.
- Breaking entry-point changes are deliberate. Recovery before release is a repository revert;
  after release users can install the preceding `tedtoolkit-career` version while their data remains
  unchanged.
- Escalation triggers: a required cross-plugin dependency, automatic user-data migration, external
  write or contact operation, non-Markdown persisted database, final automated hiring verdict, or
  another public entry-point removal not listed above requires renewed approval.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

`plan-work-items` will create a separately approved map because candidate plugin evolution, hiring
plugin introduction, and integrated marketplace/migration verification are independently verifiable
delivery boundaries that must converge atomically before release.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=structural shape=component -->
<!-- primary-proof: AC-02 purpose=acceptance shape=end-to-end -->
<!-- primary-proof: AC-03 purpose=regression shape=end-to-end -->
<!-- primary-proof: AC-04 purpose=acceptance shape=end-to-end -->
<!-- primary-proof: AC-05 purpose=boundary shape=end-to-end -->
<!-- primary-proof: AC-06 purpose=structural shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Marketplace, manifest, Skill metadata, and sole-ownership contracts pass. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development skill-contract-release-gate --tier static` |
| AC-02 | Primary | Candidate research, normalized target, evidence matching, and targeted resume scenario passes without unsupported claims. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-career --tier smoke` |
| AC-03 | Primary | A target-free final-copy request produces no resume and routes to missing target evidence. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-career write-resume --tier full` |
| AC-04 | Primary | Hiring workspace, assessment, and interview-plan scenarios preserve candidate and application isolation. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-hiring --tier smoke` |
| AC-05 | Primary | Hiring evals exclude protected traits, preserve supplied resume/profile bytes, and emit no final hiring verdict. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-hiring --tier full` |
| AC-06 | Primary | The extended release gate fails when an old Skill path remains, replacement guidance is absent, or any Skill name has multiple plugin owners. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development skill-contract-release-gate --tier static` |
| Affected eval harness | Conditional | Harness self-tests still pass after a sixth marketplace plugin and test group are introduced. | `py -3.10 tests/test_run_evals.py` |

<!-- section: completion-criteria -->
## Completion

Complete when AC-01 through AC-06 pass on one exact candidate; both marketplaces and plugin
manifests are synchronized; candidate and hiring integrity/schema references are authoritative and
self-contained; all renamed or moved Skill routes and tests use their new owner; README and
`CLAUDE.md` describe six plugins and the breaking migration; existing user data is untouched; and
the accepted ADR remains the durable boundary record. After final review and explicit closure, the
temporary change record follows the repository cleanup lifecycle rather than becoming an archive.
