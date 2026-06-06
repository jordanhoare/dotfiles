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

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = true;
      # Disable natural scrolling (unnatural for a keyboard-driven workflow)
      "com.apple.swipescrolldirection" = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      tilesize = 48;
      orientation = "bottom";
      mineffect = "scale";
      show-recents = false;
      mru-spaces = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      FXDefaultSearchScope = "SCcf";
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    spaces.spans-displays = false;
  };

  system.stateVersion = 5;

  # User-level config nested under nix-darwin's home-manager integration.
  home-manager.users.${username} = {
    home.file = {
      ".config/ghostty/config".source = ../../config/ghostty/config;
    };

    # Applied at activation time alongside all other home config.
    # First run from a bare Ghostty window triggers a one-time TCC prompt;
    # after that it works from tmux or anywhere else under Ghostty.
    home.activation.setWallpaper = ''
      WALLPAPER=$(readlink -f "$HOME/.config/wallpapers/wallpaper.jpg" 2>/dev/null)
      if [[ -f "$WALLPAPER" ]]; then
        osascript -e "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$WALLPAPER\"" 2>/dev/null || true
      fi
    '';
  };
}
