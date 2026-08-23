#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  standard-change|standard-change-execute)
    mkdir -p docs/changes/temperature-clamp
    cat > docs/changes/temperature-clamp/change.md <<'EOF'
# Preserve in-range temperatures

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: bug-fix -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->

<!-- approval-source: Fixture owner -->

<!-- section: goal-rationale -->
## Goal and rationale

Callers retain the exact value when normalizing a temperature already inside the valid range.

<!-- section: scope -->
## Scope and non-goals

Change normalization of in-range values only; preserve the public API and out-of-range clamping.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
- Current: `Normalize` rounds in-range decimal values.
- Expected: in-range decimal values remain unchanged.
- Preserved: out-of-range values are still clamped to the valid range.

<!-- acceptance-case: AC-01 -->
### AC-01 — Preserve an in-range decimal value

```gherkin
Scenario: Preserve an in-range decimal value
  Given a temperature of 12.25 Celsius
  When a caller normalizes it
  Then the result remains 12.25 Celsius
```

<!-- section: delivery-brief -->
## Delivery brief

- Likely touchpoints: `Temperature.cs` and the focused Temperature tests; these are non-binding.
- Constraint: do not change the public API or out-of-range clamping behavior.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=regression shape=unit -->
| Contract | Role | Evidence purpose | Execution shape | Observable assertion | Command |
| --- | --- | --- | --- | --- | --- |
| AC-01 | Primary | Regression | Unit | `Normalize` preserves 12.25 Celsius | Repository test command |

<!-- section: completion-criteria -->
## Completion

AC-01 passes and existing out-of-range normalization tests remain green.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public Temperature Normalize() => new(Clamp(Celsius));

    private static decimal Clamp(decimal value) =>
        decimal.Round(decimal.Clamp(value, -273.15m, 1000m));
}
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
    if [[ "$scenario" == "standard-change-execute" ]]; then
      mkdir -p .binstub
      cat > CLAUDE.md <<'EOF'
# Repository guidance

Use `dotnet test Weather.Tests.csproj -c Release` for the focused primary and regression proof.
EOF
      cat > .binstub/dotnet <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> .dotnet-calls
test -f Temperature.cs || {
  echo "AC-01 verification failed: Temperature.cs was deleted" >&2
  exit 1
}
grep -Fq 'public readonly record struct Temperature(decimal Celsius)' Temperature.cs || {
  echo "AC-01 verification failed: the public Temperature API changed" >&2
  exit 1
}
grep -Fq 'Clamp(Celsius)' Temperature.cs || {
  echo "AC-01 verification failed: Normalize no longer uses the preserved clamp boundary" >&2
  exit 1
}
grep -Fq 'decimal.Clamp(value, -273.15m, 1000m)' Temperature.cs || {
  echo "AC-01 verification failed: out-of-range clamping changed" >&2
  exit 1
}
if grep -Fq 'decimal.Round(decimal.Clamp(value, -273.15m, 1000m))' Temperature.cs; then
  echo "AC-01 still fails: Normalize rounds the in-range value" >&2
  exit 1
fi
grep -Fq '12.25' TemperatureTests.cs || {
  echo "AC-01 primary proof is missing the approved example" >&2
  exit 1
}
echo "1 discovered, 1 passed, 0 failed, 0 skipped"
EOF
      chmod +x .binstub/dotnet
    fi
    ;;
  structural-maintenance)
    mkdir -p docs/changes/readme-spelling
    cat > docs/changes/readme-spelling/change.md <<'EOF'
# Correct reader-facing spelling

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: maintenance -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->

<!-- section: goal-rationale -->
## Goal and rationale

Readers see the correctly spelled public guide without any production behavior change.

<!-- section: scope -->
## Scope and non-goals

Correct the one documented spelling error. Do not change code, APIs, examples, or build behavior.

<!-- section: structural-contract -->
## Structural outcome

<!-- structural-outcome: STR-01 -->
- STR-01: `Guide.md` contains "the parser" and no longer contains "teh parser"; all other lines remain unchanged.

<!-- section: delivery-brief -->
## Delivery brief

Edit `Guide.md` only and leave the exact implementation of the wording correction open.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: STR-01 purpose=structural shape=manual -->
| Contract | Role | Purpose | Shape | Assertion | Command |
| --- | --- | --- | --- | --- | --- |
| STR-01 | Primary | Structural | Manual | Correct phrase exists and typo is absent | `bash verify-docs.sh` |

<!-- section: completion-criteria -->
## Completion

The bounded documentation check passes with no code or test changes.
EOF
    cat > Guide.md <<'EOF'
# Parser Guide

Use teh parser through its public Parse method.
EOF
    cat > verify-docs.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
grep -Fq 'Use the parser through its public Parse method.' Guide.md
! grep -Fq 'teh parser' Guide.md
EOF
    chmod +x verify-docs.sh
    ;;
  unapproved-design)
    mkdir -p docs/changes/P2-temperature-parse
    cat > docs/changes/P2-temperature-parse/change.md <<'EOF'
# Temperature parsing

## Status

Draft

## Acceptance criteria

`Temperature.TryParse` accepts Celsius decimal input and rejects invalid values.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    ;;
  change-index)
    mkdir -p docs/changes/P2-geometry-rebuild
    cat > docs/changes/P2-geometry-rebuild/change.md <<'EOF'
# Geometry rebuild

## Status

Approved

| ID | Work package | Status |
| --- | --- | --- |
| GEOM-001 | Equality model | Planned |
| GEOM-002 | Bounds rename | Planned |
EOF
    ;;
  implementation-freedom)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

<!-- change-format: 2 -->

## Status

Approved

## Change goal

Callers can parse invariant Celsius text without accepting invalid values.

## Rationale traceability

| ID | Design claim | Why it is necessary | Evidence, governing record, or decision ID | Status |
| --- | --- | --- | --- | --- |
| R-01 | Safe parsing | Prevent inconsistent domain values. | Approved request | Resolved |

## Observable behavior change

| ID | Observable boundary | Current behavior | Expected behavior | Must remain unchanged | Rationale ID |
| --- | --- | --- | --- | --- | --- |
| OB-01 | Public temperature parsing | No shared parser exists. | Valid invariant input parses and invalid input is rejected. | Existing constructor behavior. | R-01 |

## Acceptance specification

<!-- acceptance-case: AC-01 -->
### AC-01 — Parse valid invariant Celsius

- Type: Success
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Parse valid invariant Celsius
  Given the text "12.5"
  When a caller attempts to parse it as Celsius
  Then parsing succeeds with a 12.5 Celsius value
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Reject invalid Celsius

- Type: Failure
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Reject invalid Celsius
  Given invalid Celsius text
  When a caller attempts to parse it
  Then parsing fails without producing a value
```

## Completion criteria

AC-01 and AC-02 pass while existing construction behavior remains compatible.

<!-- delivery-map -->
## Delivery map

| ID | Work item | Outcome | Acceptance ownership | Priority and rationale | Estimate | Logical prerequisites and supplied input | Item-owned verification gates | Status | Document |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TEMP-001 | Parse Celsius text | Callers can parse valid input and reject invalid input. | Owns AC-01 / Owns AC-02 | P1 — public API | 0.1–0.2 person-months | None | AC-01 and AC-02 Acceptance; focused Unit; regression | Approved | `work-items/TEMP-001-parse.md` |
EOF
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md <<'EOF'
# TEMP-001: Parse Celsius text

## Status

Approved

<!-- work-item: scope -->
## Outcome, scope, and non-goals

| Expected affected area or exact public contract | Authorized outcome | Explicit non-goal |
| --- | --- | --- |
| Public temperature parsing API and its tests | Add invariant parsing behavior. | No formatting API. |

<!-- work-item: start-conditions -->
## Start conditions and blockers

| Start condition or blocker | Evidence or owner | Effect if unmet |
| --- | --- | --- |
| None | Approved parent change | Ready to start. |

<!-- work-item: acceptance-coverage -->
## Acceptance coverage

| Acceptance case | Source | Responsibility | Acceptance proof intent |
| --- | --- | --- | --- |
| AC-01 | `../change.md`, AC-01 | Owns | Prove valid input through the public API. |
| AC-02 | `../change.md`, AC-02 | Owns | Prove invalid input is rejected through the public API. |

<!-- work-item: integration-boundaries -->
## Required integration boundaries

| Boundary | Risk being protected | Required evidence |
| --- | --- | --- |
| None | No real external component boundary is involved. | Not applicable. |

<!-- work-item: delivery-constraints -->
## Delivery constraints

| Observable boundary or governing constraint | Required result | Compatibility or invariant |
| --- | --- | --- |
| Public parsing API | Invariant decimal parsing with non-throwing failure. | Existing constructor remains unchanged. |

<!-- work-item: verification-plan -->
## Acceptance proof and verification gates

| Acceptance case or gate | Level | Observable assertion | Stable command or bounded manual procedure, if known |
| --- | --- | --- | --- |
| AC-01 | Acceptance | Valid input produces the expected public value. | Repository test command. |
| AC-02 | Acceptance | Invalid input returns false. | Repository test command. |
| Focused parsing logic | Unit | Valid and invalid branches are deterministic. | Repository test command. |
| Work-item regression | Regression gate | Existing construction behavior remains green. | Repository test command. |

<!-- work-item: definition-of-done -->
## Definition of done

| Criterion | Required evidence |
| --- | --- |
| AC-01 and AC-02 pass. | Acceptance and focused Unit results. |

<!-- work-item: completion-evidence -->
## Completion evidence

Pending implementation.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > Weather.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
</Project>
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
