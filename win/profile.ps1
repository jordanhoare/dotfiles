function dot { Set-Location 'D:\repositories\dotfiles' }

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
