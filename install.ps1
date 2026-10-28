#Requires -Version 5.1
<#
.SYNOPSIS
Entry point for a fresh Windows machine:
  irm https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.ps1 | iex

.DESCRIPTION
Does only what must happen before the clone: git, mise, pwsh, the clone itself.
Everything after that is a mise task under .mise\; 'mise run bootstrap' runs
win\apply.ps1, which needs elevation or Developer Mode.
#>

$ErrorActionPreference = 'Stop'

$dotfiles = 'D:\repositories\dotfiles'

# mise runs every .ps1 task through pwsh, so PowerShell 7 must exist before 'mise run bootstrap'.
foreach ($id in 'Git.Git', 'jdx.mise', 'Microsoft.PowerShell') {
    if (-not (winget list --id $id --exact --accept-source-agreements 2>$null | Select-String $id)) {
        winget install --id $id --exact --accept-package-agreements --accept-source-agreements
    }
}

# winget edits the registry Path; this process still has the old one.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

if (-not (Test-Path -LiteralPath (Join-Path $dotfiles '.git'))) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $dotfiles) -Force | Out-Null
    git clone https://github.com/jordanhoare/dotfiles.git $dotfiles
}

Set-Location $dotfiles
mise run bootstrap
