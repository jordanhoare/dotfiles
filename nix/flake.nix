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
      dotfiles = builtins.toString ../.;

      mkHome = { system, modules }: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        extraSpecialArgs = { inherit dotfiles; };
        modules = [ ./modules/common.nix ] ++ modules;
      };
    in
    {
      # macOS — activate with: make switch
      darwinConfigurations."jordan@macos" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./modules/macos-system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit dotfiles; };
            home-manager.users.jordanhoare = {
              imports = [ ./modules/common.nix ./modules/macos.nix ];
            };
          }
        ];
      };

      # Linux — activate with: make switch
      homeConfigurations."jordan@linux" = mkHome {
        system = "x86_64-linux";
        modules = [ ./modules/linux-base.nix ./modules/linux.nix ];
      };

      # WSL — activate with: make switch
      homeConfigurations."jordan@wsl" = mkHome {
        system = "x86_64-linux";
        modules = [ ./modules/linux-base.nix ./modules/wsl.nix ];
      };
    };
}
