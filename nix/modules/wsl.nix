{ pkgs, ... }:

{
  # GUI apps on WSL are Windows apps from win/winget.json.
  home.packages = with pkgs; [
    xdg-utils
  ];
}
