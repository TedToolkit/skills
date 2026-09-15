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
- Location: Shanghai hybrid.
- Posting close date: not stated.
EOF

sha256sum career-workspace/profile.md | cut -d' ' -f1 > profile.sha256
sha256sum career-workspace/companies/acme-robotics/company.md | cut -d' ' -f1 > company.sha256
rm -f setup_fixture.sh
