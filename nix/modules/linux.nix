{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    obsidian
    bitwarden-desktop
  ];
}
