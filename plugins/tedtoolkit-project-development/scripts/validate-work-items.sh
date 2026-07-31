#!/usr/bin/env bash
set -euo pipefail

# Check the structural facts that let a work item start, finish, and prove its
# own outcome. This intentionally checks completeness, not domain correctness;
# the latter remains a human design-review responsibility.

change_dir=${1:?usage: validate-work-items.sh <parent-change-directory>}
work_items_dir="$change_dir/work-items"
change_file="$change_dir/change.md"
errors=0

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    errors=1
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
    grep -Fq "<!-- work-item: $marker -->" "$file" || fail "$file: missing marker '$marker'"
}

require_nonempty_table_row() {
    local file=$1 marker=$2
    local body
    body=$(section "$file" "$marker")
    if ! printf '%s\n' "$body" | awk '
        /^\|/ {
            rows++
            if (rows > 2 && $0 !~ /^\|[[:space:]]*\|/) {
                found = 1
            }
        }
        END { exit !found }
    '; then
        fail "$file: '$marker' has no populated table row"
    fi
}

delivery_map() {
    local file=$1
    awk '
        index($0, "<!-- delivery-map -->") { active = 1; next }
        /^## / && index($0, "Delivery map") { active = 1; next }
        active && /^## / { exit }
        active { print }
    ' "$file"
}

if [[ ! -f $change_file ]]; then
    fail "$change_dir: missing change.md"
fi
if [[ ! -d $work_items_dir ]]; then
    fail "$change_dir: missing work-items directory"
fi

shopt -s nullglob
items=("$work_items_dir"/*.md)
if ((${#items[@]} == 0)); then
    fail "$work_items_dir: no work-item documents"
fi

for item in "${items[@]}"; do
    for marker in \
        scope \
        start-conditions \
        behavior-cases \
        delivery-constraints \
        verification-plan \
        definition-of-done \
        completion-evidence; do
        require_section "$item" "$marker"
    done

    for marker in \
        scope \
        behavior-cases \
        delivery-constraints \
        verification-plan \
        definition-of-done; do
        require_nonempty_table_row "$item" "$marker"
    done

    mapfile -t cases < <(section "$item" behavior-cases | grep -oE 'BC-[0-9]+' | sort -u)
    if ((${#cases[@]} == 0)); then
        fail "$item: behavior cases must use at least one BC-<number> identifier"
        continue
    fi
    verification=$(section "$item" verification-plan)
    for behavior_case in "${cases[@]}"; do
        if ! grep -Fq "$behavior_case" <<<"$verification"; then
            fail "$item: $behavior_case has no verification-plan mapping"
        fi
    done
done

if [[ -f $change_file ]]; then
    mapfile -t map_rows < <(delivery_map "$change_file" | grep -E '^\|[[:space:]]*[[:alnum:]]+-[0-9]+[[:space:]]*\|' || true)
    if ((${#map_rows[@]} == 0)); then
        fail "$change_file: delivery map has no work-item rows or is missing '<!-- delivery-map -->'"
    fi
    declare -A known_ids=()
    declare -A prerequisites_for_id=()
    for row in "${map_rows[@]}"; do
        IFS='|' read -r _ id _ _ _ _ prerequisites verification _ _ <<<"$row"
        id=$(xargs <<<"$id")
        prerequisites=$(xargs <<<"$prerequisites")
        verification=$(xargs <<<"$verification")
        if [[ -z $id || -v "known_ids[$id]" ]]; then
            fail "$change_file: delivery-map ID is empty or duplicated: '$id'"
            continue
        fi
        known_ids[$id]=1
        prerequisites_for_id[$id]=$prerequisites
        [[ -n $verification && $verification != *'<'* ]] || fail "$change_file: $id has no item-owned verification gate"
    done

    for id in "${!known_ids[@]}"; do
        prerequisites=${prerequisites_for_id[$id]}
        [[ $prerequisites == 'None' ]] && continue
        [[ $prerequisites == *:* && $prerequisites != *'<'* ]] || fail "$change_file: $id prerequisites must name a supplied concrete input"
        while read -r prerequisite_id; do
            [[ -z $prerequisite_id ]] && continue
            if [[ $prerequisite_id == "$id" ]]; then
                fail "$change_file: $id cannot depend on itself"
            elif [[ ! -v "known_ids[$prerequisite_id]" ]]; then
                fail "$change_file: $id depends on unknown item $prerequisite_id"
            fi
        done < <(grep -oE '[[:alnum:]]+-[0-9]+' <<<"$prerequisites" || true)
    done

    declare -A dependency_state=()
    visit_dependency() {
        local id=$1
        local state=${dependency_state[$id]:-unseen}
        [[ $state == done ]] && return
        if [[ $state == visiting ]]; then
            fail "$change_file: circular delivery-map dependency includes $id"
            return
        fi

        dependency_state[$id]=visiting
        local dependency_id
        local -a dependency_ids=()
        mapfile -t dependency_ids < <(grep -oE '[[:alnum:]]+-[0-9]+' <<<"${prerequisites_for_id[$id]}" || true)
        for dependency_id in "${dependency_ids[@]}"; do
            [[ -v "known_ids[$dependency_id]" ]] && visit_dependency "$dependency_id"
        done
        dependency_state[$id]=done
    }

    for id in "${!known_ids[@]}"; do
        visit_dependency "$id"
    done
fi

if ((errors)); then
    exit 1
fi
printf 'Work-item delivery boundary: valid\n'
