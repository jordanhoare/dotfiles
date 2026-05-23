{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obsidian
    bitwarden-desktop
  ];
}
