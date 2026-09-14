#!/usr/bin/env bash
set -euo pipefail

mkdir -p career-profiles/sam/work/northwind career-profiles/sam/private

cat > career-profiles/sam/profile.md <<'EOF'
# Sam Lee

- Preferred name: Sam Lee
EOF

cat > career-profiles/sam/work/northwind/2020-01--2022-06-order-api.md <<'EOF'
---
id: work-northwind-order-api-2020
kind: work
record_type: project
start: 2020-01
end: 2022-06
organization: Northwind
role: Software Engineer
engagement: employment
support: candidate-asserted
updated: 2026-09-14
---

# Northwind — Software Engineer

## Facts

- Built C# APIs.
EOF

cat > career-profiles/sam/private/contact.md <<'EOF'
# Contact

- Email: sam@example.test
EOF

sha256sum career-profiles/sam/private/contact.md | cut -d' ' -f1 > contact.sha256
