{ config, pkgs, lib, dotfiles, ... }:

{
  home.stateVersion = "24.11";

  home.username = "jordanhoare";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/jordanhoare" else "/home/jordanhoare";

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

  home.file = let link = path: { source = "${dotfiles}/${path}"; }; in {
    # shell
    ".zshrc" = link "home/.zshrc";
    ".zshenv" = link "home/.zshenv";
    ".zprofile" = link "home/.zprofile";
    ".zlogin" = link "home/.zlogin";
    ".zsh/platform/linux.zsh" = link "home/.zsh/platform/linux.zsh";
    ".zsh/platform/macos.zsh" = link "home/.zsh/platform/macos.zsh";
    ".zsh/platform/wsl.zsh" = link "home/.zsh/platform/wsl.zsh";

    # ssh
    ".ssh/config" = link "home/.ssh/config";

    # git
    ".config/git/config" = link "config/git/config";

    # private git identity - only linked after 'make secrets' has decrypted it
    ".config/git/private" = lib.mkIf
      (builtins.pathExists "${dotfiles}/config/git/private")
      (link "config/git/private");

    # cloud CLIs
    ".config/gh/config.yml" = link "config/gh/config.yml";
    ".config/glab-cli/config.yml" = link "config/glab-cli/config.yml";
    ".config/gcloud/properties" = link "config/gcloud/properties";
    ".aws/config" = link "home/.aws/config";
    ".azure/config" = link "home/.azure/config";

    # shell tooling
    ".config/starship/starship.toml" = link "config/starship/starship.toml";
    ".config/sheldon/plugins.toml" = link "config/sheldon/plugins.toml";
    ".config/tmux/tmux.conf" = link "config/tmux/tmux.conf";

    # dev tooling
    ".config/lazygit/config.yml" = link "config/lazygit/config.yml";
    ".config/k9s/config.yaml" = link "config/k9s/config.yaml";
    ".config/nvim" = link "config/nvim";
    ".config/mise/config.toml" = link "config/mise/config.toml";

    # runtimes
    ".config/uv/uv.toml" = link "config/uv/uv.toml";
    ".bunfig.toml" = link "home/.bunfig.toml";

    # claude
    ".claude" = link "home/.claude";

    # bin
    "bin/mkcd" = link "bin/mkcd";
    "bin/secrets" = link "bin/secrets";
    "bin/sync" = link "bin/sync";
    "bin/up" = link "bin/up";
  };

  home.sessionPath = [ "$HOME/bin" ];
}
