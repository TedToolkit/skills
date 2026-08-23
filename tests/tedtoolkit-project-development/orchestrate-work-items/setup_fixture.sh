#!/usr/bin/env bash
set -euo pipefail

scenario=${1:?usage: setup_fixture.sh <scenario>}
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

write_change() {
    local change_dir=$1 title=$2 contracts=$3
    local contract_markers proof_markers proof_rows
    contract_markers=$(grep -Eo 'AC-[0-9]+' <<<"$contracts" | sort -u |
        sed 's/.*/<!-- acceptance-case: & -->/')
    proof_markers=$(grep -Eo 'AC-[0-9]+' <<<"$contracts" | sort -u |
        sed 's/.*/<!-- primary-proof: & purpose=acceptance shape=unit -->/')
    proof_rows=$(grep -Eo 'AC-[0-9]+' <<<"$contracts" | sort -u |
        sed 's/.*/| & | Primary | Acceptance | Unit | Approved outcome is observable | bash verify-all.sh |/')
    mkdir -p "$change_dir/work-items"
    cat > "$change_dir/change.md" <<EOF
# $title

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: multi-item -->

<!-- approval-source: Fixture owner -->

<!-- section: goal-rationale -->
## Goal and rationale

Deliver independently verifiable behavior through the approved multi-item map.

<!-- section: scope -->
## Scope and non-goals

Only the named outcomes are in scope; unrelated behavior remains unchanged.

<!-- section: behavior-contract -->
## Behavior contract

$contract_markers

$contracts

<!-- section: delivery-brief -->
## Delivery disposition

The approved outcome requires two or more independently verifiable deliveries.

<!-- section: proof-plan -->
## Proof

$proof_markers

| Contract | Role | Purpose | Shape | Observable assertion | Command or procedure |
| --- | --- | --- | --- | --- | --- |
$proof_rows

<!-- section: completion-criteria -->
## Completion

All owned ACs and required regression evidence pass on the integrated candidate.
EOF
}

write_item() {
    local change_dir=$1 id=$2 title=$3 status=$4 prerequisite=$5 area=$6 owned=$7 outcome=$8
    local proof_markers proof_rows
    proof_markers=$(grep -Eo 'AC-[0-9]+|INV-[0-9]+' <<<"$owned" | sort -u |
        sed 's/.*/<!-- primary-proof: & purpose=acceptance shape=unit -->/' || true)
    proof_rows=$(grep -Eo 'AC-[0-9]+|INV-[0-9]+|STR-[0-9]+' <<<"$owned" | sort -u |
        sed "s/.*/| & | Primary | Acceptance | Unit | $outcome | bash verify-item.sh |/" || true)
    cat > "$change_dir/work-items/$id.md" <<EOF
# $id: $title

<!-- work-item-format: 2 -->
<!-- work-item-id: $id -->

<!-- approval-source: Fixture owner -->
<!-- work-item: scope -->
## Scope and non-goals

- Outcome: $outcome
- Likely touchpoints (non-binding): $area
- Non-goal: unrelated behavior.

<!-- work-item: start-conditions -->
## Start conditions

$prerequisite

<!-- work-item: contract-coverage -->
## Contract responsibility

$owned

<!-- work-item: delivery-constraints -->
## Constraints

Preserve adjacent public behavior.

<!-- work-item: proof-plan -->
## Proof

$proof_markers

| Contract | Role | Purpose | Shape | Observable assertion | Command or procedure |
| --- | --- | --- | --- | --- | --- |
$proof_rows

<!-- work-item: definition-of-done -->
## Done

$owned passes and the supplied output is recorded.

<!-- work-item: completion-evidence -->
## Completion evidence

Record the command, observable assertion, result, changed artifacts, and supplied output.
EOF
}

case "$scenario" in
  dependency-wave)
    change_dir=docs/changes/flow
    write_change "$change_dir" "Dependency wave" $'- AC-01: the foundation is available.\n- AC-02: the left consumer uses it.\n- AC-03: the right consumer uses it.\n- AC-04: the combined surface exposes both consumers.'
    cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## Delivery map

<!-- approval-source: Fixture owner -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| FLOW-001 | Foundation | Owns AC-01 | None | Foundation assertion | Verified | `work-items/FLOW-001.md` |
| FLOW-002 | Left consumer | Owns AC-02 | FLOW-001: verified foundation | Left assertion | Approved | `work-items/FLOW-002.md` |
| FLOW-003 | Right consumer | Owns AC-03 | FLOW-001: verified foundation | Right assertion | Approved | `work-items/FLOW-003.md` |
| FLOW-004 | Combined surface | Owns AC-04 | FLOW-002: verified left result; FLOW-003: verified right result | Combined assertion | Approved | `work-items/FLOW-004.md` |
EOF
    write_item "$change_dir" FLOW-001 Foundation Implemented None Foundation.cs "Owns AC-01" "Provide the verified foundation."
    write_item "$change_dir" FLOW-002 "Left consumer" Approved "FLOW-001: verified foundation" LeftConsumer.cs "Owns AC-02" "Consume the foundation on the left path."
    write_item "$change_dir" FLOW-003 "Right consumer" Approved "FLOW-001: verified foundation" RightConsumer.cs "Owns AC-03" "Consume the foundation on the right path."
    write_item "$change_dir" FLOW-004 "Combined surface" Approved "FLOW-002 and FLOW-003: verified consumer results" Combined.cs "Owns AC-04" "Expose both verified consumers."
    ;;
  runtime-collision)
    change_dir=docs/changes/registration
    write_change "$change_dir" "Shared registration" $'- AC-01: alpha resolves.\n- AC-02: beta resolves.'
    cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## Delivery map

<!-- approval-source: Fixture owner -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| REG-001 | Register alpha | Owns AC-01 | None | Alpha resolution | Approved | `work-items/REG-001.md` |
| REG-002 | Register beta | Owns AC-02 | None | Beta resolution | Approved | `work-items/REG-002.md` |
EOF
    write_item "$change_dir" REG-001 "Register alpha" Approved None "SharedRegistry.cs and registration tests" "Owns AC-01" "Register the alpha service."
    write_item "$change_dir" REG-002 "Register beta" Approved None "SharedRegistry.cs and registration tests" "Owns AC-02" "Register the beta service."
    cat > SharedRegistry.cs <<'EOF'
namespace Fixture;

public static class SharedRegistry;
EOF
    ;;
  circular-dependency)
    change_dir=docs/changes/loop
    write_change "$change_dir" "Circular delivery" $'- AC-01: the first result is available.\n- AC-02: the second result is available.'
    cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## Delivery map

<!-- approval-source: Fixture owner -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| LOOP-001 | First | Owns AC-01 | LOOP-002: second result | First assertion | Approved | `work-items/LOOP-001.md` |
| LOOP-002 | Second | Owns AC-02 | LOOP-001: first result | Second assertion | Approved | `work-items/LOOP-002.md` |
EOF
    write_item "$change_dir" LOOP-001 First Approved "LOOP-002: second result" First.cs "Owns AC-01" "Produce the first result."
    write_item "$change_dir" LOOP-002 Second Approved "LOOP-001: first result" Second.cs "Owns AC-02" "Produce the second result."
    ;;
  partial-cycle)
    change_dir=docs/changes/partial-loop
    write_change "$change_dir" "Partial circular delivery" $'- AC-01: the independent result is available.\n- AC-02: the second result is available.\n- AC-03: the third result is available.'
    cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## Delivery map

<!-- approval-source: Fixture owner -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| PART-001 | Independent | Owns AC-01 | None | Independent assertion | Verified | `work-items/PART-001.md` |
| PART-002 | Second | Owns AC-02 | PART-003: third result | Second assertion | Approved | `work-items/PART-002.md` |
| PART-003 | Third | Owns AC-03 | PART-002: second result | Third assertion | Approved | `work-items/PART-003.md` |
EOF
    write_item "$change_dir" PART-001 Independent Verified None Independent.cs "Owns AC-01" "Produce the independent result."
    write_item "$change_dir" PART-002 Second Approved "PART-003: third result" Second.cs "Owns AC-02" "Produce the second result."
    write_item "$change_dir" PART-003 Third Approved "PART-002: second result" Third.cs "Owns AC-03" "Produce the third result."
    ;;
  execute-dependent-items)
    change_dir=docs/changes/dependent-chain
    write_change "$change_dir" "Build and consume a verified registry" $'- AC-01: the registry exposes alpha.\n- AC-02: the consumer reads alpha from the verified registry.'
    cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## Delivery map

<!-- approval-source: Fixture owner -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| CHAIN-001 | Expose alpha | Owns AC-01 | None | `bash verify-registry.sh` | Approved | `work-items/CHAIN-001.md` |
| CHAIN-002 | Consume alpha | Owns AC-02 | CHAIN-001: verified alpha registry | `bash verify-consumer.sh` | Approved | `work-items/CHAIN-002.md` |
EOF
    write_item "$change_dir" CHAIN-001 "Expose alpha" Approved None Registry.cs "Owns AC-01" "Set Registry.Alpha to the exact value ready. Prove with bash verify-registry.sh."
    write_item "$change_dir" CHAIN-002 "Consume alpha" Approved "CHAIN-001: verified alpha registry" Consumer.cs "Owns AC-02" "Return Registry.Alpha from Consumer.Read. Prove with bash verify-consumer.sh."
    cat > Registry.cs <<'EOF'
namespace Fixture;

internal static class Registry
{
    internal const string Alpha = "pending";
}
EOF
    cat > Consumer.cs <<'EOF'
namespace Fixture;

internal static class Consumer
{
    internal static string Read() => "pending";
}
EOF
    cat > verify-registry.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
grep -Fq 'Alpha = "ready"' Registry.cs
EOF
    cat > verify-consumer.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
grep -Fq 'Read() => Registry.Alpha' Consumer.cs
grep -Fq 'Alpha = "ready"' Registry.cs
EOF
    cat > verify-all.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash verify-registry.sh
bash verify-consumer.sh
EOF
    chmod +x verify-registry.sh verify-consumer.sh verify-all.sh
    ;;
  execute-independent-items)
    change_dir=docs/changes/independent-flags
    write_change "$change_dir" "Enable independent flags" $'- AC-01: alpha is enabled.\n- AC-02: beta is enabled.'
    cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## Delivery map

<!-- approval-source: Fixture owner -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| FLAG-001 | Enable alpha | Owns AC-01 | None | `bash verify-alpha.sh` | Approved | `work-items/FLAG-001.md` |
| FLAG-002 | Enable beta | Owns AC-02 | None | `bash verify-beta.sh` | Approved | `work-items/FLAG-002.md` |
EOF
    write_item "$change_dir" FLAG-001 "Enable alpha" Approved None Alpha.cs "Owns AC-01" "Enable alpha; prove with bash verify-alpha.sh."
    write_item "$change_dir" FLAG-002 "Enable beta" Approved None Beta.cs "Owns AC-02" "Enable beta; prove with bash verify-beta.sh."
    cat > Alpha.cs <<'EOF'
namespace Fixture;

internal static class Alpha
{
    internal const bool Enabled = false;
}
EOF
    cat > Beta.cs <<'EOF'
namespace Fixture;

internal static class Beta
{
    internal const bool Enabled = false;
}
EOF
    cat > verify-alpha.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
grep -Fq 'Enabled = true' Alpha.cs
EOF
    cat > verify-beta.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
grep -Fq 'Enabled = true' Beta.cs
EOF
    cat > verify-all.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash verify-alpha.sh
bash verify-beta.sh
EOF
    chmod +x verify-alpha.sh verify-beta.sh verify-all.sh
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
