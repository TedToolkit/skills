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

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
