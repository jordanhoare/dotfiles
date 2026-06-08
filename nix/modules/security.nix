{ pkgs, lib, ... }:

let
  addons = pkgs.nur.repos.rycee.firefox-addons;

  sharedExtensions = [
    addons.ublock-origin
    addons.bitwarden
    addons.leechblock-ng
    addons.news-feed-eradicator
    addons.privacy-badger
    addons.proton-vpn
    # unhook (Unhook - Remove YouTube Recommended) is not in NUR rycee.
    # Install manually from AMO: https://addons.mozilla.org/addon/youtube-recommended-videos/
  ];

  sharedContainers = {
    "Personal" = { id = 1; color = "blue";   icon = "fingerprint"; };
    "Work"     = { id = 2; color = "orange"; icon = "briefcase";   };
    "Banking"  = { id = 3; color = "green";  icon = "dollar";      };
    "Shopping" = { id = 4; color = "pink";   icon = "cart";        };
  };

  securefox = builtins.readFile ../../config/firefox/securefox.js;
in
{
  programs.firefox = {
    enable = true;
    # macOS: Firefox is a Homebrew cask; nix manages config only. See ADR 0008.
    package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;

    profiles.personal = {
      id = 0;
      isDefault = true;
      name = "personal";
      extensions.packages = sharedExtensions;
      extraConfig = securefox;
      containers = sharedContainers;
      containersForce = true;
    };
  };

  # ProtonVPN: macOS uses a Homebrew cask (declared in macos.nix). See ADR 0010.
  home.packages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.protonvpn-gui
  ];
}
