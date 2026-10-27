{ config, pkgs, lib, ... }:

let
  arkenfox = builtins.readFile ../../config/firefox/arkenfox.js;
  overridesRaw = builtins.readFile ../../config/firefox/user-overrides.js;
  overrides = lib.replaceStrings [ "__HOME__" ] [ config.home.homeDirectory ] overridesRaw;

  # Firefox autoconfig (mozilla.cfg) runs in the privileged chrome context, so it
  # can route new tabs to a local file:// that the WebExtension sandbox no longer
  # reaches. extraPrefs bakes it into the app bundle - the only resource path the
  # nix-built Firefox actually reads from.
  mozillaCfg = lib.replaceStrings
    [ "__NEWTAB_URL__" ]
    [ "file://${config.home.homeDirectory}/.config/firefox/newtab.html" ]
    (builtins.readFile ../../config/firefox/mozilla.cfg);

  # Firefox ignores installation_mode without install_url for sideloaded
  # extensions: https://mozilla.github.io/policy-templates/#extensionsettings
  forceInstalled = id: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
    private_browsing = true;
  };
in
{
  programs.firefox = {
    enable = true;
    # home-manager 26.05 moved the default to $XDG_CONFIG_HOME/mozilla/firefox.
    # Pin the legacy location so the pre-existing profile at ~/.mozilla/firefox
    # keeps working without a filesystem migration.
    configPath = ".mozilla/firefox";
    package = pkgs.firefox.override {
      extraPrefs = mozillaCfg;
    };
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableCrashReporter = true;
      SkipTermsOfUse = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;

      SearchEngines = {
        Default = "DuckDuckGo";
        PreventInstalls = true;
        Remove = [ "Google" "Bing" "Amazon.com" "eBay" "Wikipedia (en)" ];
      };

      Handlers = {
        schemes = {
          mailto = {
            action = "useHelperApp";
            ask = false;
            handlers = [{
              name = "Outlook";
              uriTemplate = "https://outlook.live.com/owa/?path=/mail/action/compose&to=%s";
            }];
          };
        };
      };

      ExtensionSettings = lib.genAttrs [
        "uBlock0@raymondhill.net"
        "{446900e4-71c2-419f-a6a7-df9c091e268b}"
        "leechblockng@proginosko.com"
        "@news-feed-eradicator"
        "vpn@proton.ch"
        "clipper@obsidian.md"
        "{ad81280b-0506-473b-815b-9fbbdd754448}"
      ] forceInstalled;
    };

    profiles.personal = {
      id = 0;
      isDefault = true;
      name = "personal";
      extraConfig = arkenfox + overrides;

      bookmarks = {
        force = true;
        settings = [
          {
            name = "toolbar";
            toolbar = true;
            bookmarks = [
              {
                name = "Personal";
                bookmarks = [
                  {
                    name = "LinkedIn";
                    url = "https://www.linkedin.com";
                  }
                  {
                    name = "Drive";
                    url = "https://drive.google.com";
                  }
                ];
              }
              {
                name = "Cloud";
                bookmarks = [
                  {
                    name = "AWS";
                    url = "https://console.aws.amazon.com";
                  }
                  {
                    name = "Azure";
                    url = "https://portal.azure.com";
                  }
                  {
                    name = "Google";
                    url = "https://console.cloud.google.com";
                  }
                  {
                    name = "Terraform";
                    url = "https://app.terraform.io";
                  }
                  {
                    name = "HashiCorp";
                    url = "https://portal.cloud.hashicorp.com";
                  }
                  {
                    name = "Cloudflare";
                    url = "https://dash.cloudflare.com";
                  }
                  {
                    name = "Vault";
                    url = "https://portal.cloud.hashicorp.com/services/secrets";
                  }
                ];
              }
              {
                name = "Other";
                bookmarks = [
                  {
                    name = "Claude";
                    url = "https://claude.ai";
                  }
                  {
                    name = "JIRA";
                    url = "https://www.atlassian.com/software/jira";
                  }
                  {
                    name = "Confluence";
                    url = "https://www.atlassian.com/software/confluence";
                  }
                  {
                    name = "Loom";
                    url = "https://loom.com";
                  }
                  {
                    name = "GitLab";
                    url = "https://gitlab.com";
                  }
                  {
                    name = "Bitwarden";
                    url = "https://vault.bitwarden.com";
                  }
                  {
                    name = "Proton";
                    url = "https://account.proton.me";
                  }
                ];
              }
              {
                name = "Outlook";
                url = "https://outlook.live.com";
              }
              {
                name = "GitHub";
                url = "https://github.com";
              }
            ];
          }
        ];
      };
    };
  };

  # ProtonVPN: macOS uses a Homebrew cask (declared in macos.nix).
  home.packages = lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
    pkgs.proton-vpn
  ];
}
