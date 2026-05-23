{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    firefox
    obsidian
    ghostty
  ];

  # VSCode settings land in ~/Library/Application Support/Code/User/ on macOS
  home.file."Library/Application Support/Code/User/settings.json".source = "${dotfiles}/config/Code/User/settings.json";
  home.file."Library/Application Support/Code/User/keybindings.json".source = "${dotfiles}/config/Code/User/keybindings.json";

  # ghostty config is macOS-native on this machine
  home.file.".config/ghostty/config".source = "${dotfiles}/config/ghostty/config";
}
