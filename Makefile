DOTFILES := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix

PLATFORM ?= $(shell \
	if [ -n "$$WSL_DISTRO_NAME" ]; then echo "jordan@wsl"; \
	elif [ "$$(uname)" = "Darwin" ]; then echo "jordan@macos"; \
	else echo "jordan@linux"; fi)

# macOS system activation must run as root. sudo resets PATH (so call nix by absolute
# path) and USER/HOME (so pass the invoking user's identity through, otherwise the
# env-derived identity in flake.nix resolves to root:/var/root instead of the real user).
# Home Manager (Linux/WSL) activates in user space and must NOT use sudo.
NIX := $(shell command -v nix)
SUDO_NIX = sudo USER="$$(logname)" HOME="$(HOME)" $(NIX) run nix-darwin --
NIX_RUN = $(if $(filter jordan@macos,$(PLATFORM)),$(SUDO_NIX),nix run home-manager/master --)

# Attribute path into the declared home.file set, dispatched by platform.
# On macOS, Home Manager is nested inside the nix-darwin configuration under
# the activating user; elsewhere it lives at the top-level homeConfigurations.
HM_FILES_ATTR = $(if $(filter jordan@macos,$(PLATFORM)),darwinConfigurations.\"jordan@macos\".config.home-manager.users.$(shell echo $$USER).home.file,homeConfigurations.\"$(PLATFORM)\".config.home.file)

.DEFAULT_GOAL := help

.PHONY: help switch secrets verify hooks decrypt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

switch: ## activate nix profile for the detected platform
	$(NIX_RUN) switch --flake $(NIX_FLAKE)#$(PLATFORM) --impure

secrets: ## restore SSH keys from bitwarden and decrypt sops
	$(DOTFILES)/bin/secrets

decrypt: ## unpack any encrypted sops secrets into local repo
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(DOTFILES)/config/git/private $(DOTFILES)/config/git/private.enc

verify: ## verify declared symlinks, tools, and git identity
	@echo "==> symlinks (derived from home.file in $(PLATFORM))"
	@nix eval --impure --json $(NIX_FLAKE)#$(HM_FILES_ATTR) --apply 'fs: builtins.attrNames fs' 2>/dev/null \
		| jq -r '.[] | select(startswith("/") | not) | select(test("^(Applications/Home Manager Apps|Library/Fonts/)") | not) | select(endswith("/.keep") | not)' \
		| while IFS= read -r f; do \
			test -L "$(HOME)/$$f" && echo "  ✓ $$f" || echo "  ✗ $$f"; \
		done
	@echo "==> tools"
	@command -v nix          >/dev/null && echo "  ✓ nix"          || echo "  ✗ nix"
	@command -v mise         >/dev/null && echo "  ✓ mise"         || echo "  ✗ mise"
	@command -v uv           >/dev/null && echo "  ✓ uv"           || echo "  ✗ uv"
	@command -v gh           >/dev/null && echo "  ✓ gh"           || echo "  ✗ gh"
	@command -v kubectl      >/dev/null && echo "  ✓ kubectl"      || echo "  ✗ kubectl"
	@command -v nvim         >/dev/null && echo "  ✓ nvim"         || echo "  ✗ nvim"
	@echo "==> identity"
	@if [ -f $(HOME)/.ssh/personal ]; then \
		git whoami 2>/dev/null             && echo "  ✓ git identity" || echo "  ✗ git identity (run make secrets)"; \
		ssh -T git@personal 2>&1 | grep -q "jordanhoare" && echo "  ✓ ssh personal" || echo "  ✗ ssh personal"; \
		ssh -T git@private  2>&1 | grep -q "Hi "         && echo "  ✓ ssh private"  || echo "  ✗ ssh private"; \
	else \
		echo "  - identity checks skipped (no ~/.ssh/personal; run make secrets to enable)"; \
	fi

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg
