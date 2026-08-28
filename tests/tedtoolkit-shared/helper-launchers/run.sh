#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:?usage: run.sh <repository-root>}"
scripts="$repo_root/plugins/tedtoolkit-shared/scripts"
fixture=$(mktemp -d "${TMPDIR:-/tmp}/helper-launchers.XXXXXX")
trap 'rm -rf -- "$fixture"' EXIT
unset CLAUDE_PLUGIN_ROOT TEDTOOLKIT_PLUGIN_ROOT

fail() { echo "helper launcher check failed: $*" >&2; exit 1; }

remote="$fixture/origin.git"
git init -q --bare "$remote"
seed="$fixture/seed"
git clone -q "$remote" "$seed"
git -C "$seed" switch -qc main
git -C "$seed" config user.name Fixture
git -C "$seed" config user.email fixture@example.com
printf 'base\n' >"$seed/base.txt"
git -C "$seed" add base.txt
git -C "$seed" commit -qm base
git -C "$seed" push -q -u origin main
git --git-dir="$remote" symbolic-ref HEAD refs/heads/main

make_repo() {
    local target=$1
    git clone -q "$remote" "$target"
    git -C "$target" config user.name Fixture
    git -C "$target" config user.email fixture@example.com
}

bash_repo="$fixture/bash-repo"
pwsh_repo="$fixture/pwsh-repo"
legacy_repo="$fixture/windows-powershell-repo"
make_repo "$bash_repo"
make_repo "$pwsh_repo"
make_repo "$legacy_repo"

fake_bin="$fixture/cygwin64/bin"
mkdir -p "$fake_bin"
for decoy in bash.exe cygpath.exe git.exe; do
    cp "$(cygpath -u "$COMSPEC")" "$fake_bin/$decoy"
done

bash_branch=$(cd "$bash_repo" && bash "$scripts/default_branch.sh")
ps_launcher=$(cygpath -w "$scripts/default_branch.ps1")
pwsh_branch=$(cd "$pwsh_repo" && PATH="$fake_bin:$PATH" pwsh.exe -NoProfile -File "$ps_launcher" | tr -d '\r')
[[ "$bash_branch" == main && "$pwsh_branch" == main ]] || fail "default branch launchers disagree"

ps_guard=$(cygpath -w "$scripts/premerge_guard.ps1")
bash_guard=$(cd "$bash_repo" && bash "$scripts/premerge_guard.sh")
pwsh_guard=$(cd "$pwsh_repo" && PATH="$fake_bin:$PATH" pwsh.exe -NoProfile -File "$ps_guard" | tr -d '\r')
[[ "$bash_guard" == CLEAN_WORKTREE && "$pwsh_guard" == CLEAN_WORKTREE ]] || fail "pre-merge guard launchers disagree"

message_file="$fixture/message.txt"
printf '%s\n\n%s\n' '🧪 test(portability): preserve literal input' 'Keep $HOME, `text`, and 中文 literal.' >"$message_file"
for target in "$bash_repo" "$pwsh_repo" "$legacy_repo"; do
    printf 'selected\n' >"$target/selected.txt"
    printf 'outside staged\n' >"$target/outside-staged.txt"
    printf 'outside worktree\n' >"$target/outside-worktree.txt"
    git -C "$target" add outside-staged.txt
done

(cd "$bash_repo" && bash "$scripts/commit_group.sh" selected.txt <"$message_file")
ps_commit=$(cygpath -w "$scripts/commit_group.ps1")
(cd "$pwsh_repo" && PATH="$fake_bin:$PATH" pwsh.exe -NoProfile -File "$ps_commit" selected.txt <"$message_file")
(cd "$legacy_repo" && PATH="$fake_bin:$PATH" powershell.exe -NoProfile -File "$ps_commit" selected.txt <"$message_file")

for target in "$bash_repo" "$pwsh_repo" "$legacy_repo"; do
    [[ $(git -C "$target" show --format= --name-only HEAD) == selected.txt ]] || fail "launcher widened commit membership"
    git -C "$target" diff --cached --quiet -- outside-staged.txt && fail "launcher lost unrelated staged state"
    [[ -f "$target/outside-worktree.txt" ]] || fail "launcher lost unrelated worktree state"
    git -C "$target" log -1 --format=%B >"$target/message.actual"
    grep -Fq 'Keep $HOME, `text`, and 中文 literal.' "$target/message.actual" || fail "launcher changed literal commit input"
done
cmp "$bash_repo/message.actual" "$pwsh_repo/message.actual" || fail "launcher commit messages differ"
cmp "$bash_repo/message.actual" "$legacy_repo/message.actual" || fail "Windows PowerShell changed UTF-8 commit input"

before=$(git -C "$pwsh_repo" rev-parse HEAD)
if (cd "$pwsh_repo" && pwsh.exe -NoProfile -File "$ps_commit" </dev/null >/dev/null 2>&1); then
    fail "Windows launcher accepted missing commit paths"
fi
[[ $(git -C "$pwsh_repo" rev-parse HEAD) == "$before" ]] || fail "invalid invocation changed history"

if (cd "$pwsh_repo" && TEDTOOLKIT_GIT_BASH='Z:\definitely-missing\bash.exe' pwsh.exe -NoProfile -File "$ps_launcher" >/dev/null 2>&1); then
    fail "Windows launcher ignored an unusable explicit runtime"
fi
[[ $(git -C "$pwsh_repo" rev-parse HEAD) == "$before" ]] || fail "runtime failure changed history"

if (cd "$pwsh_repo" && TEDTOOLKIT_GIT_BASH='Z:\definitely-missing\bash.exe' pwsh.exe -NoProfile -File "$ps_guard" >/dev/null 2>&1); then
    fail "Windows guard launcher ignored an unusable explicit runtime"
fi
[[ $(git -C "$pwsh_repo" rev-parse HEAD) == "$before" ]] || fail "guard runtime failure changed history"

mkdir "$fixture/isolated"
cp "$scripts/default_branch.ps1" "$fixture/isolated/"
isolated=$(cygpath -w "$fixture/isolated/default_branch.ps1")
if (cd "$pwsh_repo" && pwsh.exe -NoProfile -File "$isolated" >/dev/null 2>&1); then
    fail "Windows launcher guessed a missing canonical helper location"
fi

echo "helper launcher parity checks passed"
