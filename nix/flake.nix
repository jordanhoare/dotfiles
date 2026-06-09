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

    nur.url = "github:nix-community/NUR";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, nur, ... }:
    let
      # Change this when forking for your own use.
      username = "jordanhoare";
      firstName = "Jordan";

      # pathExists on a gitignored file is the sole reason --impure is required.
      # Evaluates to false on a fresh clone before `make secrets` has run.
      hasPrivateProfile = builtins.pathExists ../config/git/private;

      nurOverlay = nur.overlays.default;

      mkHome = { system, homeDirectory, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; overlays = [ nurOverlay ]; };
          extraSpecialArgs = { inherit username firstName homeDirectory hasPrivateProfile; };
          modules = [ ./modules/base.nix ./modules/profiles.nix ] ++ modules;
        };

      darwinSystem = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username firstName; };
        modules = [
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ nurOverlay ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Pre-existing files at a symlink target are renamed with this
            # suffix instead of aborting activation.
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {
              inherit username firstName hasPrivateProfile;
              homeDirectory = "/Users/${username}";
            };
            home-manager.users.${username}.imports =
              [ ./modules/base.nix ./modules/profiles.nix ];
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

      # Stable targets for make verify / make doctor. Keyed by platform so the
      # Makefile passes homeManagerFiles.${PLATFORM} without knowing the internal
      # nix-darwin nesting path or the username.
      homeManagerFiles.macos = darwinSystem.config.home-manager.users.${username}.home.file;
      homeManagerFiles.linux = linuxHome.config.home.file;
      homeManagerFiles.wsl   = wslHome.config.home.file;

      # Re-export the pinned home-manager CLI so `make switch` on Linux/WSL
      # uses the version from flake.lock rather than the Nix registry.
      packages.x86_64-linux.home-manager =
        home-manager.packages.x86_64-linux.home-manager;
    };
}
