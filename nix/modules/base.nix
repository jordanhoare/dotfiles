{ config, pkgs, lib, username, homeDirectory, vscodeUserDir, ... }:

{
  home.stateVersion = "24.11";

  home.username = username;
  home.homeDirectory = homeDirectory;

  home.packages = with pkgs; [
    # core
    git
    git-lfs
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

    # shell
    starship
    sheldon
    tmux

    # runtime manager
    mise

    # cloud + infra
    gh
    claude-code
    bitwarden-cli
    kubernetes-helm
    k9s
    kubectx
    kubectl
    kustomize
    socat
    argocd

    # secrets
    sops
    age

    # dev tools
    bat
    delta
    lazygit
    neovim
    protobuf
    gnupg
    lua-language-server
    luajit

    # nix
    nil
    nixfmt-rfc-style
  ];

  home.file = {
    # shell
    ".zshrc".source = ../../home/.zshrc;
    ".zshenv".source = ../../home/.zshenv;
    ".zprofile".source = ../../home/.zprofile;
    ".zlogin".source = ../../home/.zlogin;
    ".zsh/platform/linux.zsh".source = ../../home/.zsh/platform/linux.zsh;
    ".zsh/platform/macos.zsh".source = ../../home/.zsh/platform/macos.zsh;
    ".zsh/platform/wsl.zsh".source = ../../home/.zsh/platform/wsl.zsh;

    # ssh
    ".ssh/config".source = ../../home/.ssh/config;

    # git (identity files are owned by modules/profiles.nix)
    ".config/git/config".source = ../../config/git/config;

    # cloud CLIs
    ".config/gh/config.yml".source = ../../config/gh/config.yml;
    ".config/glab-cli/config.yml".source = ../../config/glab-cli/config.yml;
    ".config/gcloud/properties".source = ../../config/gcloud/properties;
    ".aws/config".source = ../../home/.aws/config;
    ".azure/config".source = ../../home/.azure/config;

    # shell tooling
    ".config/starship/starship.toml".source = ../../config/starship/starship.toml;
    ".config/sheldon/plugins.toml".source = ../../config/sheldon/plugins.toml;
    ".config/tmux/tmux.conf".source = ../../config/tmux/tmux.conf;

    # dev tooling
    ".config/lazygit/config.yml".source = ../../config/lazygit/config.yml;
    ".config/k9s/config.yaml".source = ../../config/k9s/config.yaml;
    ".config/nvim".source = ../../config/nvim;
    ".config/mise/config.toml".source = ../../config/mise/config.toml;

    # runtimes
    ".config/uv/uv.toml".source = ../../config/uv/uv.toml;
    ".bunfig.toml".source = ../../home/.bunfig.toml;

    # vscode (target path differs per Platform; see flake.nix)
    "${vscodeUserDir}/settings.json" = { source = ../../config/Code/User/settings.json; };
    "${vscodeUserDir}/keybindings.json" = { source = ../../config/Code/User/keybindings.json; };

    # claude
    ".claude/CLAUDE.md".source     = ../../home/.claude/CLAUDE.md;
    ".claude/settings.json".source = ../../home/.claude/settings.json;
    ".claude/skills".source        = ../../home/.claude/skills;

    # bin
    "bin/mkcd".source = ../../bin/mkcd;
    "bin/secrets".source = ../../bin/secrets;
    "bin/sync".source = ../../bin/sync;
    "bin/up".source = ../../bin/up;
  };

  home.sessionPath = [ "$HOME/bin" ];
}
