#!/usr/bin/env bash
set -euo pipefail

mkdir -p career-workspace/work/northwind

cat > career-workspace/profile.md <<'EOF'
# Lin Chen
EOF

cat > career-workspace/work/northwind/2022-01--present-inventory-api.md <<'EOF'
---
id: work-northwind-inventory-api-2022
kind: work
record_type: project
start: 2022-01
end: present
role: Backend Engineer
engagement: employment
support: candidate-asserted
updated: 2026-09-15
---

# Inventory API

## Role and Responsibility Boundaries

- Lin Chen personally built and maintains a C# inventory API and its SQL schema.

## Deliverables and Outcomes

- The internal warehouse team uses the API.

## To Confirm

- No performance, scale, percentage, or Kubernetes experience was supplied.
EOF

cat > supplied-company.md <<'EOF'
# Acme Robotics official company snapshot

- URL: https://acme.example/about
- Retrieved: 2026-09-12
- Acme Robotics builds warehouse picking robots for logistics operators.
- Its public engineering stack and customer count are unknown.
EOF

cat > supplied-role.md <<'EOF'
# Acme Robotics — Backend Engineer official posting snapshot

- URL: https://acme.example/careers/backend-engineer
- Retrieved: 2026-09-12
- Required: C# API development and SQL schema maintenance.
- Preferred: Kubernetes.
- Responsibility: build services supporting warehouse robotics operations.
- No performance metric, scale claim, or posting close date is stated.
EOF

sha256sum career-workspace/profile.md | cut -d' ' -f1 > profile.sha256
sha256sum career-workspace/work/northwind/2022-01--present-inventory-api.md | cut -d' ' -f1 > work.sha256
sha256sum supplied-company.md | cut -d' ' -f1 > company-source.sha256
sha256sum supplied-role.md | cut -d' ' -f1 > role-source.sha256

rm -f setup_fixture.sh
