#!/usr/bin/env bash
set -euo pipefail

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

[[ $# == 1 ]] || fail "usage: resolve-change-step.sh <change.md>"
change_file=$1
[[ -f $change_file ]] || fail "change record not found: $change_file"

marker_value() {
    local file=$1 marker=$2 values count
    values=$(awk -v marker="$marker" '
        index($0, "<!-- " marker ":") {
            value=$0
            sub("^.*<!-- " marker ":[[:space:]]*", "", value)
            sub("[[:space:]]*-->.*$", "", value)
            print value
        }
    ' "$file")
    count=$(grep -cve '^[[:space:]]*$' <<<"$values" || true)
    [[ $count == 1 ]] || fail "$file: expected exactly one '$marker' marker"
    printf '%s\n' "$values"
}

require_candidate_binding() {
    local binding=$1
    [[ $binding =~ ^commit:([0-9a-f]{40}|[0-9a-f]{64})$ ||
       $binding =~ ^workspace:([0-9a-f]{40}|[0-9a-f]{64}):sha256:[0-9a-f]{64}$ ]] ||
        fail "$change_file: candidate-binding must identify a full commit or frozen workspace digest"
}

format=$(marker_value "$change_file" change-format)
profile=$(marker_value "$change_file" workflow-profile)
status=$(marker_value "$change_file" change-status)
shape=$(marker_value "$change_file" delivery-shape)
approval=$(marker_value "$change_file" approval-source)

[[ $format == 3 ]] || fail "$change_file: only format-3 change records are resumable"
case "$profile" in standard|controlled) ;; *) fail "$change_file: unsupported workflow profile '$profile'" ;; esac
case "$shape" in single|multi-item) ;; *) fail "$change_file: unsupported delivery shape '$shape'" ;; esac
case "$status" in
    draft|approved|in-progress|candidate-ready|implemented|completed|superseded) ;;
    *) fail "$change_file: unsupported change status '$status'" ;;
esac
[[ $profile != standard || $shape == single ]] || fail "$change_file: Standard changes must use a single delivery"
[[ $shape != multi-item || $profile == controlled ]] || fail "$change_file: multi-item delivery requires a Controlled profile"

if [[ $status == draft ]]; then
    [[ $approval == none ]] || fail "$change_file: Draft approval-source must be 'none'"
else
    [[ -n $approval && $approval != none ]] || fail "$change_file: non-Draft status requires an explicit approval source"
fi

change_dir=$(cd "$(dirname "$change_file")" && pwd)
map_file="$change_dir/work-items.md"
action=
reason=

case "$status" in
    draft)
        action=request-change-approval
        reason="the change contract is Draft and cannot advance without explicit approval"
        ;;
    completed|superseded)
        action=none
        reason="the change lifecycle is terminal"
        ;;
    candidate-ready)
        candidate_binding=$(marker_value "$change_file" candidate-binding)
        require_candidate_binding "$candidate_binding"
        action=review-implementation
        reason="the exact implementation candidate is ready for candidate-bound review"
        ;;
    implemented)
        candidate_binding=$(marker_value "$change_file" candidate-binding)
        require_candidate_binding "$candidate_binding"
        action=complete-change
        reason="implementation review passed and closure checks remain"
        ;;
    approved|in-progress)
        if [[ $shape == single ]]; then
            [[ ! -e $map_file ]] || fail "$change_file: a single delivery must not have work-items.md"
            action=implement-change
            reason="the approved single delivery requires no work-item map"
        elif [[ ! -e $map_file ]]; then
            [[ $status == approved ]] || fail "$change_file: an in-progress multi-item change is missing work-items.md"
            action=plan-work-items
            reason="the approved multi-item delivery has no work-item map"
        else
            map_approval=$(marker_value "$map_file" approval-source)
            if [[ $map_approval == none ]]; then
                [[ $status == approved ]] || fail "$change_file: an in-progress delivery map is not approved"
                action=request-work-item-map-approval
                reason="the work-item map is Draft and requires explicit approval"
            else
                action=orchestrate-work-items
                reason="the Controlled delivery has an approved work-item map"
            fi
        fi
        ;;
esac

printf 'change=%s\n' "$change_file"
printf 'status=%s\n' "$status"
printf 'delivery-shape=%s\n' "$shape"
printf 'next-action=%s\n' "$action"
printf 'reason=%s\n' "$reason"
