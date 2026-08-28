[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$canonical = Join-Path $PSScriptRoot 'premerge_guard.sh'
if (-not (Test-Path -LiteralPath $canonical -PathType Leaf)) {
    [Console]::Error.WriteLine('premerge_guard: canonical helper is missing beside the Windows launcher')
    exit 1
}

$override = [Environment]::GetEnvironmentVariable('TEDTOOLKIT_GIT_BASH')
if ($override) {
    if (-not (Test-Path -LiteralPath $override -PathType Leaf)) {
        [Console]::Error.WriteLine('premerge_guard: TEDTOOLKIT_GIT_BASH does not name an executable file')
        exit 1
    }
    $bash = $override
} else {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $git = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($git) {
        $gitRoot = Split-Path (Split-Path $git.Source -Parent) -Parent
        $candidates.Add((Join-Path $gitRoot 'bin\bash.exe'))
    }
    if ($env:ProgramFiles) { $candidates.Add((Join-Path $env:ProgramFiles 'Git\bin\bash.exe')) }
    $command = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($command -and (Test-Path -LiteralPath (Join-Path (Split-Path $command.Source -Parent) 'cygpath.exe') -PathType Leaf)) {
        $candidates.Add($command.Source)
    }
    $bash = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
}

if (-not $bash) {
    [Console]::Error.WriteLine('premerge_guard: Git Bash could not be located; install Git for Windows or set TEDTOOLKIT_GIT_BASH')
    exit 1
}

& $bash $canonical
exit $LASTEXITCODE
