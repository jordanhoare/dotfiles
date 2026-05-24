{ pkgs, dotfiles, ... }:

{
  # WSL runs GUI apps (VSCode, Obsidian, Bitwarden) as native Windows apps
  # via windows/winget.json, so no Linux GUI packages are installed here.
  home.packages = with pkgs; [
    xdg-utils
  ];

  # VSCode settings land in ~/.config/Code/User/ on WSL
  home.file = let link = path: { source = "${dotfiles}/${path}"; }; in {
    ".config/Code/User/settings.json" = link "config/Code/User/settings.json";
    ".config/Code/User/keybindings.json" = link "config/Code/User/keybindings.json";
  };
}
