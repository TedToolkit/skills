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
    cat > expected-files.txt <<'EOF'
hiring-workspace/companies/northwind/applications/data/avery/application.md
hiring-workspace/companies/northwind/applications/data/blake/application.md
hiring-workspace/companies/northwind/applications/platform/avery/application.md
hiring-workspace/companies/northwind/candidates/avery/candidate.md
hiring-workspace/companies/northwind/candidates/avery/resumes/2026-09-15-resume.md
hiring-workspace/companies/northwind/candidates/blake/candidate.md
hiring-workspace/companies/northwind/candidates/blake/resumes/2026-09-15-resume.md
hiring-workspace/companies/northwind/company.md
hiring-workspace/companies/northwind/roles/data/role.md
hiring-workspace/companies/northwind/roles/platform/role.md
source-resumes/avery.md
source-resumes/blake.md
EOF
    find source-resumes -type f -print | sort | xargs sha256sum > all-fixtures.sha256
    {
      sed 's#^#./#' expected-files.txt
      printf '%s\n' ./all-fixtures.sha256 ./avery-source.sha256 ./blake-source.sha256 \
        ./expected-files.txt ./setup_fixture.sh
    } | sort > expected-all-files.txt
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
    cat > expected-files.txt <<'EOF'
hiring-workspace/companies/northwind/candidates/avery/resumes/2026-09-15-resume.md
source-resumes/avery-new.md
EOF
    find hiring-workspace source-resumes -type f -print | sort | xargs sha256sum > all-fixtures.sha256
    {
      sed 's#^#./#' expected-files.txt
      printf '%s\n' ./all-fixtures.sha256 ./destination.sha256 ./expected-files.txt \
        ./setup_fixture.sh ./source.sha256
    } | sort > expected-all-files.txt
    ;;
  *)
    echo "unknown fixture" >&2
    exit 2
    ;;
esac
