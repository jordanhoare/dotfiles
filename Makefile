DOTFILES  := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix

# Platform detection - pick the named flake configuration. Override with
# PLATFORM=<name> on the make command line.
ifdef WSL_DISTRO_NAME
PLATFORM ?= wsl
else ifeq ($(shell uname),Darwin)
PLATFORM ?= macos
else
PLATFORM ?= linux
endif

# `\#` is the literal `#` escape - bare `#` starts a Make comment.
FLAKE_REF := $(NIX_FLAKE)\#$(PLATFORM)

# macOS activation builds the system derivation first so that darwin-rebuild
# comes from the flake-pinned nix-darwin, not whatever `nix run nix-darwin`
# resolves from the registry. This also handles fresh machines where
# darwin-rebuild is not yet on PATH.
DARWIN_SYSTEM  := $(NIX_FLAKE)\#darwinConfigurations."macos".system
DARWIN_RESULT  := $(NIX_FLAKE)/result
DARWIN_REBUILD := $(DARWIN_RESULT)/sw/bin/darwin-rebuild

.DEFAULT_GOAL := help

.PHONY: help switch secrets hooks decrypt encrypt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

switch: ## activate nix profile for the detected platform
ifeq ($(PLATFORM),macos)
	nix build '$(DARWIN_SYSTEM)' --out-link $(DARWIN_RESULT)
	sudo $(DARWIN_REBUILD) switch --flake $(FLAKE_REF)
else
	nix run '$(NIX_FLAKE)#home-manager' -- switch --flake $(FLAKE_REF)
endif

secrets: ## restore SSH keys from bitwarden and decrypt sops
	$(DOTFILES)/bin/secrets

decrypt: ## unpack any encrypted sops secrets to ~/.config/git/private
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(HOME)/.config/git/private $(DOTFILES)/config/git/private.enc

encrypt: ## re-encrypt ~/.config/git/private back into sops file
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --encrypt --output $(DOTFILES)/config/git/private.enc $(HOME)/.config/git/private

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg
