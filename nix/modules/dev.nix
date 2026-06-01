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
    nixfmt-rfc-style
  ];

  home.file = {
    ".config/lazygit/config.yml".source = ../../config/lazygit/config.yml;
    ".config/nvim".source = ../../config/nvim;
  };
}
