export MSBuild="D:\msvsc\product\MSBuild\Current\Bin\MSBuild.exe"
alias home='cd /mnt/d/'

[ -d "/mnt/d/vscode/bin" ] && export PATH="$PATH:/mnt/d/vscode/bin"
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"

# The ExileApi HUD path for the poe workspace, which builds plugins from WSL
# as a build host (workspace ADR 0006). Windows holds the same value in setx.
export exapiPackage="/mnt/d/repositories/private/poe/ExileApi"
