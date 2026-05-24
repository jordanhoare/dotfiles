{ pkgs, ... }:

{
  # Homebrew handles macOS GUI apps that nixpkgs cannot build for darwin
  # (Docker Desktop and the GUI apps below all lack darwin support in nixpkgs).
  # cleanup = "zap" makes this list authoritative - any unlisted cask is removed on rebuild.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };
    casks = [
      "docker"
      "ghostty"
      "firefox"
      "obsidian"
    ];
  };

  # Nix is installed and managed by Determinate (its own daemon), which conflicts
  # with nix-darwin's native Nix management. Hand control to Determinate.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  system.primaryUser = "jordanhoare";

  users.users.jordanhoare = {
    name = "jordanhoare";
    home = "/Users/jordanhoare";
  };

  system.stateVersion = 5;
}
