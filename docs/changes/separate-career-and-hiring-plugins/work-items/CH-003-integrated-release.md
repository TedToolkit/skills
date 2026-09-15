# CH-003: Integrate the persona plugins into one validated marketplace release

<!-- work-item-format: 2 -->
<!-- work-item-id: CH-003 -->

<!-- approval-source: User approved the complete CH-001 through CH-003 map and requested continuation in the Codex conversation on 2026-09-15. -->

## Outcome

Both verified persona plugins are exposed consistently by the Codex and Claude marketplaces, and
repository guidance plus release validation makes the breaking Skill replacements discoverable and
prevents duplicate cross-plugin Skill ownership.

<!-- work-item: scope -->
## Scope and non-goals

- Target delivery area or exact public/persisted contract: root marketplace contract, repository
  orientation and migration guidance, and cross-plugin release validation.
- In scope:
  - add `tedtoolkit-hiring` to both marketplace manifests;
  - update the repository plugin count, capability descriptions, and breaking replacement guidance;
  - extend the release gate to reject duplicate Skill names across plugins, retained obsolete paths,
    or missing replacement guidance;
  - run integrated static and harness verification against the verified plugin outputs.
- Non-goals: changing candidate or hiring Skill behavior, altering their persisted schemas,
  redesigning the eval harness, publishing the marketplace, or migrating user workspaces.
- Likely touchpoints (non-binding): root marketplace manifests, `README.md`, `CLAUDE.md`, and the
  existing Skill release-contract checker and tests.

<!-- work-item: start-conditions -->
## Start conditions

| Prerequisite or blocker | Concrete input or guarantee | Evidence |
| --- | --- | --- |
| CH-001 | Verified `tedtoolkit-career` `0.4.0`, candidate entry points, and absent obsolete career Skill paths. | CH-001 status is `Verified` on the selected integration revision. |
| CH-002 | Verified `tedtoolkit-hiring` `0.1.0` and sole migrated `design-interview` entry point. | CH-002 status is `Verified` on the selected integration revision. |

<!-- work-item: contract-coverage -->
## Contract responsibility

| Parent contract | Responsibility | Contribution or supplied input |
| --- | --- | --- |
| AC-01 | Owns | Identical marketplace exposure, paired manifests, independent installability, and sole Skill ownership. |
| AC-06 | Owns | Executable validation of removed paths, replacement guidance, and global unique Skill names. |

<!-- work-item: delivery-constraints -->
## Constraints

- Both marketplace manifests declare the same six plugins and exact local source paths.
- Release validation uses repository structure and explicit migration contracts, not heuristic Skill
  content matching.
- Removed public entries are `tedtoolkit-career/design-interview` and
  `tedtoolkit-career/interview-career-project`; replacements are
  `tedtoolkit-hiring/design-interview` and `tedtoolkit-career/enrich-career-project`.
- The release checker must fail on any duplicate Skill frontmatter name across marketplace plugins.
- Integration changes do not revise approved candidate or hiring behavior and do not touch user data.
- Private choices deliberately left to the implementer: exact checker function decomposition and
  concise placement of migration wording in existing repository orientation documents.

<!-- work-item: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=structural shape=component -->
<!-- primary-proof: AC-06 purpose=structural shape=component -->
| Contract or gate | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Marketplace equality, plugin directories, paired versions, Skill metadata, links, and global sole ownership all pass. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development skill-contract-release-gate --tier static` |
| AC-06 | Primary | Checker mutation tests fail for either obsolete path, missing replacement guidance, or duplicate Skill ownership, then pass on the release candidate. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development skill-contract-release-gate --tier static` |
| Eval harness regression | Conditional | The harness still discovers and groups the sixth plugin without changing established behavior. | `py -3.10 tests/test_run_evals.py` |

<!-- work-item: definition-of-done -->
## Done

- AC-01 and AC-06 have passing primary proof on the integrated candidate.
- Both marketplaces expose the same six independently valid plugins, repository guidance names the
  breaking replacements, and mutation tests prove the new release checks fail closed.
- CH-001 and CH-002 verified outputs are present unchanged on the integration revision; no user data
  or external marketplace is modified.

<!-- work-item: completion-evidence -->
## Verification result requirements

Record the integrated candidate revision, actual changed artifacts, CH-001 and CH-002 verified input
bindings, AC-01 and AC-06 proof purpose and component shape, exact commands, unittest counts,
discovered/passed/failed/skipped eval counts, and confirmation that no publication or user-data
operation occurred.

## Risks and implementation notes

The static release checker evaluates the Git-tracked tree, so final proof must bind a frozen tracked
candidate rather than relying only on untracked workspace files.
