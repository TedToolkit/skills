#!/usr/bin/env bash
set -euo pipefail

# Report logical readiness only. Runtime write collisions are established by
# implementation preflight and never become invented delivery dependencies.

change_dir=${1:?usage: schedule-work-items.sh <parent-change-directory>}
change_file="$change_dir/change.md"
map_file="$change_dir/work-items.md"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

[[ -f $change_file ]] || {
    printf 'ERROR: missing parent change: %s\n' "$change_file" >&2
    exit 1
}

legacy_embedded=0
if [[ -f $map_file ]]; then
    "$script_dir/validate-work-items.sh" "$change_dir" >/dev/null
fi

if [[ -f $map_file ]]; then
    rows=$(awk -F'|' '
        function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        /^\|/ {
            id=trim($2); prereqs=trim($5)
            if (trim($8) != "") status=trim($7); else status=trim($6)
            if (id == "ID" || id ~ /^-+$/ || id == "") next
            printf "%s\t%s\t%s\n", id, prereqs, status
        }
    ' "$map_file")
elif grep -Fq '<!-- change-format: 2 -->' "$change_file"; then
    # Transitional support for the former nine-column map embedded in change.md.
    "$script_dir/validate-acceptance-specification.sh" --allow-approved-legacy "$change_file" >/dev/null
    printf 'DEPRECATED: scheduling unchanged approved change-format 2; migrate before any edit or renewed approval\n' >&2
    legacy_embedded=1
    rows=$(awk -F'|' '
        function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        /^\|/ {
            id=trim($2); prereqs=trim($7); status=trim($9)
            if (id == "ID" || id ~ /^-+$/ || id == "") next
            printf "%s\t%s\t%s\n", id, prereqs, status
        }
    ' "$change_file")
else
    printf 'ERROR: format 3 Controlled changes require work-items.md\n' >&2
    exit 1
fi

[[ -n $rows ]] || {
    printf 'ERROR: no delivery rows found in %s\n' "$change_dir" >&2
    exit 1
}

status_of() {
    local wanted=$1
    awk -F'\t' -v wanted="$wanted" '$1 == wanted { print $3; exit }' <<<"$rows"
}

dependency_ids() {
    local text=$1
    grep -Eo '[A-Z][A-Z0-9]*-[0-9]+' <<<"$text" | sort -u || true
}

ready_count=0
pending_count=0
while IFS=$'\t' read -r id prerequisites status; do
    normalized=${status,,}
    normalized=${normalized// /-}
    case "$normalized" in
        verified)
            printf '%s\tCOMPLETE\t%s\n' "$id" "$status"
            continue
            ;;
        implemented)
            if (( legacy_embedded == 1 )); then
                printf '%s\tCOMPLETE\t%s (legacy embedded map)\n' "$id" "$status"
            else
                printf '%s\tBLOCKED\tImplemented candidate awaits authoritative integration verification\n' "$id"
            fi
            continue
            ;;
        approved)
            ((pending_count += 1))
            ;;
        *)
            printf '%s\tBLOCKED\tdocument status is %s\n' "$id" "$status"
            continue
            ;;
    esac

    blocked_by=()
    while IFS= read -r dependency; do
        [[ -n $dependency ]] || continue
        dependency_status=$(status_of "$dependency")
        if [[ -z $dependency_status ]]; then
            blocked_by+=("$dependency (missing)")
        else
            dependency_normalized=${dependency_status,,}
            dependency_normalized=${dependency_normalized// /-}
            if [[ $dependency_normalized != verified ]] &&
                { ! (( legacy_embedded == 1 )) || [[ $dependency_normalized != implemented ]]; }; then
                blocked_by+=("$dependency ($dependency_status)")
            fi
        fi
    done < <(dependency_ids "$prerequisites")

    if (( ${#blocked_by[@]} == 0 )); then
        printf '%s\tREADY\tall logical prerequisites are integrated and verified\n' "$id"
        ((ready_count += 1))
    else
        reason=$(IFS=', '; printf '%s' "${blocked_by[*]}")
        printf '%s\tBLOCKED\twaiting for %s\n' "$id" "$reason"
    fi
done <<<"$rows"

if (( pending_count > 0 && ready_count == 0 )); then
    printf 'ERROR: no approved item is ready; every prerequisite must be Verified on the authoritative integration revision\n' >&2
    exit 1
fi
