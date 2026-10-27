#MISE description="decrypt every committed *.sops file to its target under ~"
$ErrorActionPreference = 'Stop'

$env:SOPS_AGE_SSH_PRIVATE_KEY_FILE = Join-Path $env:USERPROFILE '.ssh\personal'

# The package a file sits in gives its target: home/ maps to ~, config/ to ~/.config.
foreach ($source in @(git ls-files '*.sops')) {
    if ($source -like 'home/*') {
        $target = Join-Path $env:USERPROFILE $source.Substring('home/'.Length)
    } elseif ($source -like 'config/*') {
        $target = Join-Path $env:USERPROFILE ('.config\' + $source.Substring('config/'.Length))
    } else {
        Write-Host "skip   ${source}: not under home/ or config/" -ForegroundColor Yellow
        continue
    }
    $target = ($target -replace '\.sops$', '') -replace '/', '\'
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    sops --decrypt --output $target $source
    if ($LASTEXITCODE -ne 0) { throw "sops failed to decrypt $source" }
    # OpenSSH refuses a config file other accounts can write to.
    icacls $target /inheritance:r /grant:r "$($env:USERNAME):F" | Out-Null
    Write-Host "write  $target" -ForegroundColor Green
}
