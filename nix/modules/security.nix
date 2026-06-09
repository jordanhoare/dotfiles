{ pkgs, lib, ... }:

let
  arkenfox  = builtins.readFile ../../config/firefox/arkenfox.js;
  overrides = builtins.readFile ../../config/firefox/user-overrides.js;

  # force_installed with install_url is required per Mozilla policy docs.
  # Firefox ignores installation_mode without install_url for sideloaded extensions.
  # https://mozilla.github.io/policy-templates/#extensionsettings
  amoUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
in
{
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableCrashReporter = true;
      SkipTermsOfUse = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;

      ManagedBookmarks = [
        { toplevel_name = "Bookmarks"; }
        { name = "Outlook";      url = "https://outlook.live.com"; }
        { name = "Drive";        url = "https://drive.google.com"; }
        { name = "GitHub";       url = "https://github.com"; }
        {
          name = "Cloud";
          children = [
            { name = "AWS";        url = "https://console.aws.amazon.com"; }
            { name = "Azure";      url = "https://portal.azure.com"; }
            { name = "GCP";        url = "https://console.cloud.google.com"; }
            { name = "Cloudflare"; url = "https://dash.cloudflare.com"; }
            { name = "HashiCorp";  url = "https://portal.cloud.hashicorp.com"; }
          ];
        }
        {
          name = "Accounts";
          children = [
            { name = "Bitwarden"; url = "https://vault.bitwarden.com"; }
            { name = "Proton";    url = "https://account.proton.me"; }
            { name = "GitLab";    url = "https://gitlab.com"; }
          ];
        }
      ];

      ExtensionSettings = {
        "uBlock0@raymondhill.net"                = { installation_mode = "force_installed"; install_url = amoUrl "uBlock0@raymondhill.net"; };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = { installation_mode = "force_installed"; install_url = amoUrl "{446900e4-71c2-419f-a6a7-df9c091e268b}"; };
        "leechblockng@proginosko.com"            = { installation_mode = "force_installed"; install_url = amoUrl "leechblockng@proginosko.com"; };
        "@news-feed-eradicator"                  = { installation_mode = "force_installed"; install_url = amoUrl "@news-feed-eradicator"; };
        "vpn@proton.ch"                          = { installation_mode = "force_installed"; install_url = amoUrl "vpn@proton.ch"; };
        "clipper@obsidian.md"                    = { installation_mode = "force_installed"; install_url = amoUrl "clipper@obsidian.md"; };
        "{ad81280b-0506-473b-815b-9fbbdd754448}" = { installation_mode = "force_installed"; install_url = amoUrl "{ad81280b-0506-473b-815b-9fbbdd754448}"; };
      };
    };

    profiles.personal = {
      id = 0;
      isDefault = true;
      name = "personal";
      extraConfig = arkenfox + overrides;
    };
  };

  # ProtonVPN: macOS uses a Homebrew cask (declared in macos.nix). See ADR 0010.
  home.packages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.protonvpn-gui
  ];
}
