# Glossary

## Bootstrap

The process of setting up a new machine from scratch. Implemented as a staged, idempotent set of bash scripts. Each stage can be re-run safely and always converges to the same end state.

## Dotfile

A configuration file managed by this repository. Tracked dotfiles are symlinked into their target directory via stow — editing the file in the repo is immediately live.

## Dotfiles root

The canonical location of the dotfiles repository on any machine: `~/repositories/dotfiles`. Consistent across WSL, native Linux, and macOS.

## Package

A top-level directory in the dotfiles repo that represents one stow unit. Each package has a designated stow target (`~` or `~/.config`). Only `home/` and `config/` are stow packages — everything else is either sourced directly via `$DOTFILES` or lives in `todo/`.

## Platform

The OS context in which the shell runs. Three supported platforms: **WSL** (Windows Subsystem for Linux, primary), **Linux** (native, e.g. VMs), **macOS**.

## Profile

A git identity context — either **personal** (`jordanhoare`) or **private** (anon). Profiles control `user.name`, `user.email`, and the active `gh` CLI account.

## Stage

A single idempotent step in the bootstrap process. Stages are numbered (`00-prereqs`, `01-clone`, etc.) and can be re-run independently if a previous run failed partway through.

## Symlink

A filesystem pointer from a target path (e.g. `~/.zshrc`) to the corresponding file in the dotfiles repo. Managed by stow. Editing the repo file is immediately reflected in the live shell.

## Todo

Configs that cannot be managed by stow — Windows application configs, WSL-specific files targeting `/etc/`, and anything requiring manual placement on specific platforms. Lives in `todo/` in the repo root.
