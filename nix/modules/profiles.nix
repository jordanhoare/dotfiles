{ ... }:

# Git identity Profiles (see glossary).
#   personal: committed plaintext at config/git/personal, linked into ~/.config/git.
#   private:  sops-encrypted at config/git/private.enc, decrypted by `make secrets`
#             directly into ~/.config/git/private (not managed by Nix). The
#             [includeIf] in config/git/config silently no-ops when missing.

{
  home.file.".config/git/personal".source = ../../config/git/personal;
}
