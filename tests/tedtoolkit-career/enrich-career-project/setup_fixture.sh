#!/usr/bin/env bash
set -euo pipefail

mkdir -p career-profiles/sam/work/northwind career-profiles/sam/work/contoso career-profiles/sam/private

cat > career-profiles/sam/work/northwind/2024-01--present-order-orchestration.md <<'EOF'
---
id: work-northwind-order-orchestration-2024
kind: work
record_type: project
start: 2024-01
end: present
role: Backend Engineer
engagement: employment
support: candidate-asserted
updated: 2026-09-01
---

# Order Orchestration

## Context and Objective

- Built an internal order-orchestration service.

## Role and Responsibility Boundaries

- Personally implemented the scheduling workflow.

## Technologies

- C# and PostgreSQL.

## To Confirm

- Where and when was the service delivered, and who used it?
- What constraints or trade-offs shaped the implementation?
EOF

cat > career-profiles/sam/work/contoso/2023-01--2023-12-inventory-dashboard.md <<'EOF'
---
id: work-contoso-inventory-dashboard-2023
kind: work
record_type: project
start: 2023-01
end: 2023-12
support: candidate-asserted
updated: 2026-09-01
---

# Inventory Dashboard

- UNSELECTED-RECORD-MARKER: preserve this record byte for byte.
EOF

cat > career-profiles/sam/private/contact.md <<'EOF'
# Contact

- Email: sam.private@example.test
EOF

sha256sum career-profiles/sam/work/northwind/2024-01--present-order-orchestration.md | cut -d' ' -f1 > target.sha256
sha256sum career-profiles/sam/work/contoso/2023-01--2023-12-inventory-dashboard.md | cut -d' ' -f1 > unselected.sha256
sha256sum career-profiles/sam/private/contact.md | cut -d' ' -f1 > contact.sha256

rm -f setup_fixture.sh
