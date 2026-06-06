{ pkgs, username, ... }:

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
      "zed"
    ];
  };

  # Nix is installed and managed by Determinate (its own daemon), which conflicts
  # with nix-darwin's native Nix management. Hand control to Determinate.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  system.primaryUser = username;

  # Touch ID for sudo - declarative replacement for the /etc/pam.d/sudo hack.
  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system.stateVersion = 5;

  # User-level config nested under nix-darwin's home-manager integration.
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      desktoppr
    ];

    home.file = {
      # ghostty config is macOS-native on this machine
      ".config/ghostty/config".source = ../../config/ghostty/config;
    };
  };
}
