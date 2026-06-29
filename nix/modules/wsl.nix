{ pkgs, lib, ... }:

{
  # WSL runs GUI apps (VSCode, Obsidian, Bitwarden) as native Windows apps
  # via win/winget.json, so no Linux GUI packages are installed here.
  home.packages = with pkgs; [
    xdg-utils
  ];

  # /etc/wsl.conf is root-owned and lives outside Home Manager's normal
  # surface. Sync it via an activation that compares the repo's
  # etc/wsl.conf against /etc/wsl.conf and copies via sudo only if they
  # differ. A 'wsl --shutdown' on the Windows side is required to apply.
  home.activation.wslConfSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src=${../../etc/wsl.conf}
    dst=/etc/wsl.conf
    sudo=/usr/bin/sudo
    if [ ! -x "$sudo" ]; then
      echo "sudo not found at $sudo; skipping /etc/wsl.conf sync." >&2
      exit 0
    fi
    if [ ! -f "$dst" ] || ! cmp -s "$src" "$dst"; then
      echo "Syncing /etc/wsl.conf (sudo required)..."
      "$sudo" install -m 644 "$src" "$dst"
      echo "Run 'wsl --shutdown' from Windows PowerShell to apply."
    fi
  '';
}
