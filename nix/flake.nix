{
  description = "Jordan Hoare dotfiles - Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }:
    let
      # Identity is derived from the environment at activation (requires --impure),
      # with a neutral fallback so pure `nix flake check` still evaluates. This is
      # the single point of impurity; modules receive identity as explicit args.
      envOr = name: fallback: let v = builtins.getEnv name; in if v != "" then v else fallback;
      username = envOr "USER" "user";

      linuxVscodeUserDir = ".config/Code/User";
      macosVscodeUserDir = "Library/Application Support/Code/User";

      mkHome = { system, homeFallback, vscodeUserDir, modules }: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        extraSpecialArgs = {
          inherit username vscodeUserDir;
          homeDirectory = envOr "HOME" homeFallback;
        };
        modules = [ ./modules/base.nix ./modules/profiles.nix ] ++ modules;
      };
    in
    {
      # macOS — activate with: make switch
      # The darwin path activates as root via sudo, so USER inside nix evaluates
      # to "root" (sudo's env_reset overrides any USER= prefix on the make line).
      # That would make `home-manager.users.${envOr "USER" ...}` resolve to
      # `home-manager.users.root`, which HM then null-defaults. macOS is also
      # already structurally tied to "jordanhoare" via `system.primaryUser` and
      # `users.users.jordanhoare` in macos-system.nix, so the env-derived
      # identity pattern only makes sense for the user-space Linux/WSL paths.
      darwinConfigurations."jordan@macos" =
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            ./modules/macos-system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Pre-existing files at a Symlink target (a hand-edited config, a
              # directory already populated by an app, etc) are renamed with this
              # suffix instead of aborting activation. Same behaviour CI relies on
              # via HOME_MANAGER_BACKUP_EXT=bak.
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit username;
                homeDirectory = "/Users/${username}";
                vscodeUserDir = macosVscodeUserDir;
              };
              home-manager.users.${username} = {
                imports = [ ./modules/base.nix ./modules/profiles.nix ./modules/macos.nix ];
              };
            }
          ];
        };

      # Linux — activate with: make switch
      homeConfigurations."jordan@linux" = mkHome {
        system = "x86_64-linux";
        homeFallback = "/home/${username}";
        vscodeUserDir = linuxVscodeUserDir;
        modules = [ ./modules/linux.nix ];
      };

      # WSL — activate with: make switch
      homeConfigurations."jordan@wsl" = mkHome {
        system = "x86_64-linux";
        homeFallback = "/home/${username}";
        vscodeUserDir = linuxVscodeUserDir;
        modules = [ ./modules/wsl.nix ];
      };
    };
}
