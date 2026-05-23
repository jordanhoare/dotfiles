{ config, pkgs, lib, dotfiles, ... }:

{
  home.stateVersion = "24.11";

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
    bitwarden-cli
    helm
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

  # shell
  home.file.".zshrc".source = "${dotfiles}/home/.zshrc";
  home.file.".zshenv".source = "${dotfiles}/home/.zshenv";
  home.file.".zprofile".source = "${dotfiles}/home/.zprofile";
  home.file.".zlogin".source = "${dotfiles}/home/.zlogin";
  home.file.".zsh/platform/linux.zsh".source = "${dotfiles}/home/.zsh/platform/linux.zsh";
  home.file.".zsh/platform/macos.zsh".source = "${dotfiles}/home/.zsh/platform/macos.zsh";
  home.file.".zsh/platform/wsl.zsh".source = "${dotfiles}/home/.zsh/platform/wsl.zsh";

  # ssh
  home.file.".ssh/config".source = "${dotfiles}/home/.ssh/config";

  # git
  home.file.".config/git/config".source = "${dotfiles}/config/git/config";

  # private git identity - only linked after 'make secrets' has decrypted it
  home.file.".config/git/private" = lib.mkIf
    (builtins.pathExists "${dotfiles}/config/git/private")
    { source = "${dotfiles}/config/git/private"; };

  # cloud CLIs
  home.file.".config/gh/config.yml".source = "${dotfiles}/config/gh/config.yml";
  home.file.".config/gh/hosts.yml".source = "${dotfiles}/config/gh/hosts.yml";
  home.file.".config/glab-cli/config.yml".source = "${dotfiles}/config/glab-cli/config.yml";
  home.file.".config/gcloud/properties".source = "${dotfiles}/config/gcloud/properties";
  home.file.".aws/config".source = "${dotfiles}/home/.aws/config";
  home.file.".azure/config".source = "${dotfiles}/home/.azure/config";

  # shell tooling
  home.file.".config/starship/starship.toml".source = "${dotfiles}/config/starship/starship.toml";
  home.file.".config/sheldon/plugins.toml".source = "${dotfiles}/config/sheldon/plugins.toml";
  home.file.".config/tmux/tmux.conf".source = "${dotfiles}/config/tmux/tmux.conf";

  # dev tooling
  home.file.".config/lazygit/config.yml".source = "${dotfiles}/config/lazygit/config.yml";
  home.file.".config/k9s/config.yaml".source = "${dotfiles}/config/k9s/config.yaml";
  home.file.".config/nvim".source = "${dotfiles}/config/nvim";
  home.file.".config/mise/config.toml".source = "${dotfiles}/config/mise/config.toml";

  # runtimes
  home.file.".config/uv/uv.toml".source = "${dotfiles}/config/uv/uv.toml";
  home.file.".bunfig.toml".source = "${dotfiles}/home/.bunfig.toml";

  # claude
  home.file.".claude".source = "${dotfiles}/home/.claude";

  # bin
  home.file."bin/mkcd".source = "${dotfiles}/bin/mkcd";
  home.file."bin/sync".source = "${dotfiles}/bin/sync";
  home.file."bin/up".source = "${dotfiles}/bin/up";

  home.sessionPath = [ "$HOME/bin" ];
}
