#!/usr/bin/env bash
set -euo pipefail

# Validate a real multi-item delivery map. Human headings are free to vary;
# stable comments and table columns are the automation contract.

change_dir=${1:?usage: validate-work-items.sh <parent-change-directory>}
change_file="$change_dir/change.md"
map_file="$change_dir/work-items.md"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
errors=0

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    errors=1
}

marker_value() {
    local file=$1 name=$2
    awk -v name="$name" '
        index($0, "<!-- " name ":") {
            value = $0
            sub("^.*<!-- " name ":[[:space:]]*", "", value)
            sub("[[:space:]]*-->.*$", "", value)
            print value
            exit
        }
    ' "$file"
}

section() {
    local file=$1 marker=$2
    awk -v marker="$marker" '
        index($0, "<!-- work-item: " marker " -->") { active = 1; next }
        active && /^## / && !seen_heading { seen_heading = 1; next }
        active && /^## / { exit }
        active { print }
    ' "$file"
}

require_section() {
    local file=$1 marker=$2
    grep -Fq "<!-- work-item: $marker -->" "$file" || {
        fail "$file: missing section marker '$marker'"
        return
    }
    [[ -n $(section "$file" "$marker" | sed '/^[[:space:]]*$/d') ]] ||
        fail "$file: section '$marker' is empty"
}

[[ -f $change_file ]] || fail "missing parent change: $change_file"
[[ -f $map_file ]] || fail "missing delivery map: $map_file"
(( errors == 0 )) || exit 1

"$script_dir/validate-acceptance-specification.sh" "$change_file" ||
    fail "$change_file: parent change is not structurally valid"
grep -Fq '<!-- workflow-profile: controlled -->' "$change_file" ||
    fail "$change_file: a multi-item map requires a Controlled parent"
grep -Fq '<!-- delivery-shape: multi-item -->' "$change_file" ||
    fail "$change_file: a work-item map requires an approved multi-item delivery shape"
parent_status=$(marker_value "$change_file" change-status)
[[ $parent_status != draft ]] ||
    fail "$change_file: work-item planning requires an approved parent change, not a Draft"
grep -Fq '<!-- change-kind: experiment -->' "$change_file" &&
    fail "$change_file: experiments are single deliveries and cannot have a work-item map"

parent_contracts=$(grep -Eo '<!--[[:space:]]*(acceptance-case:[[:space:]]*AC|preserved-invariant:[[:space:]]*INV|structural-outcome:[[:space:]]*STR|experiment:[[:space:]]*EXP)-[0-9]+[[:space:]]*-->' "$change_file" |
    grep -Eo 'AC-[0-9]+|INV-[0-9]+|STR-[0-9]+|EXP-[0-9]+' | sort -u)

grep -Fq '<!-- delivery-map -->' "$map_file" || fail "$map_file: missing delivery-map marker"

map_rows=$(awk -F'|' '
    function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
    /^\|/ {
        id=trim($2); outcome=trim($3); contracts=trim($4); prereqs=trim($5)
        proof=trim($6); status=trim($7); doc=trim($8)
        if (id == "ID" || id ~ /^-+$/ || doc == "") next
        gsub(/`/, "", doc)
        printf "%s\034%s\034%s\034%s\034%s\034%s\034%s\n", id, outcome, contracts, prereqs, proof, status, doc
    }
' "$map_file")

row_count=$(sed '/^[[:space:]]*$/d' <<<"$map_rows" | wc -l | tr -d ' ')
(( row_count >= 2 )) || fail "$map_file: delivery maps are only valid with at least two items"

declare -a ids=()
declare -a contracts_by_row=()
declare -a prerequisites_by_row=()
declare -a statuses_by_row=()
declare -A known_ids=()
declare -A status_by_id=()
requires_approval=0
has_draft=0
while IFS=$'\034' read -r id outcome contracts prereqs primary_proof map_status document; do
    [[ -n $id ]] || continue
    [[ $id =~ ^[A-Z][A-Z0-9]*-[0-9]+$ ]] || {
        fail "$map_file: invalid work-item ID '$id'"
        continue
    }
    ids+=("$id")
    contracts_by_row+=("$contracts")
    prerequisites_by_row+=("$prereqs")
    statuses_by_row+=("${map_status,,}")

    if [[ -n ${known_ids[$id]+x} ]]; then
        fail "$map_file: duplicate work-item ID '$id'"
    fi
    known_ids["$id"]=1
    status_by_id["$id"]=${map_status,,}

    [[ -n $outcome ]] || fail "$map_file: $id needs a non-empty outcome"
    [[ -n $contracts ]] || fail "$map_file: $id needs explicit contract ownership or None"
    [[ -n $prereqs ]] || fail "$map_file: $id needs explicit prerequisites or None"
    [[ -n $primary_proof ]] || fail "$map_file: $id needs a primary proof summary"

    case "${map_status,,}" in
        draft|approved|implementing|implemented|verified|superseded) ;;
        *) fail "$map_file: $id has unsupported or missing authoritative status '$map_status'" ;;
    esac

    [[ $document =~ ^work-items/${id}(-[A-Za-z0-9._-]+)?\.md$ ]] || {
        fail "$map_file: $id document must be a safe relative path under work-items/"
        continue
    }
    item_file="$change_dir/$document"
    [[ -f $item_file ]] || {
        fail "$map_file: $id references missing document '$document'"
        continue
    }

    grep -Fq '<!-- work-item-format: 2 -->' "$item_file" ||
        fail "$item_file: expected work-item-format 2"
    grep -Fq "<!-- work-item-id: $id -->" "$item_file" ||
        fail "$item_file: work-item-id does not match map row '$id'"

    if [[ ${map_status,,} == draft ]]; then
        has_draft=1
        [[ $(marker_value "$item_file" approval-source) == none ]] ||
            fail "$item_file: Draft approval-source must be 'none'"
    else
        requires_approval=1
        approval_source=$(marker_value "$item_file" approval-source)
        [[ -n $approval_source && $approval_source != none ]] ||
            fail "$item_file: non-Draft item requires an explicit human approval-source"
    fi

    for required in scope start-conditions contract-coverage delivery-constraints proof-plan definition-of-done completion-evidence; do
        require_section "$item_file" "$required"
    done

    coverage=$(section "$item_file" contract-coverage)
    item_proof=$(section "$item_file" proof-plan)
    while IFS= read -r owned_contract; do
        [[ -n $owned_contract ]] || continue
        grep -Eq "(^|[^[:alnum:]])$owned_contract([^0-9]|$)" <<<"$coverage" ||
            fail "$item_file: contract coverage does not include owned $owned_contract"
        grep -Eq "(^|[^[:alnum:]])$owned_contract([^0-9]|$)" <<<"$item_proof" ||
            fail "$item_file: proof plan does not map owned $owned_contract"
        primary_count=$(grep -Eic "<!--[[:space:]]*primary-proof:[[:space:]]*$owned_contract[[:space:]]+purpose=(acceptance|regression|boundary|structural|journey|decision)[[:space:]]+shape=(unit|component|contract|integration|end-to-end|benchmark|manual)[[:space:]]*-->" <<<"$item_proof" || true)
        (( primary_count == 1 )) ||
            fail "$item_file: owned $owned_contract must have exactly one stable primary-proof marker (found $primary_count)"
        awk -F'|' -v wanted="$owned_contract" '
            function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
            /^\|/ {
                contract=trim($2); role=tolower(trim($3)); assertion=trim($6); command=trim($7)
                if (contract == wanted && role == "primary" && assertion != "" && command != "" &&
                    assertion !~ /^<.*>$/ && command !~ /^<.*>$/) found++
            }
            END { exit(found == 1 ? 0 : 1) }
        ' <<<"$item_proof" ||
            fail "$item_file: owned $owned_contract needs one Primary proof row with assertion and command/procedure"
    done < <(grep -Eio '(Owns|负责)[[:space:]]+(AC-[0-9]+|INV-[0-9]+|STR-[0-9]+|EXP-[0-9]+)' <<<"$contracts" |
        grep -Eo 'AC-[0-9]+|INV-[0-9]+|STR-[0-9]+|EXP-[0-9]+' || true)

    while IFS= read -r mentioned_contract; do
        [[ -n $mentioned_contract ]] || continue
        grep -Fxq "$mentioned_contract" <<<"$parent_contracts" ||
            fail "$map_file: $id references undeclared parent contract $mentioned_contract"
        grep -Eqi "(Owns|负责|Supports|支持)[[:space:]]+$mentioned_contract([^0-9]|$)" <<<"$contracts" ||
            fail "$map_file: $id must give $mentioned_contract an explicit Owns or Supports token"
    done < <(grep -Eo 'AC-[0-9]+|INV-[0-9]+|STR-[0-9]+|EXP-[0-9]+' <<<"$contracts" | sort -u || true)

done <<<"$map_rows"

if (( requires_approval == 1 )); then
    (( has_draft == 0 )) || fail "$map_file: delivery-map approval cannot leave individual rows Draft"
    map_approval_source=$(marker_value "$map_file" approval-source)
    [[ -n $map_approval_source && $map_approval_source != none ]] ||
        fail "$map_file: approved delivery map requires an explicit human approval-source"
else
    [[ $(marker_value "$map_file" approval-source) == none ]] ||
        fail "$map_file: Draft approval-source must be 'none'"
fi

dependency_ids() {
    local text=$1
    grep -Eo '[A-Z][A-Z0-9]*-[0-9]+' <<<"$text" | sort -u || true
}

declare -A indegree=()
declare -A removed=()
for id in "${ids[@]}"; do
    indegree["$id"]=0
done

for ((i = 0; i < ${#ids[@]}; i++)); do
    id=${ids[i]}
    while IFS= read -r dependency; do
        [[ -n $dependency ]] || continue
        if [[ -z ${known_ids[$dependency]+x} ]]; then
            fail "$map_file: $id references missing prerequisite '$dependency'"
            continue
        fi
        if [[ $dependency == "$id" ]]; then
            fail "$map_file: $id cannot depend on itself"
        fi
        if [[ ${status_by_id[$dependency]} == superseded ]]; then
            fail "$map_file: $id depends on superseded $dependency; name a verified replacement and supplied input"
        fi
        ((indegree["$id"] += 1))
    done < <(dependency_ids "${prerequisites_by_row[i]}")
done

processed=0
while (( processed < ${#ids[@]} )); do
    progressed=0
    for id in "${ids[@]}"; do
        [[ -z ${removed[$id]+x} ]] || continue
        (( indegree[$id] == 0 )) || continue
        removed["$id"]=1
        ((processed += 1))
        progressed=1
        for ((j = 0; j < ${#ids[@]}; j++)); do
            dependent=${ids[j]}
            [[ -z ${removed[$dependent]+x} ]] || continue
            if dependency_ids "${prerequisites_by_row[j]}" | grep -Fxq "$id"; then
                indegree["$dependent"]=$((indegree["$dependent"] - 1))
            fi
        done
    done
    (( progressed == 1 )) || break
done

(( processed == ${#ids[@]} )) || fail "$map_file: delivery prerequisites contain a cycle"

if [[ -f $change_file ]]; then
    while IFS= read -r contract_id; do
        [[ -n $contract_id ]] || continue
        owner_count=0
        for ((i = 0; i < ${#contracts_by_row[@]}; i++)); do
            [[ ${statuses_by_row[i]} != superseded ]] || continue
            contracts=${contracts_by_row[i]}
            if grep -Eqi "(Owns|负责)[[:space:]]+$contract_id([^0-9]|$)" <<<"$contracts"; then
                ((owner_count += 1))
            fi
        done
        (( owner_count == 1 )) ||
            fail "$map_file: $contract_id must have exactly one owner (found $owner_count)"
    done <<<"$parent_contracts"
fi

if (( errors > 0 )); then
    exit 1
fi

printf 'OK: %s contains %s independently verifiable work items\n' "$map_file" "$row_count"
