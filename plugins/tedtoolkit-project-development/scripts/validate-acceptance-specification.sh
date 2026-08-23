#!/usr/bin/env bash
set -euo pipefail

# Validate stable markers and the minimum executable human handoff of one change.
# Visible headings may be translated; machine values and proof-table columns are stable.

change_file=${1:?usage: validate-acceptance-specification.sh <change.md>}
errors=0

fail() { printf 'ERROR: %s\n' "$*" >&2; errors=1; }

marker_values() {
    local name=$1
    awk -v name="$name" '
        index($0, "<!-- " name ":") {
            value = $0
            sub("^.*<!-- " name ":[[:space:]]*", "", value)
            sub("[[:space:]]*-->.*$", "", value)
            print value
        }
    ' "$change_file"
}

marker_value() {
    local name=$1 values count
    values=$(marker_values "$name")
    count=$(sed '/^[[:space:]]*$/d' <<<"$values" | wc -l | tr -d ' ')
    (( count == 1 )) || fail "$change_file: expected exactly one '$name' marker (found $count)"
    sed -n '1p' <<<"$values"
}

section() {
    local marker=$1
    awk -v marker="$marker" '
        index($0, "<!-- section: " marker " -->") { active = 1; next }
        active && /^## / && !seen_heading { seen_heading = 1; next }
        active && /^## / { exit }
        active { print }
    ' "$change_file"
}

require_section() {
    local marker=$1
    grep -Fq "<!-- section: $marker -->" "$change_file" || {
        fail "$change_file: missing section marker '$marker'"
        return
    }
    [[ -n $(section "$marker" | sed '/^[[:space:]]*$/d') ]] ||
        fail "$change_file: section '$marker' is empty"
}

legacy_approved() {
    grep -Eq '^## .*Status' "$change_file" &&
        grep -Eq '^## .*Change goal' "$change_file" &&
        grep -Eq '^## .*Acceptance specification' "$change_file" &&
        awk '
            /^## .*Status/ { in_status = 1; next }
            in_status && /^## / { exit }
            in_status && /^[[:space:]]*(Approved|In progress|Implemented|Completed|Superseded)[[:space:]]*$/ { found = 1 }
            END { exit(found ? 0 : 1) }
        ' "$change_file"
}

contract_markers() {
    local section_name=$1 marker_name=$2 prefix=$3 content
    content=$(section "$section_name")
    grep -Eo "<!--[[:space:]]*$marker_name:[[:space:]]*$prefix-[0-9]+[[:space:]]*-->" <<<"$content" |
        grep -Eo "$prefix-[0-9]+" || true
}

proof_row_complete() {
    local contract_id=$1
    awk -F'|' -v wanted="$contract_id" '
        function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        /^\|/ {
            contract=trim($2); role=tolower(trim($3)); assertion=trim($6); command=trim($7)
            if (contract == wanted && role == "primary" && assertion != "" && command != "" &&
                assertion !~ /^<.*>$/ && command !~ /^<.*>$/) found++
        }
        END { exit(found == 1 ? 0 : 1) }
    ' <<<"$(section proof-plan)"
}

[[ -f $change_file ]] || {
    printf 'ERROR: change file not found: %s\n' "$change_file" >&2
    exit 1
}

if ! grep -Fq '<!-- change-format: 3 -->' "$change_file"; then
    # Historical records predate the format marker. Only an already-approved
    # recognizable legacy contract may continue; a Draft must migrate to format 3.
    if legacy_approved; then
        printf 'OK: approved legacy change accepted: %s\n' "$change_file"
        exit 0
    fi
    fail "$change_file: expected format 3 or a recognizable already-approved legacy change"
    exit 1
fi

profile=$(marker_value workflow-profile)
kind=$(marker_value change-kind)
status=$(marker_value change-status)
delivery_shape=$(marker_value delivery-shape)
approval_source=$(marker_value approval-source)

case "$profile" in standard|controlled) ;; *) fail "$change_file: workflow-profile must be standard or controlled" ;; esac
case "$kind" in
    behavior-change|bug-fix|behavior-preserving-refactor|maintenance|migration|experiment) ;;
    *) fail "$change_file: unsupported or missing change-kind" ;;
esac
case "$status" in
    draft|approved|in-progress|implemented|completed|superseded) ;;
    *) fail "$change_file: unsupported or missing change-status" ;;
esac
case "$delivery_shape" in single|multi-item) ;; *) fail "$change_file: delivery-shape must be single or multi-item" ;; esac

[[ $profile != standard || $delivery_shape == single ]] ||
    fail "$change_file: Standard changes must use delivery-shape single"
[[ $kind != experiment || $delivery_shape == single ]] ||
    fail "$change_file: experiments must use delivery-shape single"
[[ $delivery_shape != multi-item || $profile == controlled ]] ||
    fail "$change_file: multi-item delivery requires a Controlled profile"

if [[ $status == draft ]]; then
    [[ $approval_source == none ]] || fail "$change_file: Draft approval-source must be 'none'"
else
    [[ -n $approval_source && $approval_source != none ]] ||
        fail "$change_file: non-Draft status requires an explicit human approval-source"
fi

for required in goal-rationale scope delivery-brief proof-plan completion-criteria; do
    require_section "$required"
done

contract_ids=""
case "$kind" in
    behavior-change|bug-fix|migration)
        require_section behavior-contract
        contract_ids=$(contract_markers behavior-contract acceptance-case AC)
        ;;
    behavior-preserving-refactor)
        require_section invariants
        contract_ids=$(contract_markers invariants preserved-invariant INV)
        ;;
    maintenance)
        require_section structural-contract
        contract_ids=$(contract_markers structural-contract structural-outcome STR)
        ;;
    experiment)
        require_section experiment-contract
        contract_ids=$(contract_markers experiment-contract experiment EXP)
        ;;
esac

[[ -n $contract_ids ]] || fail "$change_file: change kind '$kind' needs at least one stable contract marker"
contract_count=$(sed '/^[[:space:]]*$/d' <<<"$contract_ids" | wc -l | tr -d ' ')
unique_contract_count=$(sort -u <<<"$contract_ids" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')
(( contract_count == unique_contract_count )) || fail "$change_file: contract markers must be unique"
contract_ids=$(sort -u <<<"$contract_ids")

proof=$(section proof-plan)
proof_markers=$(grep -Eo '<!--[[:space:]]*primary-proof:[^>]*-->' <<<"$proof" || true)
while IFS= read -r proof_marker; do
    [[ -n $proof_marker ]] || continue
    if [[ ! $proof_marker =~ ^\<!--[[:space:]]*primary-proof:[[:space:]]*(AC|INV|STR|EXP)-[0-9]+[[:space:]]+purpose=(acceptance|regression|boundary|structural|journey|decision)[[:space:]]+shape=(unit|component|contract|integration|end-to-end|benchmark|manual)[[:space:]]*--\>$ ]]; then
        fail "$change_file: malformed primary-proof marker '$proof_marker'"
        continue
    fi
    proof_contract=$(grep -Eo '(AC|INV|STR|EXP)-[0-9]+' <<<"$proof_marker")
    grep -Fxq "$proof_contract" <<<"$contract_ids" ||
        fail "$change_file: primary-proof marker references undeclared $proof_contract"
done <<<"$proof_markers"

while IFS= read -r contract_id; do
    [[ -n $contract_id ]] || continue
    primary_count=$(grep -Ec "<!--[[:space:]]*primary-proof:[[:space:]]*$contract_id[[:space:]]" <<<"$proof_markers" || true)
    (( primary_count == 1 )) ||
        fail "$change_file: $contract_id must have exactly one stable primary-proof marker (found $primary_count)"
    proof_row_complete "$contract_id" ||
        fail "$change_file: $contract_id needs exactly one Primary proof row with observable assertion and command/procedure"
done <<<"$contract_ids"

if grep -Eqi '^##[[:space:]]+(clarification log|decision ledger|agent log|澄清日志|决策日志|代理日志)' "$change_file"; then
    fail "$change_file: agent/process logs belong outside the human change record"
fi

(( errors == 0 )) || exit 1
printf 'OK: change handoff is structurally complete: %s\n' "$change_file"
