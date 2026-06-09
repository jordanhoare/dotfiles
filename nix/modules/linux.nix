{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    obsidian
    bitwarden-desktop
    zed-editor
    vlc
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
    ".config/vlc/vlcrc".source = ../../config/vlc/vlcrc;
  };
}
