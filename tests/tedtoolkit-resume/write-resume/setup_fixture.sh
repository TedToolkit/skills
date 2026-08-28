#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
git config commit.gpgsign false

cat > candidate-notes.md <<'EOF'
# Candidate notes

- Name: Lin Chen
- Target: backend engineer
- Built a C# inventory API.
- Maintained its SQL schema.
- Supported the internal warehouse team.
- No metrics, dates, title, employer, or contact details supplied.
EOF

cat > .gitignore <<'EOF'
setup_fixture.sh
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"

if [[ "${1:-}" == "existing" ]]; then
  printf '# Existing resume\n\nDo not replace me.\n' > resume.md
  sha256sum resume.md | cut -d' ' -f1 > resume.sha256
  git add resume.md resume.sha256
  git commit -qm "existing resume"
fi
