{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    obsidian
    bitwarden-desktop
  ];

  # VSCode settings land in ~/.config/Code/User/ on native Linux
  home.file = let link = path: { source = "${dotfiles}/${path}"; }; in {
    ".config/Code/User/settings.json" = link "config/Code/User/settings.json";
    ".config/Code/User/keybindings.json" = link "config/Code/User/keybindings.json";
  };
}
