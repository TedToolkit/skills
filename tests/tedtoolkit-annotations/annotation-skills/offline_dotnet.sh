#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == restore ]]; then
    exit 0
fi

if [[ ${1:-} != run ]]; then
    echo "offline dotnet stub: unsupported command" >&2
    exit 2
fi

case "$(basename "$PWD")" in
    behavior-pass)
        printf '%s\n' 'total: 1' 'succeeded: 1' 'failed: 0' 'skipped: 0'
        exit 0
        ;;
    behavior-fail)
        printf '%s\n' 'total: 1' 'succeeded: 0' 'failed: 1' 'skipped: 0'
        exit 1
        ;;
    behavior-zero)
        printf '%s\n' 'total: 0' 'succeeded: 0' 'failed: 0' 'skipped: 0'
        exit 0
        ;;
    *)
        echo "offline dotnet stub: unexpected fixture directory" >&2
        exit 2
        ;;
esac
