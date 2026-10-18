#Requires -Version 5.1

<#
.SYNOPSIS
Windows-side activation for this dotfiles repo. Counterpart to 'make switch'
on Linux/WSL/macOS. Intentionally nix-agnostic. See ADR 0011 and ADR 0014.

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
winget import --import-file $wingetManifest --accept-package-agreements --accept-source-agreements

# --- install manifest ---
# parallel to nix/modules/zed.nix - keep both in sync when adding entries.
# Mode = 'Symlink' for files the app treats as read-only config; 'Copy' for
# files the app mutates at runtime (one-way push from repo, local writes lost
# on next bootstrap).

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
    @{ Source = Join-Path $repo 'home\.claude\settings.json';          Target = Join-Path $env:USERPROFILE '.claude\settings.json';                 Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'home\.claude\hooks';                  Target = Join-Path $env:USERPROFILE '.claude\hooks';                         Mode = 'Symlink' }
    @{ Source = Join-Path $repo 'home\.claude\output-styles';          Target = Join-Path $env:USERPROFILE '.claude\output-styles';                 Mode = 'Symlink' }
)

Get-ChildItem -Directory (Join-Path $repo 'home\.claude\skills') | ForEach-Object {
    Get-ChildItem -Directory $_.FullName | ForEach-Object {
        $links += @{ Source = $_.FullName; Target = Join-Path $env:USERPROFILE ".claude\skills\$($_.Name)"; Mode = 'Symlink' }
    }
}

foreach ($link in $links) {
    $source = $link.Source
    $target = $link.Target
    $mode = $link.Mode

    if (-not (Test-Path -LiteralPath $source)) {
        Write-Host "skip   $target (source missing: $source)" -ForegroundColor Yellow
        continue
    }

    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $existing = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue

    if ($mode -eq 'Copy') {
        if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
            Remove-Item -LiteralPath $target -Force
        }
        Copy-Item -LiteralPath $source -Destination $target -Force
        Write-Host "copy   $target <- $source" -ForegroundColor Green
        continue
    }

    if ($null -eq $existing) {
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "link   $target -> $source" -ForegroundColor Green
        continue
    }

    if ($existing.LinkType -eq 'SymbolicLink') {
        $currentTarget = $existing.Target
        if ($currentTarget -is [array]) { $currentTarget = $currentTarget[0] }

        if ((Resolve-Path -LiteralPath $currentTarget -ErrorAction SilentlyContinue).Path -eq $source) {
            Write-Host "ok     $target" -ForegroundColor DarkGray
            continue
        }

        Remove-Item -LiteralPath $target -Force
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "relink $target -> $source (was: $currentTarget)" -ForegroundColor Yellow
        continue
    }

    $backup = "$target.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item -LiteralPath $target -Destination $backup
    New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    Write-Host "backup $target -> $backup, then linked to $source" -ForegroundColor Yellow
}

$shims = Join-Path $env:LOCALAPPDATA 'mise\shims'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $shims) {
    [Environment]::SetEnvironmentVariable('Path', "$shims;$userPath", 'User')
    Write-Host "path   prepended $shims (open a new shell)" -ForegroundColor Green
} else {
    Write-Host "ok     $shims on PATH" -ForegroundColor DarkGray
}

if (-not (Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.ssh\personal'))) {
    Write-Host 'warn   ~/.ssh/personal missing: run win\secrets.ps1 so git@personal remotes resolve' -ForegroundColor Yellow
}

$gitconfig = Join-Path $env:USERPROFILE '.gitconfig'
if ((Test-Path -LiteralPath $gitconfig) -and (git config --file $gitconfig --get user.email)) {
    Write-Host 'warn   ~/.gitconfig sets [user], which overrides ~/.config/git/personal: remove that section' -ForegroundColor Yellow
}

Write-Host 'Done.' -ForegroundColor Cyan
