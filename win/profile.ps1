function dot { Set-Location 'D:\repositories\dotfiles' }

# Keep the active gh account on the identity git would commit with here, as the
# zsh wrapper does. Outside a repo, git's [includeIf] cannot fire, so the private
# path is matched by hand to cover `gh repo clone` and `gh repo create`.
function gh {
    $cli = Get-Command gh.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
    if ((Get-Location).Path -like 'D:\repositories\private\*') {
        $target = git config --file "$env:USERPROFILE\.config\git\private" github.user 2>$null
    } else {
        $target = git config github.user 2>$null
    }
    if ($target) { & $cli auth switch --user $target 2>$null | Out-Null }
    & $cli @args
}

# A function outranks the exe on PATH, so resolve the cli explicitly to avoid recursion.
function zed {
    # An unelevated Zed cannot open an elevated cli's pipe, so the cli waits forever.
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error 'zed: this shell is elevated; open it from an unelevated shell'
        return
    }
    $cli = Get-Command zed.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
    if ($args.Count -eq 0) { & $cli . } else { & $cli @args }
}
