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
- The page does not identify its engineering stack or team structure.
EOF

cat > trade-report.md <<'EOF'
# Trade publication snapshot

- URL: https://trade.example/acme-profile
- Retrieved: 2026-09-10
- The publication reports that Acme Robotics currently serves customers in East Asia.
- It does not verify the company's worldwide-customer statement.
EOF

sha256sum career-workspace/profile.md | cut -d' ' -f1 > profile.sha256
rm -f setup_fixture.sh
