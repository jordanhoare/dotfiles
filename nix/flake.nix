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
      # Change this when forking for your own use.
      username = "jordanhoare";

      # pathExists on a gitignored file is the sole reason --impure is required.
      # Evaluates to false on a fresh clone before `make secrets` has run.
      hasPrivateProfile = builtins.pathExists ../config/git/private;

      mkHome = { system, homeDirectory, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          extraSpecialArgs = { inherit username homeDirectory hasPrivateProfile; };
          modules = [ ./modules/base.nix ./modules/profiles.nix ] ++ modules;
        };
    in
    {
      # macOS — activate with: make switch
      darwinConfigurations."macos" =
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            ./modules/macos-system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Pre-existing files at a symlink target are renamed with this
              # suffix instead of aborting activation.
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
      homeConfigurations."linux" = mkHome {
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        modules = [ ./modules/linux.nix ];
      };

      # WSL — activate with: make switch
      homeConfigurations."wsl" = mkHome {
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        modules = [ ./modules/wsl.nix ];
      };
    };
}
