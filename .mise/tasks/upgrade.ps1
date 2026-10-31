#MISE description="pull the merged pin bumps, apply, then upgrade the unpinned tools"
$ErrorActionPreference = 'Stop'

# Pins live in the repo and move only through renovate's pull requests, so this
# task never writes a tracked file: it pulls what merged and installs it.
if (git status --porcelain --untracked-files=no) { throw 'the tree is dirty; commit or stash before upgrading' }
git pull --ff-only
if ($LASTEXITCODE -ne 0) { throw 'git pull failed' }

mise run apply
mise install

# winget owns mise on Windows, so `mise self-update` refuses to run; the
# winget upgrade below covers it. The shim launcher is copied from the old
# binary until a forced reshim replaces it.
winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
mise reshim --force
uv tool upgrade --all
