{ pkgs, lib, username, homeDirectory, ... }:

let
  # Claude Code globs skills/*/SKILL.md one level deep, so the lifecycle buckets
  # are flattened here. Codex skips symlinked files, so ~/.agents/skills gets a
  # directory link per skill; ~/.claude/skills stays per-file to avoid colliding
  # with its existing links on activation.
  skillsRoot = ../../home/.claude/skills;

  subdirsOf = path:
    lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir path));

  skillLinks = lib.listToAttrs (
    lib.concatMap
      (bucket:
        lib.concatMap
          (skill:
            let source = skillsRoot + "/${bucket}/${skill}"; in [
              (lib.nameValuePair ".claude/skills/${skill}" {
                inherit source;
                recursive = true;
              })
              (lib.nameValuePair ".agents/skills/${skill}" { inherit source; })
            ])
          (subdirsOf (skillsRoot + "/${bucket}")))
      (subdirsOf skillsRoot)
  );
in

{
  imports = [
    ./shell.nix
    ./git.nix
    ./cloud.nix
    ./dev.nix
    ./zed.nix
    ./firefox.nix
  ];

  home.stateVersion = "24.11";

  home.username = username;
  home.homeDirectory = homeDirectory;

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    unzip
    zip
    fd
    fzf
    ripgrep
    zoxide
    eza
    bat
    jq
    pwgen
    age
    bitwarden-cli
    imagemagick
    fastfetch
    luarocks
    llvm
  ];

  home.file = skillLinks // {
    ".ssh/config".source = ../../home/.ssh/config;

    ".config/mise/config.toml".source = ../../config/mise/config.toml;
    ".config/uv/uv.toml".source = ../../config/uv/uv.toml;
    ".bunfig.toml".source = ../../home/.bunfig.toml;

    ".claude/AGENTS.md".source     = ../../home/.claude/AGENTS.md;
    ".codex/AGENTS.md".source      = ../../home/.claude/AGENTS.md;
    ".claude/CLAUDE.md".source     = ../../home/.claude/CLAUDE.md;
    ".claude/settings.json".source = ../../home/.claude/settings.json;
    ".codex/hooks.json".source = ../../home/.codex/hooks.json;
    ".claude/hooks" = {
      source    = ../../home/.claude/hooks;
      recursive = true;
    };
    ".claude/output-styles" = {
      source    = ../../home/.claude/output-styles;
      recursive = true;
    };

    "bin" = {
      source = ../../bin;
      recursive = true;
    };

    ".config/wallpapers/source.jpg".source = ../../config/wallpapers/source.jpg;
    ".config/wallpapers/wallpaper.jpg".source = ../../config/wallpapers/wallpaper.jpg;
  };
}
