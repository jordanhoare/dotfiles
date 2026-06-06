{ pkgs, username, homeDirectory, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./cloud.nix
    ./dev.nix
    ./vscode.nix
    ./zed.nix
  ];

  home.stateVersion = "24.11";

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
    jq
    just
    pwgen
    mise
    sops
    age
    bitwarden-cli
  ];

  home.file = {
    ".ssh/config".source = ../../home/.ssh/config;

    ".config/mise/config.toml".source = ../../config/mise/config.toml;
    ".config/uv/uv.toml".source = ../../config/uv/uv.toml;
    ".bunfig.toml".source = ../../home/.bunfig.toml;

    ".claude/CLAUDE.md".source     = ../../home/.claude/CLAUDE.md;
    ".claude/settings.json".source = ../../home/.claude/settings.json;
    ".claude/skills".source        = ../../home/.claude/skills;

    "bin/mkcd".source = ../../bin/mkcd;
    "bin/secrets".source = ../../bin/secrets;
    "bin/sync".source = ../../bin/sync;
    "bin/up".source = ../../bin/up;
    "bin/work".source = ../../bin/work;
  };

  home.sessionPath = [ "$HOME/bin" ];
}
