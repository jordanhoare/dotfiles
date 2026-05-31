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

      # Identity is derived from the environment at activation (requires --impure),
      # with committed fallbacks so pure `nix flake check` still evaluates. This is
      # the single point of impurity; modules receive identity as explicit args.
      envOr = name: fallback: let v = builtins.getEnv name; in if v != "" then v else fallback;
      username = envOr "USER" "jordanhoare";

      linuxVscodeUserDir = ".config/Code/User";
      macosVscodeUserDir = "Library/Application Support/Code/User";

      mkHome = { system, homeFallback, vscodeUserDir, modules }: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        extraSpecialArgs = {
          inherit dotfiles username vscodeUserDir;
          homeDirectory = envOr "HOME" homeFallback;
        };
        modules = [ ./modules/base.nix ] ++ modules;
      };
    in
    {
      # macOS — activate with: make switch
      darwinConfigurations."jordan@macos" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username; };
        modules = [
          ./modules/macos-system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit dotfiles username;
              homeDirectory = envOr "HOME" "/Users/${username}";
              vscodeUserDir = macosVscodeUserDir;
            };
            home-manager.users.${username} = {
              imports = [ ./modules/base.nix ./modules/macos.nix ];
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
