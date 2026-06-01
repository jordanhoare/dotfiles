{ pkgs, ... }:

{
  home.packages = with pkgs; [
    starship
    sheldon
    tmux
  ];

  home.file = {
    ".zshrc".source = ../../home/.zshrc;
    ".zshenv".source = ../../home/.zshenv;
    ".zprofile".source = ../../home/.zprofile;
    ".zlogin".source = ../../home/.zlogin;
    ".zsh/platform/linux.zsh".source = ../../home/.zsh/platform/linux.zsh;
    ".zsh/platform/macos.zsh".source = ../../home/.zsh/platform/macos.zsh;
    ".zsh/platform/wsl.zsh".source = ../../home/.zsh/platform/wsl.zsh;

    ".config/starship/starship.toml".source = ../../config/starship/starship.toml;
    ".config/sheldon/plugins.toml".source = ../../config/sheldon/plugins.toml;
    ".config/tmux/tmux.conf".source = ../../config/tmux/tmux.conf;
  };
}
