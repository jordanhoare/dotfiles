{ pkgs, username, homeDirectory, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./cloud.nix
    ./dev.nix
    ./zed.nix
    ./security.nix
  ];

  home.stateVersion = "24.11";

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.username = username;
  home.homeDirectory = homeDirectory;

  home.packages = with pkgs; [
    gnumake
    coreutils
    curl
    wget
    unzip
    zip
    fd
    fzf
    ripgrep
    zoxide
    eza
    bat
    jq
    just
    pwgen
    mise
    sops
    age
    gnupg
    bitwarden-cli
    imagemagick
    fastfetch
    shellcheck
    shfmt
    luarocks
    llvm
  ];

  home.file = {
    ".ssh/config".source = ../../home/.ssh/config;

    ".config/mise/config.toml".source = ../../config/mise/config.toml;
    ".config/uv/uv.toml".source = ../../config/uv/uv.toml;
    ".bunfig.toml".source = ../../home/.bunfig.toml;

    ".claude/CLAUDE.md".source     = ../../home/.claude/CLAUDE.md;
    ".claude/settings.json".source = ../../home/.claude/settings.json;
    ".claude/skills" = {
      source    = ../../home/.claude/skills;
      recursive = true;
    };
    ".claude/hooks" = {
      source    = ../../home/.claude/hooks;
      recursive = true;
    };

    "bin" = {
      source = ../../bin;
      recursive = true;
    };

    ".config/wallpapers/source.jpg".source = ../../config/wallpapers/source.jpg;
    ".config/wallpapers/wallpaper.jpg".source = ../../config/wallpapers/wallpaper.jpg;
  };

  home.sessionPath = [ "$HOME/bin" ];
}
