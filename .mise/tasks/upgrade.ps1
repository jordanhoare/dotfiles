#MISE description="pull, update every winget app and tool, then apply"
$ErrorActionPreference = 'Stop'

if (git status --porcelain) { throw 'the tree is dirty; commit or stash before upgrading' }
git pull --ff-only
if ($LASTEXITCODE -ne 0) { throw 'git pull failed' }

winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
mise run apply
mise upgrade
uv tool upgrade --all
