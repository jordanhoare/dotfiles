{ pkgs, ... }:

{
  home.packages = with pkgs; [
    delta
    lazygit
    neovim
    protobuf
    pkg-config
    ninja
    gnupg
    lua-language-server
    luajit
    nil
    gopls
    bash-language-server
    yaml-language-server
    typescript-language-server
    # pwsh runs PowerShell Editor Services for the zed powershell extension.
    powershell
    nixfmt
    television
  ];

  home.file = {
    ".config/lazygit/config.yml".source = ../../config/lazygit/config.yml;
    ".config/nvim".source = ../../config/nvim;
  };
}
