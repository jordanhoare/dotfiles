{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    obsidian
    bitwarden-desktop
    zed-editor
    hyprland
    hyprpaper
    waybar
    wofi
    brightnessctl
    wl-clipboard
    grim
    slurp
  ];

  home.file = {
    ".config/hypr/hyprland.conf".source = ../../config/hypr/hyprland.conf;
  };
}
