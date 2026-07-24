#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
mkdir -p docs/changes/P1-temperature-parse

case "$scenario" in
  incomplete-design)
    cat > docs/changes/P1-temperature-parse/README.md <<'EOF'
# Temperature parsing

## Change goal

Add `TryParse`.

## Scope

Add parsing support.
EOF
    ;;
  approval-ready-design)
    cat > docs/changes/P1-temperature-parse/README.md <<'EOF'
# Temperature parsing

## Status

Draft

## Change goal

Callers can safely convert invariant-culture Celsius text into a temperature value.

## Scope and non-goals

Add parsing for Celsius text. Formatting and Fahrenheit input are not part of this change.

## Compatibility and status quo

The existing value type has no text parsing API; the new API is additive.

## BehaviorCases

| ID | Observable behavior |
| --- | --- |
| BC-01 | Valid invariant-culture decimal Celsius input returns a value. |
| BC-02 | Null, whitespace, invalid text, and values below absolute zero are rejected. |

## Governing constraints

No governing records apply.

## Approach and alternatives

Add one parsing API on the value type. A separate parser type is rejected because no additional policy is needed.

## Risks and rollback

The additive API has no migration; rollback removes the new API before release.

## Completion criteria

Both BehaviorCases have focused observable tests.

## Estimate

0.01–0.02 person-months; medium confidence; assumes no public-format compatibility requirement; re-estimate if parsing requires localization.
EOF
    ;;
  missing-accepted-adr)
    cat > docs/changes/P1-temperature-parse/README.md <<'EOF'
# Temperature parsing

## Change goal

Callers can safely convert invariant-culture Celsius text into a temperature value.

## Scope and non-goals

Add parsing for Celsius text. Formatting and Fahrenheit input are not part of this change.

## BehaviorCases

| ID | Observable behavior |
| --- | --- |
| BC-01 | Valid invariant-culture decimal Celsius input returns a value. |
| BC-02 | Null, whitespace, invalid text, and values below absolute zero are rejected. |

## Durable technical decision

All public library parsing APIs will use invariant culture rather than caller culture.

## Completion criteria

Both BehaviorCases have focused observable tests.

## Estimate

0.01–0.02 person-months; medium confidence; no migration; re-estimate if parsing requires localization.
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
