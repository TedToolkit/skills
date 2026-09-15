#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  multi-role)
    mkdir -p source-resumes
    cat > source-resumes/avery.md <<'EOF'
# Synthetic Resume — Avery

- Nationality: Exampleland
- Personally operated Docker-based CI for two years.
- Led two production incident reviews with a platform team.
EOF
    cat > source-resumes/blake.md <<'EOF'
# Synthetic Resume — Blake

- Religion: Example Faith
- Personally delivered a SQL ingestion pipeline.
- Maintained batch data quality checks.
EOF
    sha256sum source-resumes/avery.md > avery-source.sha256
    sha256sum source-resumes/blake.md > blake-source.sha256
    ;;
  existing-resume)
    mkdir -p source-resumes hiring-workspace/companies/northwind/candidates/avery/resumes
    cat > source-resumes/avery-new.md <<'EOF'
# Synthetic Resume — Avery, revised

- Added Kubernetes operations evidence.
EOF
    cat > hiring-workspace/companies/northwind/candidates/avery/resumes/2026-09-15-resume.md <<'EOF'
# Existing Normalized Resume

- Preserve this exact record.
EOF
    sha256sum source-resumes/avery-new.md > source.sha256
    sha256sum hiring-workspace/companies/northwind/candidates/avery/resumes/2026-09-15-resume.md > destination.sha256
    ;;
  *)
    echo "unknown fixture" >&2
    exit 2
    ;;
esac
