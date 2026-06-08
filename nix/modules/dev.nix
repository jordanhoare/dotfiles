{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    delta
    lazygit
    neovim
    protobuf
    gnupg
    lua-language-server
    luajit
    nil
    gopls
    bash-language-server
    yaml-language-server
    typescript-language-server
    nixfmt
    television
  ];

  home.file = {
    ".config/lazygit/config.yml".source = ../../config/lazygit/config.yml;
    ".config/nvim".source = ../../config/nvim;
  };
}
