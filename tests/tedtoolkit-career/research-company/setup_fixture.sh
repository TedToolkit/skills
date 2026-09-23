#!/usr/bin/env bash
set -euo pipefail

mkdir -p career-workspace
cat > career-workspace/profile.md <<'EOF'
# Lin Chen

- Candidate fact marker: preserve exactly.
EOF

cat > official-company.md <<'EOF'
# Acme Robotics official company snapshot

- URL: https://acme.example/about
- Retrieved: 2026-09-10
- Acme Robotics states that it builds warehouse picking robots for logistics operators worldwide.
- The company says product development is organized into hardware, autonomy, and fleet-software
  groups. Customer-deployment squads draw members from all three groups and report delivery status
  to a program lead while professional development remains with each functional manager.
- The page does not identify its engineering stack, team sizes, performance-review process, or
  decision authority below group leadership.
EOF

cat > trade-report.md <<'EOF'
# Trade publication snapshot

- URL: https://trade.example/acme-profile
- Retrieved: 2026-09-10
- The publication reports that Acme Robotics currently serves customers in East Asia.
- It does not verify the company's worldwide-customer statement.
EOF

cat > compensation-snapshot.md <<'EOF'
# Acme Robotics compensation snapshot

- URL: https://jobs.example/acme-shanghai-software-engineer
- Retrieved: 2026-09-10
- One Shanghai software-engineer posting lists base pay of CNY 30,000-42,000 per month, a
  performance bonus with no published target, and supplemental medical insurance.
- The source does not state equity eligibility, other levels' ranges, or pay outside Shanghai.
EOF

cat > employee-reviews.md <<'EOF'
# Acme Robotics employee-review snapshot

- URL: https://reviews.example/acme-robotics
- Retrieved: 2026-09-10
- This is a self-selected sample of 12 anonymous reviews posted from 2025-01 through 2026-08.
- Seven reviews associated with East Asia engineering praise cross-discipline learning; four of
  those seven also describe shifting delivery priorities and long hours near deployments.
- Three reviews from other functions describe managers as accessible, while two reviews do not
  agree and describe decisions as insufficiently explained.
- Reviewer employment, identity, and representativeness are not independently verified.
EOF

sha256sum career-workspace/profile.md | cut -d' ' -f1 > profile.sha256
rm -f setup_fixture.sh
