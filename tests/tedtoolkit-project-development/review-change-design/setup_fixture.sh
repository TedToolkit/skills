#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
mkdir -p docs/changes/P1-temperature-parse

case "$scenario" in
  incomplete-design)
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

## Change goal

Add `TryParse`.

## Scope

Add parsing support.
EOF
    ;;
  approval-ready-design)
    mkdir -p docs/requests
    cat > docs/requests/PR-17.md <<'EOF'
# PR-17: Safe temperature parsing

Approved product request. Several callers duplicate invariant-Celsius parsing and accept impossible
values. Before the next ingestion API release, provide one additive, non-throwing parsing contract;
formatting and Fahrenheit support remain out of scope. Product has approved the exact accepted
grammar `[+-]?[0-9]+(\.[0-9]+)?`: accept signed zero and exactly `-273.15`, reject whitespace,
partial decimals, grouping, exponents, overflow, lower values, and precision that would require
rounding. Existing construction behavior must remain source-compatible; binary compatibility is
not a release claim for this pre-release package.
EOF
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: draft -->
<!-- delivery-shape: single -->
<!-- approval-source: none -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

Before the next ingestion API release, the library provides one additive non-throwing
invariant-Celsius parser instead of leaving callers to duplicate parsing that accepts impossible
values. Source: `docs/requests/PR-17.md`.

<!-- section: scope -->
## Scope and non-goals

- In scope: `public static bool TryParse(string? text, out Temperature result)` accepting
  `[+-]?[0-9]+(\.[0-9]+)?` invariant Celsius text at or above `-273.15` only when the value is
  exactly representable by `decimal` without rounding.
- Non-goals: formatting, Fahrenheit input, localization, migration, or rollout.
- Preserved: existing construction behavior and source compatibility. Binary compatibility is not
  claimed for this pre-release package.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
Current callers duplicate parsing. Expected behavior is one compatible public parser. Signed zero
and exactly `-273.15` are accepted. Leading/trailing whitespace, `.5`, `1.`, a sign without digits,
group separators, exponent notation, lower values, decimal overflow, and excess precision that
would require rounding are rejected.

<!-- acceptance-case: AC-01 -->
- AC-01: valid invariant decimal Celsius text succeeds and returns the exact corresponding value.
<!-- acceptance-case: AC-02 -->
- AC-02: null, whitespace, invalid, grouped, exponent, overflow, and below-absolute-zero values
  return false, set `result` to `default`, and do not throw.

## Constraints and risks

The public API is additive. Rollback removes it before release; no migration or operational handoff
is required. Using invariant culture as a system-wide rule is out of scope, so no ADR is required.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

One bounded delivery updates the value type and focused public-boundary tests. Likely touchpoints are
the Temperature implementation and its existing test project; private parsing structure remains open.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
<!-- primary-proof: AC-02 purpose=acceptance shape=unit -->
| Contract | Role | Observable assertion | Command |
| --- | --- | --- | --- |
| AC-01 | Primary | Valid exactly representable input returns its exact Celsius value, including signed zero and `-273.15` | `dotnet test --configuration Release --project Weather.Tests.csproj`; require non-zero AC-01 discovery |
| AC-02 | Primary | Every rejected grammar, boundary, overflow, and excess-precision partition returns false with default output and no exception | Same command; require non-zero AC-02 discovery |
| Existing constructor and source compatibility | Conditional | Existing constructor call sites still compile and the focused constructor regression passes | Same command; compilation of `TemperatureTests.cs` and the passing constructor test are the bounded procedure and observable pass condition |

<!-- section: completion-criteria -->
## Completion

Both acceptance cases and the affected constructor regression pass with source compatibility
preserved; no binary-compatibility claim is in scope.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > Weather.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="1.61.35" />
  </ItemGroup>
</Project>
EOF
    cat > TemperatureTests.cs <<'EOF'
using TUnit.Assertions;
using TUnit.Core;

namespace Weather.Tests;

internal sealed class TemperatureTests
{
    [Test]
    public async Task Existing_constructor_preserves_value()
    {
        await Assert.That(new Temperature(12.5m).Celsius).IsEqualTo(12.5m);
    }
}
EOF
    cat > CLAUDE.md <<'EOF'
# Repository guidance

Use `dotnet test --configuration Release --project Weather.Tests.csproj` for the authoritative focused proof.
EOF
    ;;
  planned-prerequisite)
    mkdir -p docs/changes/settings-store docs/changes/preferences-screen
    cat > docs/changes/settings-store/change.md <<'EOF'
# Provide a settings store
<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->
<!-- section: goal-rationale -->
## Goal
Applications can persist settings.
<!-- section: scope -->
## Scope
Provide one settings-store contract.
<!-- section: behavior-contract -->
## Behavior
<!-- acceptance-case: AC-01 -->
- AC-01: a caller can persist and retrieve one setting.
<!-- section: start-conditions -->
## Start conditions
<!-- change-prerequisite: none -->
None. Ready from the approved baseline.
<!-- section: delivery-brief -->
## Delivery
One bounded delivery.
<!-- section: proof-plan -->
## Proof
<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Persisted setting can be retrieved | Component procedure: save `density=compact`, reconstruct the store, and assert the value is `compact` |
<!-- section: completion-criteria -->
## Completion
AC-01 passes.
EOF
    cat > docs/changes/preferences-screen/change.md <<'EOF'
# Add a preferences screen
<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: draft -->
<!-- delivery-shape: single -->
<!-- approval-source: none -->
<!-- section: goal-rationale -->
## Goal and rationale
Users can edit persisted preferences through one screen, avoiding manual configuration changes.
<!-- section: scope -->
## Scope and non-goals
Add the screen; preserve the settings-store public contract and exclude synchronization or migration.
<!-- section: behavior-contract -->
## Behavior contract
<!-- acceptance-case: AC-01 -->
- AC-01: a user can save one preference and observe it after reopening the screen.
<!-- section: start-conditions -->
## Start conditions
<!-- change-prerequisite: PRE-01 source=../settings-store/change.md contract=AC-01 -->
| ID | Required input or guarantee | Source change outcome | Required readiness evidence |
| --- | --- | --- | --- |
| PRE-01 | Persisted settings are available | `../settings-store/change.md`, AC-01 | Source contract is completed on the implementation baseline |
<!-- section: delivery-brief -->
## Delivery brief
One bounded screen delivery; likely UI touchpoints are non-binding and private structure remains open.
<!-- section: proof-plan -->
## Proof
<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Saved preference remains visible after reopening | Component procedure: save `density=compact`, reopen the screen, and assert `compact` is displayed |
<!-- section: completion-criteria -->
## Completion
AC-01 passes with the source contract unchanged.
EOF
    ;;
  missing-rationale)
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
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

Add one parsing API on the value type. A separate parser type is rejected.

## Risks and rollback

The additive API has no migration; rollback removes the new API before release.

## Completion criteria

Both BehaviorCases have focused observable tests.

## Estimate

0.01–0.02 person-months; medium confidence; assumes no public-format compatibility requirement; re-estimate if parsing requires localization.
EOF
    ;;
  missing-accepted-adr)
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
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

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
