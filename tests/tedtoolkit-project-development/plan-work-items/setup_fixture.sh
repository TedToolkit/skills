#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

if [[ ${1:-} == standard-single ]]; then
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

Callers retain the exact value when normalizing an in-range temperature.

<!-- section: scope -->
## Scope and non-goals

Change normalization of in-range values only; preserve the public API and out-of-range behavior.

<!-- section: behavior-contract -->
## Behavior contract

<!-- acceptance-case: AC-01 -->
- AC-01: normalization preserves an in-range decimal value exactly.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome: preserve in-range decimal values.
- Scope: Temperature normalization and its focused proof.
- Constraint: public API and out-of-range behavior remain unchanged.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
| Contract | Role | Evidence purpose | Execution shape | Observable assertion | Command |
| --- | --- | --- | --- | --- | --- |
| AC-01 | Primary | Acceptance | Unit | Preserve 12.25 Celsius | Repository test command |

<!-- section: completion-criteria -->
## Completion

The focused proof and affected regression pass.
EOF
    rm -f setup_fixture.sh
    git add -A
    git commit -qm "fixture"
    exit 0
fi

if [[ ${1:-} == controlled-multi ]]; then
    mkdir -p docs/changes/temperature-ingestion/work-items
    cat > docs/changes/temperature-ingestion/change.md <<'EOF'
# Parse temperature input consistently

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: multi-item -->

<!-- approval-source: Fixture owner -->

<!-- section: goal-rationale -->
## Goal and rationale

Ingestion callers accept valid invariant Celsius text and reject invalid or impossible values
through one public parsing contract.

<!-- section: scope -->
## Scope and non-goals

- In scope: public parsing behavior and the ingestion consumer boundary.
- Non-goal: formatting or unit conversion.
- Preserved: the existing constructor and binary compatibility.

<!-- section: behavior-contract -->
## Behavior contract

<!-- acceptance-case: AC-01 -->
### AC-01 — Public parsing

Valid invariant Celsius text parses; null, whitespace, invalid text, and values below absolute zero
are rejected without throwing.

<!-- acceptance-case: AC-02 -->
### AC-02 — Ingestion adoption

Ingestion uses the verified public parser and exposes the same accepted and rejected inputs.

## Constraints and risks

`TryParse(string?, out Temperature)` is public and existing constructor behavior remains compatible.

<!-- section: delivery-brief -->
## Delivery disposition

Two independently verifiable deliveries are necessary: the public parser and its ingestion consumer.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
<!-- primary-proof: AC-02 purpose=acceptance shape=component -->
| Contract | Role | Evidence purpose | Execution shape | Observable assertion | Command |
| --- | --- | --- | --- | --- | --- |
| AC-01 | Primary | Acceptance | Unit | Parser examples satisfy public behavior | Repository test command |
| AC-02 | Primary | Acceptance | Component | Ingestion examples reuse parser results | Repository test command |

<!-- section: completion-criteria -->
## Completion

Both acceptance contracts and affected regression proof pass.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > Ingestion.cs <<'EOF'
namespace Weather;

public static class Ingestion;
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
    : > docs/changes/temperature-ingestion/work-items/TEMP-001-parser.md
    : > docs/changes/temperature-ingestion/work-items/TEMP-002-ingestion.md
    rm -f setup_fixture.sh
    git add -A
    git commit -qm "fixture"
    exit 0
fi

if [[ ${1:-} == incomplete ]]; then
    mkdir -p docs/changes/P1-incomplete-change
    cat > docs/changes/P1-incomplete-change/change.md <<'EOF'
# Incomplete change

## Status

Draft
EOF
    rm -f setup_fixture.sh
    git add -A
    git commit -qm "fixture"
    exit 0
fi

mkdir -p docs/changes/P1-temperature-parse/work-items
cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

<!-- change-format: 2 -->

## Status

Approved

## Change goal

Callers can parse valid invariant Celsius text without accepting invalid or impossible values.

## Scope and non-goals

Add one non-throwing public parsing API. Do not add formatting or conversion APIs.

## Public contract

Add `public static bool TryParse(string? text, out Temperature result)`. It uses invariant decimal
syntax, returns `false` for invalid or impossible values, and leaves the existing constructor
unchanged.

## Rationale traceability

| ID | Design claim | Why it is necessary | Evidence, governing record, or decision ID | Status |
| --- | --- | --- | --- | --- |
| R-01 | Safe invariant parsing | Prevent inconsistent domain values. | Approved request | Resolved |

## Observable behavior change

| ID | Observable boundary | Current behavior | Expected behavior | Must remain unchanged | Rationale ID |
| --- | --- | --- | --- | --- | --- |
| OB-01 | Public temperature parsing | Callers duplicate parsing. | Valid invariant Celsius parses; invalid or impossible input is rejected. | Existing constructor behavior. | R-01 |

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
### AC-02 — Reject invalid or impossible Celsius

- Type: Failure
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Reject invalid or impossible Celsius
  Given null, whitespace, invalid text, or a value below absolute zero
  When a caller attempts to parse it as Celsius
  Then parsing fails without producing an impossible value
```

## Completion criteria

AC-01 and AC-02 pass and the existing constructor remains compatible.
EOF
cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
cat > Weather.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="1.61.35" />
  </ItemGroup>
</Project>
EOF
rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
: > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md
