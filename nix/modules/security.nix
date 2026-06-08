{ pkgs, lib, ... }:

let
  sharedExtensions = with pkgs.firefox-addons; [
    ublock-origin
    bitwarden
    leechblock-ng
    news-feed-eradicator
    privacy-badger17
    proton-vpn-firefox-extension
    # unhook (Unhook - Remove YouTube Recommended) is not in nixpkgs firefox-addons.
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
    package = lib.mkIf (!pkgs.stdenv.isDarwin) pkgs.firefox;

    profiles.personal = {
      id = 0;
      isDefault = true;
      name = "personal";
      extensions = sharedExtensions;
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
