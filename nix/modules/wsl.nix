{ pkgs, ... }:

{
  # WSL runs GUI apps (VSCode, Obsidian, Bitwarden) as native Windows apps
  # via windows/winget.json, so no Linux GUI packages are installed here.
  home.packages = with pkgs; [
    xdg-utils
  ];
}
