# Glossary

## Bootstrap
The process of setting up a new machine from scratch. Implemented as a staged, idempotent set of bash scripts under `bootstrap/`. Each stage can be re-run safely and always converges to the same end state.

## Dotfile
A configuration file managed by this repository. Dotfiles are symlinked into `$HOME` via stow — editing the file in the repo is immediately live.

## Dotfiles root
The canonical location of the dotfiles repository on any machine: `~/repositories/dotfiles`. Consistent across WSL, native Linux, and macOS.

## Platform
The OS context in which the shell runs. Three supported platforms: **WSL** (Windows Subsystem for Linux, primary), **Linux** (native, e.g. VMs), **macOS**.

## Profile
A git identity context — either **personal** (`jordanhoare`) or **private** (anon). Profiles control `user.name`, `user.email`, and the active `gh` CLI account.

## Stage
A single idempotent step in the bootstrap process. Stages are numbered (`00-prereqs`, `01-clone`, etc.) and can be re-run independently if a previous run failed partway through.

## Symlink
A filesystem pointer from a `$HOME` path (e.g. `~/.zshrc`) to the corresponding file in the dotfiles repo. Managed by stow. Editing the repo file is immediately reflected in the live shell.
