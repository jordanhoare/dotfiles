#Requires -Version 5.1

<#
.SYNOPSIS
Windows-side activation for this dotfiles repo, run by 'mise run apply'.
Counterpart to the Home Manager activation on Linux/WSL/macOS. Intentionally nix-agnostic.

.DESCRIPTION
Runs 'winget import' against win/winget.json and installs the configs managed
cross-platform: Zed, mise, uv, git, ssh and Claude Code. Files mutated at runtime (e.g.
settings.json, which it rewrites with wsl_connections recent-project paths)
are copied so local writes never bleed back into the repo. Static files are
symlinked. Idempotent: re-running is safe. Real files at a symlink target are
moved to '<name>.bak.<timestamp>' before being replaced with a symlink; copy
targets are overwritten unconditionally so the repo is the source of truth.

Requires either Administrator elevation or Windows Developer Mode for
symlink creation. Both preconditions are checked before any work runs.
#>

$ErrorActionPreference = 'Stop'

$elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$devModeKey = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue
$devMode = $devModeKey.AllowDevelopmentWithoutDevLicense -eq 1

if (-not ($elevated -or $devMode)) {
    Write-Host 'Symlink creation requires elevation or Developer Mode.' -ForegroundColor Red
    Write-Host 'Either:'
    Write-Host '  - Re-run this script from an elevated PowerShell, or'
    Write-Host '  - Enable Developer Mode in Settings > For developers, then re-run.'
    exit 1
}

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$wingetManifest = Join-Path $PSScriptRoot 'winget.json'
Write-Host "Importing winget packages from $wingetManifest" -ForegroundColor Cyan
# Upgrades belong to 'mise run upgrade'; apply only installs what the manifest lacks.
winget import --import-file $wingetManifest --no-upgrade --accept-package-agreements --accept-source-agreements

# Mode: 'Symlink' for files the app treats as read-only; 'Copy' for files the
# app rewrites at runtime, so local writes never bleed back into the repo.
$links = @(
    @{ Source = Join-Path $repo 'config\zed\settings.json'; Target = Join-Path $env:APPDATA 'Zed\settings.json'; Mode = 'Copy' }
    @{ Source = Join-Path $repo 'config\zed\keymap.json';   Target = Join-Path $env:APPDATA 'Zed\keymap.json';   Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\zed\tasks.json';    Target = Join-Path $env:APPDATA 'Zed\tasks.json';    Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\zed\snippets';      Target = Join-Path $env:APPDATA 'Zed\snippets';      Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'win\wslconfig';            Target = Join-Path $env:USERPROFILE '.wslconfig';    Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'win\mise.toml';                       Target = Join-Path $env:USERPROFILE '.config\mise\config.toml';             Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\uv\uv.toml';                   Target = Join-Path $env:APPDATA 'uv\uv.toml';                                Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\git\config';                   Target = Join-Path $env:USERPROFILE '.config\git\config';                   Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\git\attributes';               Target = Join-Path $env:USERPROFILE '.config\git\attributes';               Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\git\personal';                 Target = Join-Path $env:USERPROFILE '.config\git\personal';                 Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'config\git\hooks\agent-push-guard';   Target = Join-Path $env:USERPROFILE '.config\git\hooks\agent-push-guard';   Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'home\.ssh\config';                    Target = Join-Path $env:USERPROFILE '.ssh\config';                           Mode = 'Copy' }
    @{ Source = Join-Path $repo 'home\.claude\AGENTS.md';              Target = Join-Path $env:USERPROFILE '.claude\AGENTS.md';                     Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'home\.claude\CLAUDE.md';              Target = Join-Path $env:USERPROFILE '.claude\CLAUDE.md';                     Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'home\.claude\settings.json';          Target = Join-Path $env:USERPROFILE '.claude\settings.json';                 Mode = 'Copy' }    # /model writes here; a link would dirty the repo
    @{ Source = Join-Path $repo 'home\.claude\hooks';                  Target = Join-Path $env:USERPROFILE '.claude\hooks';                         Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'home\.claude\output-styles';          Target = Join-Path $env:USERPROFILE '.claude\output-styles';                 Mode = 'Symlink' }
)

Get-ChildItem -Directory (Join-Path $repo 'home\.claude\skills') | ForEach-Object {
    Get-ChildItem -Directory $_.FullName | ForEach-Object {
        $links += @{ Source = $_.FullName; Target = Join-Path $env:USERPROFILE ".claude\skills\$($_.Name)"; Mode = 'Symlink' }
    }
}

function Backup-RealFile($target) {
    $backup = "$target.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -LiteralPath $target -Destination $backup
    return $backup
}

function Install-Copy($source, $target, $existing) {
    if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
        Remove-Item -LiteralPath $target -Force
    }
    Copy-Item -LiteralPath $source -Destination $target -Force
    Write-Host "copy   $target <- $source" -ForegroundColor Green
}

function Install-Symlink($source, $target, $existing) {
    if ($null -eq $existing) {
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "link   $target -> $source" -ForegroundColor Green
        return
    }
    if ($existing.LinkType -ne 'SymbolicLink') {
        $backup = Backup-RealFile $target
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "backup $target -> $backup, then linked to $source" -ForegroundColor Yellow
        return
    }
    $currentTarget = $existing.Target
    if ($currentTarget -is [array]) { $currentTarget = $currentTarget[0] }
    if ((Resolve-Path -LiteralPath $currentTarget -ErrorAction SilentlyContinue).Path -eq $source) {
        Write-Host "ok     $target" -ForegroundColor DarkGray
        return
    }
    Remove-Item -LiteralPath $target -Force
    New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    Write-Host "relink $target -> $source (was: $currentTarget)" -ForegroundColor Yellow
}

foreach ($link in $links) {
    if (-not (Test-Path -LiteralPath $link.Source)) {
        Write-Host "skip   $($link.Target) (source missing: $($link.Source))" -ForegroundColor Yellow
        continue
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $link.Target) -Force | Out-Null
    $existing = Get-Item -LiteralPath $link.Target -Force -ErrorAction SilentlyContinue
    if ($link.Mode -eq 'Copy') {
        Install-Copy $link.Source $link.Target $existing
    } else {
        Install-Symlink $link.Source $link.Target $existing
    }
}

$shims = Join-Path $env:LOCALAPPDATA 'mise\shims'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $shims) {
    [Environment]::SetEnvironmentVariable('Path', "$shims;$userPath", 'User')
    Write-Host "path   prepended $shims (open a new shell)" -ForegroundColor Green
} else {
    Write-Host "ok     $shims on PATH" -ForegroundColor DarkGray
}

# Runtimes come from mise. nvm for Windows writes itself into the
# machine Path, which Windows searches before the user Path, so its node.exe
# outranks mise's shims and tools that resolve `node` by Path pick the wrong
# runtime. Strip its Path entries and variables from both scopes. Machine
# scope needs elevation; Developer Mode alone only covers the user scope.
$strayRuntimePaths = @('C:\ProgramData\nvm', 'C:\nvm4w\nodejs')
$strayRuntimeVars = @('NVM_HOME', 'NVM_SYMLINK')
foreach ($scope in @('User', 'Machine')) {
    if ($scope -eq 'Machine' -and -not $elevated) {
        $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine') -split ';'
        if ($machinePath | Where-Object { $strayRuntimePaths -contains $_ }) {
            Write-Host 'warn   machine Path still lists nvm for Windows: re-run elevated to remove it' -ForegroundColor Yellow
        }
        continue
    }
    $current = [Environment]::GetEnvironmentVariable('Path', $scope) -split ';' | Where-Object { $_ -ne '' }
    $kept = $current | Where-Object { $strayRuntimePaths -notcontains $_ }
    if ($kept.Count -ne $current.Count) {
        [Environment]::SetEnvironmentVariable('Path', ($kept -join ';'), $scope)
        Write-Host "path   removed nvm for Windows from the $scope Path" -ForegroundColor Green
    }
    foreach ($name in $strayRuntimeVars) {
        if ($null -ne [Environment]::GetEnvironmentVariable($name, $scope)) {
            [Environment]::SetEnvironmentVariable($name, $null, $scope)
            Write-Host "env    removed $name ($scope)" -ForegroundColor Green
        }
    }
}
if (winget list --id CoreyButler.NVMforWindows --exact --accept-source-agreements 2>$null | Select-String 'CoreyButler.NVMforWindows') {
    Write-Host 'warn   nvm for Windows is installed; runtimes come from mise: winget uninstall --id CoreyButler.NVMforWindows' -ForegroundColor Yellow
}

if (-not (Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.ssh\personal'))) {
    Write-Host "warn   ~/.ssh/personal missing: run 'mise run secrets' so git@personal remotes resolve" -ForegroundColor Yellow
}

$gitconfig = Join-Path $env:USERPROFILE '.gitconfig'
if ((Test-Path -LiteralPath $gitconfig) -and (git config --file $gitconfig --get user.email)) {
    Write-Host 'warn   ~/.gitconfig sets [user], which overrides ~/.config/git/personal: remove that section' -ForegroundColor Yellow
}

Write-Host 'Done.' -ForegroundColor Cyan
