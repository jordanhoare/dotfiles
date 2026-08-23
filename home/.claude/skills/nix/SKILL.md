---
name: nix
description: Working on the Nix flake that manages this machine - adding packages, linking dotfiles, editing modules, and activating. Use when editing any .nix file, adding a tool, changing what gets symlinked into the home directory, or when a build or activation fails.
---

# Nix

The dotfiles repo manages packages and dotfile symlinks through Nix and Home Manager, with nix-darwin adding system config on macOS. Declare what you want, then activate; never install by hand.

## Layout

```
nix/
├── flake.nix              entry point: darwinConfigurations.macos,
│                          homeConfigurations.linux, homeConfigurations.wsl
├── flake.lock             committed, pins every input
└── modules/
    ├── base.nix           packages and dotfile links shared by all platforms
    ├── linux.nix          native Linux, plus GUI apps
    ├── wsl.nix            WSL, no GUI apps (those come from Windows via winget)
    ├── macos.nix          nix-darwin system config, homebrew casks, nested home-manager
    ├── git.nix            git config linking
    └── profiles.nix       the personal/private git identity split
```

`make switch` builds and activates the config for the detected platform. On macOS it builds the system derivation first so `darwin-rebuild` comes from the flake-pinned nix-darwin rather than the registry.

## Build before you commit

Run `nix build '.#darwinConfigurations.macos.system'` (or the matching `homeConfigurations.<platform>.activationPackage`) from `nix/` and confirm it succeeds before committing any module change. A speculative fix that fails pollutes history. A successful build is not the same as a successful activation: build proves the derivation evaluates, activation proves it applies.

## Traps

**Flakes only see tracked files.** A new file is invisible to the build until `git add`, and the error names the exact command to run. Adding a file under a path the repo gitignores needs an allowlist entry too: `.gitignore` denies `home/.claude/*` and re-allows specific subdirectories with `!`.

**`home.file` preserves the source's mode.** A script needs mode `100755` in git to land executable in the store; there is no `executable` attribute to set. Check with `git ls-files -s <path>`, and verify the result with `ls -l` on the store path, which should read `r-xr-xr-x`. A file committed `100644` lands read-only and any hook or script pointing at it fails silently.

**Link a directory with `recursive = true`.** That makes each file its own symlink into the store, so new files appear without touching the module. Without it the whole directory becomes one symlink and the target must exist exactly as-is.

**Activation runs in phases and stops at the first failure.** On macOS the Homebrew bundle runs before the home-manager file linking, so a failing cask means dotfiles silently do not update even though `nix build` passed. When a switch fails, check whether the phase you cared about ran at all before assuming your change is at fault.

**Homebrew casks are not pinned.** Cask definitions come from the live JSON API on every activation. Pinning brew itself only lets the binary drift behind the metadata, so `homebrew.onActivation.autoUpdate` stays `true`.

## Adding a tool

Add the package to `home.packages` in `nix/modules/base.nix`, or the platform module when it only applies to one. macOS GUI apps that nixpkgs cannot build go in the `homebrew.casks` list in `macos.nix`; `cleanup = "zap"` makes that list authoritative, so removing an entry uninstalls the app.

Language runtimes are the exception: node, python and go come from mise, never from Nix.

## Linking a dotfile

Add an entry to `home.file` in `base.nix`:

```nix
".config/tool/config.toml".source = ../../config/tool/config.toml;

".claude/skills" = {
  source    = ../../home/.claude/skills;
  recursive = true;
};
```

The source path is relative to the module file. Only declared files are linked; everything else in the home directory is left alone.

## When activation fails

1. Read which phase failed. Everything before it succeeded and everything after it did not run.
2. Reproduce the build alone with `nix build`. If that passes, the fault is in activation, not evaluation.
3. For Homebrew failures, check whether brew itself is stale before suspecting the module.
4. Re-run `make switch` after the fix rather than assuming a partial activation left a usable state.
