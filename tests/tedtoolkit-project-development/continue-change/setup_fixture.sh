#!/usr/bin/env bash
set -euo pipefail

status=${1:?usage: setup_fixture.sh <draft|approved>}
case "$status" in
    draft) approval=none ;;
    approved) approval="Fixture owner" ;;
    *) echo "unknown status: $status" >&2; exit 1 ;;
esac

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
mkdir -p docs/changes/comment-cleanup

cat > Temperature.cs <<'EOF'
namespace Weather;

// Represnts an immutable Celsius temperature.
public readonly record struct Temperature(decimal Celsius);
EOF

cat > docs/changes/comment-cleanup/change.md <<EOF
# Correct the Temperature comment

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: maintenance -->
<!-- change-status: $status -->
<!-- delivery-shape: single -->
<!-- approval-source: $approval -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

The Temperature comment uses the correct spelling so readers are not distracted by a typo.

<!-- section: scope -->
## Scope and non-goals

Correct only the comment spelling. Production behavior and public signatures remain unchanged.

<!-- section: structural-contract -->
## Structural contract

<!-- structural-outcome: STR-01 -->
- STR-01: The Temperature comment contains `Represents` and no longer contains `Represnts`.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->
None.

<!-- section: delivery-brief -->
## Delivery brief

One bounded comment correction in `Temperature.cs`.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: STR-01 purpose=structural shape=manual -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| STR-01 | Primary | Correct spelling exists and typo is absent | `grep -Fq 'Represents' Temperature.cs && ! grep -Fq 'Represnts' Temperature.cs` |

<!-- section: completion-criteria -->
## Completion

STR-01 passes and no production behavior changes.
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
