{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
  ];

  # VSCode settings land in ~/.config/Code/User/ on Linux and WSL
  home.file.".config/Code/User/settings.json".source = "${dotfiles}/config/Code/User/settings.json";
  home.file.".config/Code/User/keybindings.json".source = "${dotfiles}/config/Code/User/keybindings.json";
}
