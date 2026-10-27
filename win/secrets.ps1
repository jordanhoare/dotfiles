#Requires -Version 5.1

<#
.SYNOPSIS
Windows counterpart to bin/secrets for the personal account only.

.DESCRIPTION
Restores ~/.ssh/personal and logs gh in with the PAT held in the hidden 'pat'
field of the same Bitwarden SSH Key item. The private account stays WSL-only:
the includeIf paths in config/git/config only match /mnt paths.
#>

$ErrorActionPreference = 'Stop'

# gh ignores stored credentials whenever GH_TOKEN/GITHUB_TOKEN is set.
Remove-Item Env:GH_TOKEN, Env:GITHUB_TOKEN -ErrorAction SilentlyContinue

# Redirecting a native command's stderr under 'Stop' turns any stderr line into a
# terminating error in PowerShell 5.1, so read the state from stdout instead.
if ((bw status | ConvertFrom-Json).status -eq 'unauthenticated') { bw login }

$env:BW_SESSION = bw unlock --raw
if (-not $env:BW_SESSION) { throw 'bw unlock failed' }
bw sync | Out-Null

$name = 'personal'
# --search matches any field, so it can return several SSH Key items; keep the exact name.
$found = @(bw list items --search $name | ConvertFrom-Json | Where-Object { $_.type -eq 5 -and $_.name -eq $name })
if ($found.Count -ne 1) { throw "expected one SSH Key item named '$name' in Bitwarden, found $($found.Count)" }
$item = $found[0]

# Validate both secrets before writing anything, so a failed run leaves no stub key behind.
$key = $item.sshKey.privateKey
if (-not $key) { throw "no private key on Bitwarden item '$name'" }
$pat = ($item.fields | Where-Object { $_.name -eq 'pat' }).value
if (-not $pat) { throw "no 'pat' field on Bitwarden item '$name'" }

$sshDir = Join-Path $env:USERPROFILE '.ssh'
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
$keyPath = Join-Path $sshDir $name
# OpenSSH refuses a key with CR line endings, so write LF explicitly.
[IO.File]::WriteAllText($keyPath, ($key -replace "`r`n", "`n").TrimEnd("`n") + "`n")
# OpenSSH refuses a private key readable by other accounts.
icacls $keyPath /inheritance:r /grant:r "$($env:USERNAME):F" | Out-Null

$pat | gh auth login --hostname github.com --git-protocol ssh --with-token

bw lock | Out-Null
Write-Host "Restored ~/.ssh/$name and logged gh in." -ForegroundColor Cyan
