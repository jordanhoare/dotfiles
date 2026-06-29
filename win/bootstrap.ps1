#Requires -Version 5.1

<#
.SYNOPSIS
Windows-side activation for this dotfiles repo. Counterpart to 'make switch'
on Linux/WSL/macOS. Intentionally nix-agnostic. See ADR 0011.

.DESCRIPTION
Runs 'winget import' against win/winget.json and creates per-file repo-rooted
symlinks for the editor configs managed cross-platform (Ghostty, Zed).
Idempotent: re-running is safe. Real files at a target path are moved to
'<name>.bak.<timestamp>' before being replaced with a symlink.

Requires either Administrator elevation or Windows Developer Mode for
symlink creation. Both preconditions are checked before any work runs.
#>

$ErrorActionPreference = 'Stop'

# --- precondition: elevation or developer mode ---

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

# --- discover repo root from script location ---

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# --- winget import ---

$wingetManifest = Join-Path $PSScriptRoot 'winget.json'
Write-Host "Importing winget packages from $wingetManifest" -ForegroundColor Cyan
winget import --import-file $wingetManifest --accept-package-agreements --accept-source-agreements

# --- symlink manifest ---
# parallel to nix/modules/zed.nix - keep both in sync when adding entries.

$links = @(
    @{ Source = Join-Path $repo 'config\zed\settings.json'; Target = Join-Path $env:APPDATA 'Zed\settings.json' }
    @{ Source = Join-Path $repo 'config\zed\keymap.json';   Target = Join-Path $env:APPDATA 'Zed\keymap.json' }
    @{ Source = Join-Path $repo 'config\zed\tasks.json';    Target = Join-Path $env:APPDATA 'Zed\tasks.json' }
    @{ Source = Join-Path $repo 'config\zed\snippets';      Target = Join-Path $env:APPDATA 'Zed\snippets' }
    @{ Source = Join-Path $repo 'win\wslconfig';            Target = Join-Path $env:USERPROFILE '.wslconfig' }
)

# --- link or relink each entry with backup-on-clobber semantics ---

foreach ($link in $links) {
    $source = $link.Source
    $target = $link.Target

    if (-not (Test-Path -LiteralPath $source)) {
        Write-Host "skip   $target (source missing: $source)" -ForegroundColor Yellow
        continue
    }

    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $existing = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue

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

Write-Host 'Done.' -ForegroundColor Cyan
