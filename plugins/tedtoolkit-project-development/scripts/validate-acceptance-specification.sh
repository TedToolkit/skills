#!/usr/bin/env bash
set -euo pipefail

# Validate stable markers and the minimum executable human handoff of one change.
# Visible headings may be translated; machine values and proof-table columns are stable.

allow_approved_legacy=0
require_ready=0
baseline=""
prerequisite_legacy_base=""
while (( $# > 0 )); do
    case "$1" in
        --allow-approved-legacy)
            allow_approved_legacy=1
            shift
            ;;
        --require-ready)
            require_ready=1
            shift
            ;;
        --baseline)
            [[ $# -ge 2 ]] || {
                printf 'ERROR: --baseline requires a Git revision\n' >&2
                exit 1
            }
            baseline=$2
            shift 2
            ;;
        --allow-approved-prerequisite-legacy)
            [[ $# -ge 2 ]] || {
                printf 'ERROR: --allow-approved-prerequisite-legacy requires a Git revision\n' >&2
                exit 1
            }
            prerequisite_legacy_base=$2
            shift 2
            ;;
        --*)
            printf 'ERROR: unsupported option: %s\n' "$1" >&2
            exit 1
            ;;
        *) break ;;
    esac
done
[[ $# == 1 ]] || {
    printf 'ERROR: usage: validate-acceptance-specification.sh [--allow-approved-legacy] [--allow-approved-prerequisite-legacy <git-rev>] [--require-ready --baseline <git-rev>] <change.md>\n' >&2
    exit 1
}
change_file=$1
errors=0

if (( require_ready == 1 )) && [[ -z $baseline ]]; then
    printf 'ERROR: --require-ready requires --baseline <git-rev>\n' >&2
    exit 1
fi
if (( require_ready == 0 )) && [[ -n $baseline ]]; then
    printf 'ERROR: --baseline is valid only with --require-ready\n' >&2
    exit 1
fi

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
    grep -Fq '<!-- change-format: 2 -->' "$change_file" &&
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
            contract=trim($2); role=tolower(trim($3))
            if (contract == wanted && role == "primary") {
                # New compact rows have four content columns. Expanded format-3
                # rows remain readable, but their purpose/shape prose is not authoritative.
                if (NF >= 8) { assertion=trim($6); command=trim($7) }
                else { assertion=trim($4); command=trim($5) }
                if (assertion != "" && command != "" && assertion !~ /^<.*>$/ && command !~ /^<.*>$/) found++
            }
        }
        END { exit(found == 1 ? 0 : 1) }
    ' <<<"$(section proof-plan)"
}

section_from_file() {
    local file=$1 marker=$2
    awk -v marker="$marker" '
        index($0, "<!-- section: " marker " -->") { active = 1; next }
        active && /^## / && !seen_heading { seen_heading = 1; next }
        active && /^## / { exit }
        active { print }
    ' "$file"
}

section_from_content() {
    local marker=$1
    awk -v marker="$marker" '
        index($0, "<!-- section: " marker " -->") { active = 1; next }
        active && /^## / && !seen_heading { seen_heading = 1; next }
        active && /^## / { exit }
        active { print }
    '
}

prerequisite_values_from_file() {
    local file=$1
    awk '
        index($0, "<!-- change-prerequisite:") {
            value = $0
            sub("^.*<!-- change-prerequisite:[[:space:]]*", "", value)
            sub("[[:space:]]*-->.*$", "", value)
            print value
        }
    ' "$file"
}

prerequisite_values_from_content() {
    awk '
        index($0, "<!-- change-prerequisite:") {
            value = $0
            sub("^.*<!-- change-prerequisite:[[:space:]]*", "", value)
            sub("[[:space:]]*-->.*$", "", value)
            print value
        }
    '
}

marker_from_content() {
    local name=$1
    awk -v name="$name" '
        index($0, "<!-- " name ":") {
            value = $0
            sub("^.*<!-- " name ":[[:space:]]*", "", value)
            sub("[[:space:]]*-->.*$", "", value)
            print value
        }
    '
}

contract_location_for_kind() {
    case "$1" in
        behavior-change|bug-fix|migration) printf '%s\t%s\t%s\n' behavior-contract acceptance-case AC ;;
        behavior-preserving-refactor) printf '%s\t%s\t%s\n' invariants preserved-invariant INV ;;
        maintenance) printf '%s\t%s\t%s\n' structural-contract structural-outcome STR ;;
        experiment) printf '%s\t%s\t%s\n' experiment-contract experiment EXP ;;
        *) return 1 ;;
    esac
}

contract_declared_in_file() {
    local file=$1 contract=$2 kind location section_name marker_name prefix
    kind=$(awk '/<!--[[:space:]]*change-kind:/ { value=$0; sub("^.*change-kind:[[:space:]]*", "", value); sub("[[:space:]]*-->.*$", "", value); print value; exit }' "$file")
    location=$(contract_location_for_kind "$kind") || return 1
    IFS=$'\t' read -r section_name marker_name prefix <<<"$location"
    [[ $contract == "$prefix"-[0-9]* ]] || return 1
    section_from_file "$file" "$section_name" |
        grep -Eq "<!--[[:space:]]*$marker_name:[[:space:]]*$contract[[:space:]]*-->"
}

contract_declared_in_content() {
    local contract=$1 content kind location section_name marker_name prefix
    content=$(cat)
    kind=$(marker_from_content change-kind <<<"$content" | sed -n '1p')
    location=$(contract_location_for_kind "$kind") || return 1
    IFS=$'\t' read -r section_name marker_name prefix <<<"$location"
    [[ $contract == "$prefix"-[0-9]* ]] || return 1
    section_from_content "$section_name" <<<"$content" |
        grep -Eq "<!--[[:space:]]*$marker_name:[[:space:]]*$contract[[:space:]]*-->"
}

normalize_lifecycle_status() {
    tr -d '\r' | sed -E 's/(<!--[[:space:]]*change-status:)[^>]*(-->)/\1 normalized \2/'
}

repository_root_for_file() {
    local file=$1 root
    root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || return 1
    if command -v cygpath >/dev/null 2>&1; then
        root=$(cygpath -u "$root")
    fi
    realpath -m "$root"
}

repository_relative_path() {
    local root=$1 file=$2 resolved_root resolved_file
    resolved_root=$(realpath -m "$root")
    resolved_file=$(realpath -m "$file")
    case "$resolved_file" in
        "$resolved_root"/*) printf '%s\n' "${resolved_file#"$resolved_root"/}" ;;
        *) return 1 ;;
    esac
}

active_status() {
    case "$1" in approved|in-progress|implemented|completed|superseded) return 0 ;; *) return 1 ;; esac
}

legacy_prerequisite_eligible_file() {
    local file=$1 root rel current_status current_approval base_content base_status
    [[ -n $prerequisite_legacy_base ]] || return 1
    root=$(repository_root_for_file "$file") || return 1
    rel=$(repository_relative_path "$root" "$file") || return 1
    git -C "$root" cat-file -e "$prerequisite_legacy_base:$rel" 2>/dev/null || return 1
    base_content=$(git -C "$root" show "$prerequisite_legacy_base:$rel") || return 1
    [[ -z $(prerequisite_values_from_file "$file") ]] || return 1
    [[ -z $(prerequisite_values_from_content <<<"$base_content") ]] || return 1
    current_status=$(awk '/<!-- change-status:/ { value=$0; sub("^.*change-status:[[:space:]]*", "", value); sub("[[:space:]]*-->.*$", "", value); print value; exit }' "$file")
    current_approval=$(awk '/<!-- approval-source:/ { value=$0; sub("^.*approval-source:[[:space:]]*", "", value); sub("[[:space:]]*-->.*$", "", value); print value; exit }' "$file")
    base_status=$(marker_from_content change-status <<<"$base_content" | sed -n '1p')
    active_status "$current_status" || return 1
    active_status "$base_status" || return 1
    [[ -n $current_approval && $current_approval != none ]] || return 1
    [[ $(normalize_lifecycle_status <"$file") == $(normalize_lifecycle_status <<<"$base_content") ]] || return 1
    printf 'DEPRECATED: unchanged active format-3 record has no change-prerequisite contract: %s\n' "$file"
}

prerequisite_row_ids() {
    local file=$1
    awk -F'|' '
        function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        /^\|/ {
            id=trim($2)
            if (id ~ /^PRE-[0-9]+$/) print id
        }
    ' <<<"$(section_from_file "$file" start-conditions)"
}

prerequisite_row_complete() {
    local file=$1 wanted=$2
    awk -F'|' -v wanted="$wanted" '
        function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        /^\|/ {
            id=trim($2)
            if (id == wanted) {
                guarantee=trim($3); source=trim($4); evidence=trim($5)
                if (guarantee != "" && source != "" && evidence != "" &&
                    guarantee !~ /^<.*>$/ && source !~ /^<.*>$/ && evidence !~ /^<.*>$/) found++
            }
        }
        END { exit(found == 1 ? 0 : 1) }
    ' <<<"$(section_from_file "$file" start-conditions)"
}

resolve_worktree_source() {
    local node=$1 source=$2 root=$3 lexical actual rel
    [[ $source != /* && ! $source =~ ^[A-Za-z]:[/\\] ]] || return 1
    lexical=$(realpath -m "$(dirname "$node")/$source") || return 1
    case "$lexical" in "$root"/*) ;; *) return 1 ;; esac
    [[ -e $lexical ]] || return 1
    [[ ! -L $lexical ]] || return 1
    actual=$(realpath -e "$lexical") || return 1
    [[ $actual == "$lexical" ]] || return 1
    case "$actual" in "$root"/*) ;; *) return 1 ;; esac
    rel=${actual#"$root"/}
    [[ $rel == docs/changes/*/change.md ]] || return 1
    printf '%s\t%s\n' "$actual" "$rel"
}

declare -A structural_visiting=()
declare -A structural_done=()
structural_repo_root=""

validate_structural_prerequisites() {
    local file=$1 resolved values count value id source contract target target_file target_rel row_ids row_id
    resolved=$(realpath -e "$file") || {
        fail "$file: prerequisite record is missing"
        return
    }
    if [[ -n ${structural_done[$resolved]+x} ]]; then return; fi
    if [[ -n ${structural_visiting[$resolved]+x} ]]; then
        fail "$change_file: change prerequisites contain a cycle through $resolved"
        return
    fi
    structural_visiting["$resolved"]=1
    values=$(prerequisite_values_from_file "$resolved")
    count=$(sed '/^[[:space:]]*$/d' <<<"$values" | wc -l | tr -d ' ')
    if (( count == 0 )); then
        if legacy_prerequisite_eligible_file "$resolved"; then
            unset 'structural_visiting[$resolved]'
            structural_done["$resolved"]=1
            return
        fi
        fail "$resolved: missing change-prerequisite declaration; use an explicit approved compatibility base only for an unchanged active record"
        unset 'structural_visiting[$resolved]'
        structural_done["$resolved"]=1
        return
    fi
    grep -Fq '<!-- section: start-conditions -->' "$resolved" ||
        fail "$resolved: missing section marker 'start-conditions'"
    if grep -Fxq none <<<"$values"; then
        (( count == 1 )) || fail "$resolved: 'none' cannot be combined with concrete change prerequisites"
        row_ids=$(prerequisite_row_ids "$resolved")
        [[ -z $row_ids ]] || fail "$resolved: 'none' cannot have PRE rows"
        unset 'structural_visiting[$resolved]'
        structural_done["$resolved"]=1
        return
    fi
    grep -Fq '<!-- section: start-conditions -->' "$resolved" || fail "$resolved: missing section marker 'start-conditions'"
    declare -A seen_ids=()
    while IFS= read -r value; do
        [[ -n $value ]] || continue
        if [[ ! $value =~ ^(PRE-[0-9]+)[[:space:]]+source=([^[:space:]]+)[[:space:]]+contract=((AC|INV|STR|EXP)-[0-9]+)$ ]]; then
            fail "$resolved: malformed change-prerequisite marker '$value'"
            continue
        fi
        id=${BASH_REMATCH[1]}; source=${BASH_REMATCH[2]}; contract=${BASH_REMATCH[3]}
        if [[ -n ${seen_ids[$id]+x} ]]; then
            fail "$resolved: duplicate change-prerequisite ID '$id'"
            continue
        fi
        seen_ids["$id"]=1
        prerequisite_row_complete "$resolved" "$id" || fail "$resolved: $id needs exactly one complete start-condition row"
        if [[ -z $structural_repo_root ]]; then
            structural_repo_root=$(repository_root_for_file "$resolved") || {
                fail "$resolved: concrete change prerequisites require a Git repository"
                continue
            }
            structural_repo_root=$(realpath -m "$structural_repo_root")
        fi
        target=$(resolve_worktree_source "$resolved" "$source" "$structural_repo_root") || {
            fail "$resolved: $id source '$source' must resolve to a non-symlink format-3 docs/changes/**/change.md in the same repository"
            continue
        }
        IFS=$'\t' read -r target_file target_rel <<<"$target"
        [[ $target_file != "$resolved" ]] || {
            fail "$resolved: $id cannot depend on itself"
            continue
        }
        grep -Fq '<!-- change-format: 3 -->' "$target_file" || {
            fail "$resolved: $id source '$source' is not a format-3 change"
            continue
        }
        contract_declared_in_file "$target_file" "$contract" || {
            fail "$resolved: $id references undeclared source contract '$contract'"
            continue
        }
        validate_structural_prerequisites "$target_file"
    done <<<"$values"
    row_ids=$(prerequisite_row_ids "$resolved")
    while IFS= read -r row_id; do
        [[ -n $row_id ]] || continue
        [[ -n ${seen_ids[$row_id]+x} ]] || fail "$resolved: orphan start-condition row '$row_id'"
    done <<<"$row_ids"
    unset 'structural_visiting[$resolved]'
    structural_done["$resolved"]=1
}

git_tree_content() {
    local root=$1 revision=$2 rel=$3 mode
    mode=$(git -C "$root" ls-tree "$revision" -- "$rel" | awk 'NR == 1 { print $1 }')
    [[ $mode == 100644 || $mode == 100755 ]] || return 1
    git -C "$root" show "$revision:$rel"
}

resolve_git_source() {
    local node_rel=$1 source=$2 root=$3 lexical rel
    [[ $source != /* && ! $source =~ ^[A-Za-z]:[/\\] ]] || return 1
    lexical=$(realpath -m "$root/$(dirname "$node_rel")/$source") || return 1
    case "$lexical" in "$root"/*) ;; *) return 1 ;; esac
    rel=${lexical#"$root"/}
    [[ $rel == docs/changes/*/change.md ]] || return 1
    printf '%s\n' "$rel"
}

legacy_prerequisite_eligible_content() {
    local root=$1 rel=$2 current_content=$3 base_content current_status current_approval base_status
    [[ -n $prerequisite_legacy_base ]] || return 1
    base_content=$(git_tree_content "$root" "$prerequisite_legacy_base" "$rel") || return 1
    [[ -z $(prerequisite_values_from_content <<<"$current_content") ]] || return 1
    [[ -z $(prerequisite_values_from_content <<<"$base_content") ]] || return 1
    current_status=$(marker_from_content change-status <<<"$current_content" | sed -n '1p')
    current_approval=$(marker_from_content approval-source <<<"$current_content" | sed -n '1p')
    base_status=$(marker_from_content change-status <<<"$base_content" | sed -n '1p')
    active_status "$current_status" || return 1
    active_status "$base_status" || return 1
    [[ -n $current_approval && $current_approval != none ]] || return 1
    [[ $(normalize_lifecycle_status <<<"$current_content") == $(normalize_lifecycle_status <<<"$base_content") ]] || return 1
    printf 'DEPRECATED: unchanged active format-3 record has no change-prerequisite contract: %s\n' "$rel"
}

declare -A ready_visiting=()
declare -A ready_done=()

validate_ready_source() {
    local root=$1 rel=$2 expected_contract=$3 content status values value source contract child_rel ready_key
    ready_key="$rel|$expected_contract"
    if [[ -n ${ready_done[$ready_key]+x} ]]; then return; fi
    if [[ -n ${ready_visiting[$rel]+x} ]]; then
        fail "$change_file: BLOCKED: baseline $baseline contains a prerequisite cycle through $rel"
        return
    fi
    ready_visiting["$rel"]=1
    content=$(git_tree_content "$root" "$baseline" "$rel") || {
        fail "$change_file: BLOCKED: prerequisite source '$rel' is missing or is not a regular file at $baseline"
        unset 'ready_visiting[$rel]'
        return
    }
    grep -Fq '<!-- change-format: 3 -->' <<<"$content" || fail "$change_file: BLOCKED: prerequisite source '$rel' is not format 3 at $baseline"
    contract_declared_in_content "$expected_contract" <<<"$content" || fail "$change_file: BLOCKED: prerequisite source '$rel' does not declare $expected_contract at $baseline"
    status=$(marker_from_content change-status <<<"$content" | sed -n '1p')
    [[ $status == completed ]] || fail "$change_file: BLOCKED: prerequisite source '$rel' is '$status', not 'completed', at $baseline"
    values=$(prerequisite_values_from_content <<<"$content")
    if [[ -z $values ]]; then
        legacy_prerequisite_eligible_content "$root" "$rel" "$content" ||
            fail "$change_file: BLOCKED: prerequisite source '$rel' lacks a valid prerequisite contract at $baseline"
    elif grep -Fxq none <<<"$values"; then
        [[ $(sed '/^[[:space:]]*$/d' <<<"$values" | wc -l | tr -d ' ') == 1 ]] ||
            fail "$change_file: BLOCKED: prerequisite source '$rel' mixes 'none' with concrete prerequisites"
    else
        while IFS= read -r value; do
            [[ -n $value ]] || continue
            if [[ ! $value =~ ^PRE-[0-9]+[[:space:]]+source=([^[:space:]]+)[[:space:]]+contract=((AC|INV|STR|EXP)-[0-9]+)$ ]]; then
                fail "$change_file: BLOCKED: malformed prerequisite '$value' in '$rel' at $baseline"
                continue
            fi
            source=${BASH_REMATCH[1]}; contract=${BASH_REMATCH[2]}
            child_rel=$(resolve_git_source "$rel" "$source" "$root") || {
                fail "$change_file: BLOCKED: prerequisite source '$source' from '$rel' escapes docs/changes at $baseline"
                continue
            }
            [[ $child_rel != "$rel" ]] || {
                fail "$change_file: BLOCKED: '$rel' depends on itself at $baseline"
                continue
            }
            validate_ready_source "$root" "$child_rel" "$contract"
        done <<<"$values"
    fi
    unset 'ready_visiting[$rel]'
    ready_done["$ready_key"]=1
}

validate_readiness() {
    local root values value source contract rel
    root=$(repository_root_for_file "$change_file") || {
        fail "$change_file: BLOCKED: readiness validation requires a Git repository"
        return
    }
    root=$(realpath -m "$root")
    git -C "$root" rev-parse --verify "$baseline^{commit}" >/dev/null 2>&1 || {
        fail "$change_file: BLOCKED: baseline '$baseline' is not a commit"
        return
    }
    values=$(prerequisite_values_from_file "$change_file")
    [[ -n $values ]] || return 0
    grep -Fxq none <<<"$values" && return
    while IFS= read -r value; do
        [[ -n $value ]] || continue
        [[ $value =~ ^PRE-[0-9]+[[:space:]]+source=([^[:space:]]+)[[:space:]]+contract=((AC|INV|STR|EXP)-[0-9]+)$ ]] || continue
        source=${BASH_REMATCH[1]}; contract=${BASH_REMATCH[2]}
        rel=$(resolve_git_source "$(repository_relative_path "$root" "$change_file")" "$source" "$root") || {
            fail "$change_file: BLOCKED: prerequisite source '$source' escapes docs/changes at $baseline"
            continue
        }
        validate_ready_source "$root" "$rel" "$contract"
    done <<<"$values"
}

[[ -f $change_file ]] || {
    printf 'ERROR: change file not found: %s\n' "$change_file" >&2
    exit 1
}

if ! grep -Fq '<!-- change-format: 3 -->' "$change_file"; then
    # Legacy completion is an explicit, temporary compatibility path. New or
    # revised contracts must migrate to format 3 before validation.
    if (( allow_approved_legacy == 1 )) && legacy_approved; then
        printf 'DEPRECATED: approved format-2 change accepted only for unchanged completion: %s\n' "$change_file"
        exit 0
    fi
    fail "$change_file: expected format 3; use --allow-approved-legacy only to complete an unchanged already-approved legacy contract"
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
        fail "$change_file: $contract_id must have exactly one canonical primary-proof marker (found $primary_count)"
    proof_row_complete "$contract_id" ||
        fail "$change_file: $contract_id needs exactly one Primary proof row with observable assertion and command/procedure"
done <<<"$contract_ids"

if grep -Eqi '^##[[:space:]]+(clarification log|decision ledger|agent log|澄清日志|决策日志|代理日志)' "$change_file"; then
    fail "$change_file: agent/process logs belong outside the human change record"
fi

validate_structural_prerequisites "$change_file"
if (( require_ready == 1 )); then
    validate_readiness
fi

(( errors == 0 )) || exit 1
printf 'OK: change handoff is structurally complete: %s\n' "$change_file"
