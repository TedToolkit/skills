<!-- delivery-map -->
## Delivery map

This file is the only mutable work-item status source for the approved change.

<!-- approval-source: User approved the complete CH-001 through CH-003 map and requested continuation in the Codex conversation on 2026-09-15. -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Status | Document |
| --- | --- | --- | --- | --- | --- |
| CH-001 | Candidate plugin provides one-person research, matching, targeted resume, review, and preparation workflows. | Owns AC-02; Owns AC-03; Supports AC-01; Supports AC-06 | None | Verified | `work-items/CH-001-candidate-plugin.md` |
| CH-002 | Hiring plugin provides company-scoped candidate organization, assessment, and interviewer-design workflows. | Owns AC-04; Owns AC-05; Supports AC-01; Supports AC-06 | None | Verified | `work-items/CH-002-hiring-plugin.md` |
| CH-003 | Marketplace, migration guidance, and release validation expose the two verified plugins atomically. | Owns AC-01; Owns AC-06 | `CH-001`: verified candidate plugin and replacement entry points; `CH-002`: verified hiring plugin and migrated interviewer entry point | Implemented | `work-items/CH-003-integrated-release.md` |

CH-001 and CH-002 are Verified on the current integration revision using their candidate-bound
offline proof and independent reviews under the user-approved temporary verification exception in
`change.md`. The attempted representative model smoke scenarios were environment-blocked by the
missing `codex-code-mode-host.exe` and are not recorded as behavioral passes.
