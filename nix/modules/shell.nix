{ pkgs, ... }:

{
  home.packages = with pkgs; [
    starship
    sheldon
    tmux
  ];

  # .zshrc runs `direnv hook zsh` itself; home-manager's zsh integration needs
  # programs.zsh, which this repo does not use.
  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };

  home.file = {
    ".zshrc".source = ../../home/.zshrc;
    ".zshenv".source = ../../home/.zshenv;
    ".zprofile".source = ../../home/.zprofile;
    ".zsh/wsl.zsh".source = ../../home/.zsh/wsl.zsh;

    ".config/starship/starship.toml".source = ../../config/starship/starship.toml;
    ".config/sheldon/plugins.toml".source = ../../config/sheldon/plugins.toml;
    ".config/tmux/tmux.conf".source = ../../config/tmux/tmux.conf;
  };
}
