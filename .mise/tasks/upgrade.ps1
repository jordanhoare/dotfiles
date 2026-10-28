#MISE description="pull the merged pin bumps, apply, then upgrade the unpinned tools"
$ErrorActionPreference = 'Stop'

# Pins live in the repo and move only through renovate's pull requests, so this
# task never writes a tracked file: it pulls what merged and installs it.
if (git status --porcelain --untracked-files=no) { throw 'the tree is dirty; commit or stash before upgrading' }
git pull --ff-only
if ($LASTEXITCODE -ne 0) { throw 'git pull failed' }

mise run apply
mise install

mise self-update -y
winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
uv tool upgrade --all
