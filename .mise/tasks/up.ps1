#MISE description="update mise, flake.lock, switch, then upgrade every tool"
$ErrorActionPreference = 'Stop'
winget upgrade --id jdx.mise --accept-package-agreements --accept-source-agreements
mise run switch
mise upgrade
uv tool upgrade --all
