[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]] $Paths,

    [Parameter(ValueFromPipeline = $true)]
    [AllowEmptyString()]
    [string] $MessageLine
)

begin {
    $ErrorActionPreference = 'Stop'
    $originalInputEncoding = [Console]::InputEncoding
    $originalOutputEncoding = $OutputEncoding
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [Console]::InputEncoding = $utf8NoBom
    $OutputEncoding = $utf8NoBom
    $messageLines = [System.Collections.Generic.List[string]]::new()
    $canonical = Join-Path $PSScriptRoot 'commit_group.sh'
    if (-not (Test-Path -LiteralPath $canonical -PathType Leaf)) {
        [Console]::Error.WriteLine("commit_group: canonical helper is missing beside the Windows launcher")
        exit 1
    }

    $override = [Environment]::GetEnvironmentVariable('TEDTOOLKIT_GIT_BASH')
    if ($override) {
        if (-not (Test-Path -LiteralPath $override -PathType Leaf)) {
            [Console]::Error.WriteLine("commit_group: TEDTOOLKIT_GIT_BASH does not name an executable file")
            exit 1
        }
        $bash = $override
    } else {
        $roots = [System.Collections.Generic.List[string]]::new()
        $git = Get-Command git.exe -ErrorAction SilentlyContinue
        if ($git) {
            $roots.Add((Split-Path (Split-Path $git.Source -Parent) -Parent))
        }
        if ($env:ProgramFiles) { $roots.Add((Join-Path $env:ProgramFiles 'Git')) }
        $command = Get-Command bash.exe -ErrorAction SilentlyContinue
        if ($command) {
            $roots.Add((Split-Path (Split-Path $command.Source -Parent) -Parent))
        }
        $gitRoot = $roots | Where-Object {
            (Test-Path -LiteralPath (Join-Path $_ 'bin\bash.exe') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $_ 'usr\bin\cygpath.exe') -PathType Leaf) -and
            ((Test-Path -LiteralPath (Join-Path $_ 'mingw64\bin\git.exe') -PathType Leaf) -or
             (Test-Path -LiteralPath (Join-Path $_ 'mingw32\bin\git.exe') -PathType Leaf))
        } | Select-Object -First 1
        if ($gitRoot) {
            $bash = Join-Path $gitRoot 'bin\bash.exe'
            $env:PATH = "$(Join-Path $gitRoot 'cmd');$(Join-Path $gitRoot 'bin');$env:PATH"
        }
    }

    if (-not $bash) {
        [Console]::Error.WriteLine("commit_group: Git Bash could not be located; install Git for Windows or set TEDTOOLKIT_GIT_BASH")
        exit 1
    }
}

process {
    if ($PSBoundParameters.ContainsKey('MessageLine')) {
        $messageLines.Add($MessageLine)
    }
}

end {
    try {
        if ($messageLines.Count -gt 0) {
            ($messageLines -join [Environment]::NewLine) | & $bash $canonical @Paths
        } else {
            & $bash $canonical @Paths
        }
        $exitCode = $LASTEXITCODE
    } finally {
        [Console]::InputEncoding = $originalInputEncoding
        $OutputEncoding = $originalOutputEncoding
    }
    exit $exitCode
}
