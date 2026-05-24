{ dotfiles, ... }:

{
  # GUI apps (Ghostty, Firefox, Obsidian) are installed as Homebrew casks in
  # macos-system.nix - nixpkgs cannot build them for darwin.
  home.file = let link = path: { source = "${dotfiles}/${path}"; }; in {
    # VSCode settings land in ~/Library/Application Support/Code/User/ on macOS
    "Library/Application Support/Code/User/settings.json" = link "config/Code/User/settings.json";
    "Library/Application Support/Code/User/keybindings.json" = link "config/Code/User/keybindings.json";

    # ghostty config is macOS-native on this machine
    ".config/ghostty/config" = link "config/ghostty/config";
  };
}
