#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > README.md <<'EOF'
# Sample service
EOF

cat > Sample.slnx <<'EOF'
<Solution>
</Solution>
EOF

git add -A
git commit -qm "fixture"
rm -f setup_benchmark_fixture.sh
