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
      username = "jordanhoare";
      firstName = "Jordan";

      commonHmModules = [ ./modules/base.nix ./modules/profiles.nix ];

      mkHome = { system, homeDirectory, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          extraSpecialArgs = { inherit username firstName homeDirectory; };
          modules = commonHmModules ++ modules;
        };

      darwinSystem = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username firstName; };
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Pre-existing files at a symlink target are renamed with this
            # suffix instead of aborting activation.
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {
              inherit username firstName;
              homeDirectory = "/Users/${username}";
            };
            home-manager.users.${username}.imports = commonHmModules;
          }
          ./modules/macos.nix
        ];
      };

      linuxHome = mkHome {
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        modules = [ ./modules/linux.nix ];
      };

      wslHome = mkHome {
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        modules = [ ./modules/wsl.nix ];
      };
    in
    {
      darwinConfigurations."macos" = darwinSystem;
      homeConfigurations."linux"   = linuxHome;
      homeConfigurations."wsl"     = wslHome;

      # Re-export the pinned home-manager CLI so `make switch` on Linux/WSL
      # uses the version from flake.lock rather than the Nix registry.
      packages.x86_64-linux.home-manager =
        home-manager.packages.x86_64-linux.home-manager;
    };
}
