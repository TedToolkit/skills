#!/usr/bin/env bash
set -euo pipefail

area=${1:-}
case "$area" in
    preparations|runs|worktrees) ;;
    *)
        printf 'ERROR: usage: ensure-tool-state.sh <preparations|runs|worktrees>\n' >&2
        exit 2
        ;;
esac

root=$(git rev-parse --show-toplevel)
if command -v cygpath >/dev/null 2>&1; then
    root=$(cygpath -u "$root")
fi
namespace="$root/.tedtoolkit"
ignore_file="$namespace/.gitignore"
mkdir -p "$namespace"
touch "$ignore_file"

append_rule() {
    local rule=$1
    grep -Fxq "$rule" "$ignore_file" && return 0
    if [[ -s $ignore_file ]] && [[ $(tail -c 1 "$ignore_file" | wc -l) -eq 0 ]]; then
        printf '\n' >>"$ignore_file"
    fi
    printf '%s\n' "$rule" >>"$ignore_file"
}

append_rule '/worktrees/'
append_rule '/runs/'

target="$namespace/$area"
mkdir -p "$target"
printf '%s\n' "$target"
