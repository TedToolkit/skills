#!/usr/bin/env bash
set -euo pipefail

fail() {
    printf 'BLOCKED: %s\n' "$*" >&2
    exit 1
}

delete=0
retention_policy=""
durable_extraction_confirmed=0
while (( $# > 0 )); do
    case "$1" in
        --delete)
            delete=1
            shift
            ;;
        --retention-policy)
            [[ $# -ge 2 ]] || fail "--retention-policy requires cleanup or retain"
            retention_policy=$2
            shift 2
            ;;
        --durable-extraction-confirmed)
            durable_extraction_confirmed=1
            shift
            ;;
        --*) fail "unsupported option: $1" ;;
        *) break ;;
    esac
done

[[ $# == 1 ]] || fail "usage: cleanup-change.sh --retention-policy <cleanup|retain> [--durable-extraction-confirmed] [--delete] <change.md>"
case "$retention_policy" in
    cleanup) ;;
    retain) fail "explicit repository policy requires retaining this change record" ;;
    *) fail "--retention-policy must explicitly be cleanup or retain" ;;
esac

change_file=$1
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "not inside a Git repository"
repo_root=$(cd "$repo_root" && pwd -P)
[[ -e $change_file ]] || fail "change record not found: $change_file"
changes_root="$repo_root/docs/changes"
lexical_abs=$(realpath -ms -- "$change_file")
lexical_dir=$(dirname "$lexical_abs")

[[ $(basename "$lexical_abs") == change.md ]] ||
    fail "target must be docs/changes/<stable-slug>/change.md: $change_file"
[[ $(dirname "$lexical_dir") == "$changes_root" ]] ||
    fail "target must be one direct child of docs/changes/: $change_file"
for component in "$repo_root/docs" "$changes_root" "$lexical_dir" "$lexical_abs"; do
    [[ ! -L $component ]] || fail "cleanup path must not contain a symbolic link: $component"
done
change_abs=$(realpath -- "$change_file")
change_dir=$(dirname "$change_abs")
[[ $change_abs == "$lexical_abs" && $change_dir == "$lexical_dir" ]] ||
    fail "canonical target differs from the exact authorized path: $change_file"

change_rel=${change_abs#"$repo_root"/}
change_dir_rel=${change_dir#"$repo_root"/}
[[ $change_rel != "$change_abs" && $change_dir_rel != "$change_dir" ]] ||
    fail "target escapes the repository: $change_file"
git -C "$repo_root" ls-files --error-unmatch -- "$change_rel" >/dev/null 2>&1 ||
    fail "change record is not tracked: $change_rel"

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

format=$(marker_value "$change_abs" change-format)
status=$(marker_value "$change_abs" change-status)
[[ $format == 3 ]] || fail "automatic cleanup supports structurally valid format-3 records only"
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
bash "$script_dir/validate-acceptance-specification.sh" "$change_abs" >/dev/null ||
    fail "change record is not a structurally valid format-3 handoff: $change_rel"
case "$status" in
    completed) ;;
    superseded)
        (( durable_extraction_confirmed == 1 )) ||
            fail "superseded cleanup requires confirmed durable extraction disposition"
        ;;
    *) fail "change status '$status' is not eligible for cleanup" ;;
esac

target_state=$(git -C "$repo_root" status --porcelain=v1 --ignored=matching --untracked-files=all -- "$change_dir_rel")
[[ -z $target_state ]] || fail "target subtree has staged, unstaged, untracked, or ignored content: $change_dir_rel"

history_commit=$(git -C "$repo_root" rev-parse --verify 'HEAD^{commit}' 2>/dev/null) ||
    fail "repository has no commit containing the terminal change record"
git -C "$repo_root" cat-file -e "$history_commit:$change_rel" 2>/dev/null ||
    fail "terminal change record is not present in Git history at HEAD: $change_rel"
git -C "$repo_root" diff --quiet "$history_commit" -- "$change_dir_rel" ||
    fail "target subtree differs from its Git-recorded state at HEAD: $change_dir_rel"

while IFS= read -r -d '' dependent_abs; do
    dependent=${dependent_abs#"$repo_root"/}
    [[ $dependent != "$change_rel" ]] || continue
    while IFS= read -r source; do
        [[ -n $source ]] || continue
        source_abs=$(realpath -m -- "$repo_root/$(dirname "$dependent")/$source")
        [[ $source_abs != "$change_abs" ]] ||
            fail "change is still referenced by prerequisite marker in $dependent"
    done < <(awk '
        index($0, "<!-- change-prerequisite:") && match($0, /source=[^[:space:]>]+/) {
            value=substr($0, RSTART + 7, RLENGTH - 7)
            print value
        }
    ' "$dependent_abs")
done < <(find "$changes_root" -mindepth 2 -maxdepth 2 -type f -name change.md -print0)

preparations_root="$repo_root/.tedtoolkit/preparations"
while IFS= read -r -d '' preparation_abs; do
    preparation=${preparation_abs#"$repo_root"/}
    if grep -Fq "$change_rel" "$preparation_abs"; then
        fail "change is still referenced by preparation record $preparation"
    fi
done < <(if [[ -d $preparations_root ]]; then find "$preparations_root" -type f -print0; fi)

if (( delete == 0 )); then
    printf 'ELIGIBLE: %s can be removed after explicit cleanup authorization\n' "$change_dir_rel"
    exit 0
fi

rm -rf -- "$change_dir"
[[ ! -e $change_dir ]] || fail "failed to remove exact change directory: $change_dir_rel"
printf 'REMOVED: %s; recoverable from Git history at %s\n' "$change_dir_rel" "$history_commit"
