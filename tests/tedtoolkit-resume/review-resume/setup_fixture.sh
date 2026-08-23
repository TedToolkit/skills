#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
git config commit.gpgsign false

cat > candidate-resume.md <<'EOF'
# Priya Rao

Phone: +86 138-1234-5678 | Email: priya.private@example.com

## Summary

Expert engineer responsible for many high-performance systems.
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
