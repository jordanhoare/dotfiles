#MISE description="update mise and every winget app, switch, then upgrade every tool"
$ErrorActionPreference = 'Stop'
winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
mise run switch
mise upgrade
uv tool upgrade --all
