DOTFILES := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix

PLATFORM ?= $(shell \
	if [ -n "$$WSL_DISTRO_NAME" ]; then echo "jordan@wsl"; \
	elif [ "$$(uname)" = "Darwin" ]; then echo "jordan@macos"; \
	else echo "jordan@linux"; fi)

# macOS system activation must run as root. sudo resets PATH and USER/HOME, so
# pass the invoking user's identity through (otherwise the env-derived identity in
# flake.nix resolves to root:/var/root instead of the real user).
# Home Manager (Linux/WSL) activates in user space and must NOT use sudo.
#
# Activation uses the darwin-rebuild from the lock-pinned nix-darwin (built locally
# under nix/result/), NOT `nix run nix-darwin --`. The latter fetches the registry
# version, which can drift from flake.lock and cause module-API mismatches like
# `home-manager.users.root.home.homeDirectory: null`.

# Flake attribute path to the active home.file set. On macOS, Home Manager is
# nested inside the nix-darwin configuration under the activating user.
HM_FILES_ATTR = $(if $(filter jordan@macos,$(PLATFORM)),darwinConfigurations.\"jordan@macos\".config.home-manager.users.$(USER).home.file,homeConfigurations.\"$(PLATFORM)\".config.home.file)

.DEFAULT_GOAL := help

.PHONY: help switch secrets verify doctor hooks decrypt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

switch: ## activate nix profile for the detected platform
ifeq ($(PLATFORM),jordan@macos)
	nix build --impure $(NIX_FLAKE)#darwinConfigurations.\"$(PLATFORM)\".system --out-link $(NIX_FLAKE)/result
	sudo USER="$$(logname)" HOME="$(HOME)" $(NIX_FLAKE)/result/sw/bin/darwin-rebuild switch --flake $(NIX_FLAKE)#$(PLATFORM) --impure
else
	nix run home-manager/master -- switch --flake $(NIX_FLAKE)#$(PLATFORM) --impure
endif

secrets: ## restore SSH keys from bitwarden and decrypt sops
	$(DOTFILES)/bin/secrets

decrypt: ## unpack any encrypted sops secrets into local repo
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(DOTFILES)/config/git/private $(DOTFILES)/config/git/private.enc

verify: ## strict check - every declared Symlink is in place (CI gate)
	@$(DOTFILES)/bin/verify $(HM_FILES_ATTR)

doctor: ## verbose local diagnostic - symlinks, tools, git/ssh identity
	@$(DOTFILES)/bin/doctor $(HM_FILES_ATTR)

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg
