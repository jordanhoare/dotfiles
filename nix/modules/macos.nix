{
  pkgs,
  lib,
  username,
  firstName,
  ...
}:

{
  # Homebrew handles macOS GUI apps that nixpkgs cannot build for darwin.
  # cleanup = "zap" makes this list authoritative - any unlisted cask is removed on rebuild.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };
    casks = [
      "docker-desktop"
      "ghostty"
      "protonvpn"
      "nikitabobko/tap/aerospace"
      "obsidian"
      "zed"
      "vlc"
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

    # Siri + Apple Intelligence + dictation + Spotlight suggestions + diagnostics.
    # Re-asserted on every activation in case a macOS upgrade flips defaults back.
    CustomUserPreferences = {
      "com.apple.assistant.support" = {
        "Assistant Enabled" = false;
        "Dictation Enabled" = false;
        "Search Queries Data Sharing Status" = 2;
      };
      "com.apple.Siri" = {
        StatusMenuVisible = false;
        UserHasDeclinedEnable = true;
      };
      "com.apple.controlcenter" = {
        "NSStatusItem Visible Siri" = false;
      };
      "com.apple.CloudSubscriptionFeatures.optIn" = {
        device_OnTopic = false;
      };
      "com.apple.HIToolbox" = {
        AppleDictationAutoEnable = 0;
      };
      "com.apple.lookup.shared" = {
        LookupSuggestionsDisabled = true;
      };
      "com.apple.suggestions" = {
        SuggestionsAppLibraryEnabled = false;
      };
      "com.apple.SubmitDiagInfo" = {
        AutoSubmit = false;
        AutoSubmitVersion = 4;
      };

      # VLC: no recent-document persistence, no online metadata fetch, no
      # auto-update pings, skip the first-run metadata prompt.
      "org.videolan.vlc" = {
        NSRecentDocumentsLimit = 0;
        recentlyPlayedMedia = { };
        recentlyPlayedMediaList = { };
        SUEnableAutomaticChecks = false;
        MetadataNetworkAccess = false;
        OldPrefsVersion = 4;
      };

      # Default-app bindings via LaunchServices (Apple's own API, no third-party
      # tooling). lsregister is flushed in an activation script below so the
      # new bindings take effect without a logout.
      "com.apple.LaunchServices/com.apple.launchservices.secure" = {
        LSHandlers = [
          {
            LSHandlerURLScheme = "mailto";
            LSHandlerRoleAll = "org.nixos.firefox";
          }
          {
            LSHandlerURLScheme = "http";
            LSHandlerRoleAll = "org.nixos.firefox";
          }
          {
            LSHandlerURLScheme = "https";
            LSHandlerRoleAll = "org.nixos.firefox";
          }
          {
            LSHandlerContentType = "public.html";
            LSHandlerRoleAll = "org.nixos.firefox";
          }
          {
            LSHandlerContentType = "com.adobe.pdf";
            LSHandlerRoleAll = "org.nixos.firefox";
          }
          {
            LSHandlerContentType = "net.daringfireball.markdown";
            LSHandlerRoleAll = "md.obsidian";
          }
          {
            LSHandlerContentType = "public.python-script";
            LSHandlerRoleAll = "dev.zed.Zed";
          }
          {
            LSHandlerContentType = "public.shell-script";
            LSHandlerRoleAll = "dev.zed.Zed";
          }
          {
            LSHandlerContentType = "public.json";
            LSHandlerRoleAll = "dev.zed.Zed";
          }
          {
            LSHandlerContentType = "public.yaml";
            LSHandlerRoleAll = "dev.zed.Zed";
          }
          {
            LSHandlerContentType = "org.tomlang.toml";
            LSHandlerRoleAll = "dev.zed.Zed";
          }
          {
            LSHandlerContentType = "public.movie";
            LSHandlerRoleAll = "org.videolan.vlc";
          }
          {
            LSHandlerContentType = "public.audio";
            LSHandlerRoleAll = "org.videolan.vlc";
          }
          {
            LSHandlerContentType = "public.mp4";
            LSHandlerRoleAll = "org.videolan.vlc";
          }
          {
            LSHandlerContentType = "public.mpeg-4";
            LSHandlerRoleAll = "org.videolan.vlc";
          }
          {
            LSHandlerContentType = "public.mp3";
            LSHandlerRoleAll = "org.videolan.vlc";
          }
          {
            LSHandlerContentType = "com.microsoft.waveform-audio";
            LSHandlerRoleAll = "org.videolan.vlc";
          }
        ];
      };
    };
  };

  # Weekly Nix garbage collection. Determinate owns /etc/nix/nix.conf so
  # min-free/max-free auto-gc gets clobbered on its updates; a launchd job is
  # the predictable path. 7 days is enough rollback headroom since flake.lock
  # is committed and any older state is reachable from git.
  launchd.user.agents.nix-gc = {
    command = "/nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 7d";
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/nix-gc.log";
      StandardErrorPath = "/tmp/nix-gc.log";
    };
  };

  system.stateVersion = 5;

  # User-level config nested under nix-darwin's home-manager integration.
  home-manager.users.${username} = {
    home.packages = [ pkgs.defaultbrowser ];

    home.file = {
      ".config/ghostty/config".source = ../../config/ghostty/config;
      ".config/aerospace/aerospace.toml".source = ../../config/aerospace/aerospace.toml;
      "Library/Preferences/org.videolan.vlc/vlcrc".source = ../../config/vlc/vlcrc;
      ".config/firefox/newtab.html".text = lib.replaceStrings [ "__NAME__" ] [ firstName ] (
        builtins.readFile ../../config/firefox/newtab.html
      );
    };

    # Copy home-manager .app bundles to ~/Applications after linkGeneration creates
    # the "Home Manager Apps" directory. Must run after linkGeneration, not just
    # writeBoundary, otherwise the source directory does not exist yet.
    home.activation.linkApps = {
      after = [ "linkGeneration" ];
      before = [ ];
      data = ''
        src="$HOME/Applications/Home Manager Apps"
        dst="$HOME/Applications"
        if [[ -d "$src" ]]; then
          find -L "$src" -maxdepth 1 -name "*.app" | while IFS= read -r app; do
            name=$(basename "$app")
            $DRY_RUN_CMD chmod -R u+w "$dst/$name" 2>/dev/null || true
            $DRY_RUN_CMD rm -rf "$dst/$name"
            $DRY_RUN_CMD cp -RL "$app" "$dst/$name"
          done
        fi
      '';
    };

    # Prune Homebrew's download cache (bottles, cask installers). nix-darwin's
    # `cleanup = "zap"` removes untracked casks but leaves the download cache
    # untouched, which grows to multiple GB over time.
    home.activation.brewPruneCache = {
      after = [ "linkApps" ];
      before = [ ];
      data = ''
        if [[ -x /opt/homebrew/bin/brew ]]; then
          $DRY_RUN_CMD /opt/homebrew/bin/brew cleanup -s --prune=all 2>/dev/null || true
        fi
      '';
    };

    # Strip the macOS quarantine xattr off Homebrew-cask apps so they don't
    # show "downloaded from the internet" Gatekeeper prompts on first launch.
    home.activation.dequarantineCasks = {
      after = [ "linkApps" ];
      before = [ ];
      data = ''
        for app in VLC.app Obsidian.app "Zed.app" Ghostty.app ProtonVPN.app; do
          if [[ -e "/Applications/$app" ]]; then
            $DRY_RUN_CMD /usr/bin/xattr -dr com.apple.quarantine "/Applications/$app" 2>/dev/null || true
          fi
        done
      '';
    };

    # Kick LaunchServices to re-scan after the LSHandlers plist is updated by
    # setDarwinDefaults. Without this flush, the new bindings sit in the plist
    # but Finder/Spotlight keep using the cached defaults until next login.
    home.activation.refreshLaunchServices = {
      after = [
        "setDarwinDefaults"
        "linkApps"
      ];
      before = [ ];
      data = ''
        $DRY_RUN_CMD /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister \
          -kill -r -domain local -domain system -domain user 2>/dev/null || true
      '';
    };

    # macOS UI-gates default browser changes for anti-hijack reasons. The CLI
    # triggers a one-time system confirmation dialog; subsequent runs are a no-op
    # if Firefox is already default.
    home.activation.setDefaultBrowser = ''
      if [[ -x "${pkgs.defaultbrowser}/bin/defaultbrowser" ]]; then
        current=$(${pkgs.defaultbrowser}/bin/defaultbrowser 2>/dev/null | ${pkgs.gawk}/bin/awk '/^\* / {print $2}')
        if [[ "$current" != "firefox" ]]; then
          $DRY_RUN_CMD ${pkgs.defaultbrowser}/bin/defaultbrowser firefox 2>/dev/null || true
        fi
      fi
    '';

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
