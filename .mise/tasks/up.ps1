#MISE description="upgrade every winget app, switch, then upgrade every mise and uv tool"
$ErrorActionPreference = 'Stop'
winget upgrade --all --accept-package-agreements --accept-source-agreements
mise run switch
mise upgrade
uv tool upgrade --all
