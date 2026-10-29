{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    git-lfs
  ];

  home.file = {
    ".config/git/config".source = ../../config/git/config;
    ".config/git/attributes".source = ../../config/git/attributes;
    ".config/git/hooks/agent-push-guard".source = ../../config/git/hooks/agent-push-guard;
    ".config/git/tidy".source = ../../config/git/tidy;
    ".config/git/personal".source = ../../config/git/personal;
  };
}
