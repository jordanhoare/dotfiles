DOTFILES  := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix
# Must match username in nix/flake.nix.
USERNAME  := jordanhoare

# Platform detection - pick the named flake configuration. Override with
# PLATFORM=<name> on the make command line.
ifdef WSL_DISTRO_NAME
PLATFORM ?= jordan@wsl
else ifeq ($(shell uname),Darwin)
PLATFORM ?= jordan@macos
else
PLATFORM ?= jordan@linux
endif

# `\#` is the literal `#` escape - bare `#` starts a Make comment.
FLAKE_REF := $(NIX_FLAKE)\#$(PLATFORM)

# Attribute path to the active home.file set, consumed by bin/verify and
# bin/doctor. On macOS, Home Manager is nested inside nix-darwin under the
# activating user; on Linux/WSL it is the top-level configuration.
HM_FILES_DARWIN := darwinConfigurations."jordan@macos".config.home-manager.users.$(USERNAME).home.file
HM_FILES_HM     := homeConfigurations."$(PLATFORM)".config.home.file
HM_FILES_ATTR   := $(if $(filter jordan@macos,$(PLATFORM)),$(HM_FILES_DARWIN),$(HM_FILES_HM))

# macOS activation uses the lock-pinned darwin-rebuild built locally under
# nix/result/, not `nix run nix-darwin --`. The latter pulls the registry
# version, which can drift from flake.lock and trigger module-API mismatches.
DARWIN_SYSTEM  := $(NIX_FLAKE)\#darwinConfigurations."jordan@macos".system
DARWIN_RESULT  := $(NIX_FLAKE)/result
DARWIN_REBUILD := $(DARWIN_RESULT)/sw/bin/darwin-rebuild

.DEFAULT_GOAL := help

.PHONY: help switch secrets verify doctor hooks decrypt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --impure is required because hasPrivateProfile in flake.nix uses
# builtins.pathExists on a gitignored file (config/git/private).
# macOS activation runs under sudo; identity comes from the static username
# in flake.nix, not from environment variables.
switch: ## activate nix profile for the detected platform
ifeq ($(PLATFORM),jordan@macos)
	nix build --impure '$(DARWIN_SYSTEM)' --out-link $(DARWIN_RESULT)
	sudo $(DARWIN_REBUILD) switch --flake $(FLAKE_REF) --impure
else
	nix run '$(NIX_FLAKE)#home-manager' -- switch --flake $(FLAKE_REF) --impure
endif

secrets: ## restore SSH keys from bitwarden and decrypt sops
	$(DOTFILES)/bin/secrets

decrypt: ## unpack any encrypted sops secrets into local repo
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(DOTFILES)/config/git/private $(DOTFILES)/config/git/private.enc

verify: ## strict check - every declared Symlink is in place (CI gate)
	@$(DOTFILES)/bin/verify '$(HM_FILES_ATTR)'

doctor: ## verbose local diagnostic - symlinks, tools, git/ssh identity
	@$(DOTFILES)/bin/doctor '$(HM_FILES_ATTR)'

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg
