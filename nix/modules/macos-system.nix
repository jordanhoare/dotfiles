{ pkgs, ... }:

{
  # Homebrew is kept solely for Docker Desktop, which cannot be distributed via nixpkgs.
  # cleanup = "zap" makes this list authoritative - any unlisted cask is removed on rebuild.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };
    casks = [
      "docker"
    ];
  };

  system.stateVersion = 5;
}
