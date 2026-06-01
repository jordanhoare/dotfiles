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
      #
      # USER is unreliable on macOS: darwin-rebuild runs under sudo, which resets
      # USER to root, and darwin-rebuild itself resets HOME to ~root. Both are
      # unusable as identity sources under sudo. DOTFILES_USER is a custom variable
      # set by the Makefile that sudo passes through and darwin-rebuild does not
      # touch, making it the authoritative source on macOS. On Linux/WSL, USER is
      # always correct (no sudo in the activation path).
      envOr = name: fallback: let v = builtins.getEnv name; in if v != "" then v else fallback;
      username = envOr "DOTFILES_USER" (envOr "USER" "user");
      # Checked at evaluation time (requires --impure) so the result is visible
      # at the flake level rather than buried inside profiles.nix. False on a
      # fresh clone where `make secrets` has not yet run.
      hasPrivateProfile = builtins.pathExists ../config/git/private;

      mkHome = { system, homeFallback, modules }: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        extraSpecialArgs = {
          inherit username hasPrivateProfile;
          homeDirectory = envOr "HOME" homeFallback;
        };
        modules = [ ./modules/base.nix ./modules/profiles.nix ] ++ modules;
      };
    in
    {
      # macOS — activate with: make switch
      # darwin-rebuild runs under sudo, which resets USER to root. username is
      # derived from HOME (passed explicitly by the Makefile) via baseNameOf,
      # so it resolves to the invoking user in both the nix build and
      # darwin-rebuild switch evaluation passes.
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
                inherit username hasPrivateProfile;
                homeDirectory = "/Users/${username}";
              };
              home-manager.users.${username} = {
                imports = [ ./modules/base.nix ./modules/profiles.nix ./modules/macos.nix ];
              };
            }
          ];
        };

      # Re-export the pinned home-manager CLI so `make switch` on Linux/WSL
      # uses the version from flake.lock rather than the Nix registry.
      packages.x86_64-linux.home-manager =
        home-manager.packages.x86_64-linux.home-manager;

      # Linux — activate with: make switch
      homeConfigurations."jordan@linux" = mkHome {
        system = "x86_64-linux";
        homeFallback = "/home/${username}";
        modules = [ ./modules/linux.nix ];
      };

      # WSL — activate with: make switch
      homeConfigurations."jordan@wsl" = mkHome {
        system = "x86_64-linux";
        homeFallback = "/home/${username}";
        modules = [ ./modules/wsl.nix ];
      };
    };
}
