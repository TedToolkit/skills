#!/usr/bin/env bash
set -euo pipefail

mkdir -p career-workspace/companies/acme-robotics
cat > career-workspace/profile.md <<'EOF'
# Lin Chen

- Candidate fact marker: preserve exactly.
EOF

cat > career-workspace/companies/acme-robotics/company.md <<'EOF'
# Acme Robotics

- Company fact marker: preserve exactly.
EOF

cat > supplied-job-posting.md <<'EOF'
# Acme Robotics — Backend Engineer

- URL: https://acme.example/careers/backend-engineer
- Retrieved: 2026-09-12
- Required: C#, SQL, and experience operating production APIs.
- Preferred: Kubernetes.
- Responsibility: build services that coordinate warehouse robots.
- Recurring work: design and review C# API changes, release every two weeks, and participate in a
  one-in-six production incident rotation after onboarding.
- Collaboration: work with robotics-controls engineers and site-reliability engineers; the posting
  does not state the reporting line or final decision authority.
- Success measures: robot-command delivery reliability and production restoration time.
- First 90 days: independently deliver one API change through production and complete one
  supervised incident rotation.
- Location: Shanghai hybrid.
- The posting does not state the number of required office days, performance-review process, or
  promotion criteria.
- Posting close date: not stated.
EOF

cat > supplied-recent-context.md <<'EOF'
# Acme Robotics engineering update

- URL: https://acme.example/engineering/warehouse-platform-update
- Published: 2026-09-08
- Retrieved: 2026-09-12
- The warehouse coordination platform is beginning a migration from batch polling to event-driven
  robot telemetry.
- The engineering organization is piloting AI-assisted incident triage, while human engineers
  remain responsible for production decisions.
- Limitation: this is a company-wide engineering update, not part of the Backend Engineer posting.
EOF

cat > supplied-interview-reports.md <<'EOF'
# Public interview reports for Acme Robotics Backend Engineer

- Source URL: https://interviews.example/acme-robotics/backend-engineer-shanghai-2026
- Reported: 2026-08-20
- Retrieved: 2026-09-12
- Scope: one candidate report for a Shanghai Backend Engineer process; current recurrence is unknown.
- Interview question: design an idempotent robot-command API and explain retry behavior.
- Interview question: diagnose a SQL query that becomes slow as telemetry volume grows.
- Written assessment: reason about a deadlock from two transactions acquiring locks in different orders.

- Source URL: https://jobs.example/reports/acme-backend-2025
- Reported: 2025-11-03
- Retrieved: 2026-09-12
- Scope: one candidate report for an unspecified Acme Robotics backend team and location.
- Interview question: optimize a slow SQL query over warehouse events.
- Limitation: the SQL item is a near-duplicate of the 2026 report, and the process may be stale.

- Inference input only: the posting's production API responsibility makes incident diagnosis a
  relevant preparation topic, but neither report states that an incident-diagnosis question was
  asked.
EOF

sha256sum career-workspace/profile.md | cut -d' ' -f1 > profile.sha256
sha256sum career-workspace/companies/acme-robotics/company.md | cut -d' ' -f1 > company.sha256
rm -f setup_fixture.sh
