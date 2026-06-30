{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    git-lfs
  ];

  home.file = {
    ".config/git/config".source = ../../config/git/config;
    ".config/git/attributes".source = ../../config/git/attributes;
  };
}
