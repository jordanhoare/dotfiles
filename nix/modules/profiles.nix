{ lib, dotfiles, link, ... }:

# A Profile is a git identity context (see glossary). Two Profiles exist:
#   - personal: committed plaintext at config/git/personal, always linked.
#   - private:  sops-encrypted at config/git/private.enc, linked only after
#               `make secrets` has decrypted it to config/git/private.
# Both files share the same shape - a git-config fragment with [user] and
# [github] sections - consumed by config/git/config via [include] / [includeIf]
# and by the `git personal` / `git private` aliases.

{
  home.file = {
    ".config/git/personal" = link "config/git/personal";

    ".config/git/private" = lib.mkIf
      (builtins.pathExists "${dotfiles}/config/git/private")
      (link "config/git/private");
  };
}
