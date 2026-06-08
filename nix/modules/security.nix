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
  ];

  securefox = builtins.readFile ../../config/firefox/securefox.js;
in
{
  programs.firefox = {
    enable = true;
    # macOS: Firefox is a Homebrew cask; nix manages config only. See ADR 0008.
    package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;

    # Enterprise policies - applied before profile loads, cannot be overridden
    # by user interaction. Suppresses telemetry consent screen and first-run UI.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableCrashReporter = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
    };

    profiles.personal = {
      id = 0;
      isDefault = true;
      name = "personal";
      extensions.packages = sharedExtensions;
      extraConfig = securefox;
    };
  };

  # ProtonVPN: macOS uses a Homebrew cask (declared in macos.nix). See ADR 0010.
  home.packages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.protonvpn-gui
  ];
}
