{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gh
    claude-code
    socat
    google-cloud-sdk
  ];

  home.file = {
    ".config/gh/config.yml".source = ../../config/gh/config.yml;
    ".config/glab-cli/config.yml".source = ../../config/glab-cli/config.yml;
    ".aws/config".source = ../../home/.aws/config;
    ".azure/config".source = ../../home/.azure/config;
    ".config/k9s/config.yaml".source = ../../config/k9s/config.yaml;
  };

  # gcloud's properties file is internal state - the supported declarative
  # interface is `gcloud config set`. Same pattern home-manager uses for
  # gh hosts.yml, ~/.kube/config, ~/.docker/config.json: don't manage the
  # file, manage the setter commands.
  home.activation.gcloudConfig = ''
    if command -v gcloud >/dev/null 2>&1; then
      gcloud config set core/disable_usage_reporting True --quiet 2>/dev/null || true
      gcloud config set compute/region australia-southeast1 --quiet 2>/dev/null || true
      gcloud config set compute/zone australia-southeast1-b --quiet 2>/dev/null || true
    fi
  '';
}
