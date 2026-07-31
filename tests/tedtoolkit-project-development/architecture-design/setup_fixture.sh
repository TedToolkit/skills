#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > README.md <<'EOF'
# Sample service

The service must persist small configuration records. The team operates .NET applications and
requires an embedded database with no separately managed server.
EOF

mkdir -p docs/changes/temporary-configuration-store
cat > docs/changes/temporary-configuration-store/README.md <<'EOF'
# Temporary configuration-store delivery design

Tracking marker: TRANSIENT-CONFIG-CHANGE

This short-lived file will be deleted after delivery. Durable architecture records and ADRs must
not link to it, cite it, name it, or depend on it.
EOF

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
