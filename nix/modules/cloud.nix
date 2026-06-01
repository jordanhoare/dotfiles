{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gh
    claude-code
    kubernetes-helm
    k9s
    kubectx
    kubectl
    kustomize
    socat
    argocd
  ];

  home.file = {
    ".config/gh/config.yml".source = ../../config/gh/config.yml;
    ".config/glab-cli/config.yml".source = ../../config/glab-cli/config.yml;
    ".config/gcloud/properties".source = ../../config/gcloud/properties;
    ".aws/config".source = ../../home/.aws/config;
    ".azure/config".source = ../../home/.azure/config;
    ".config/k9s/config.yaml".source = ../../config/k9s/config.yaml;
  };
}
