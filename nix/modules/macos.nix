{ link, ... }:

{
  # GUI apps (Ghostty, Firefox, Obsidian) are installed as Homebrew casks in
  # macos-system.nix - nixpkgs cannot build them for darwin.
  home.file = {
    # ghostty config is macOS-native on this machine
    ".config/ghostty/config" = link "config/ghostty/config";
  };
}
