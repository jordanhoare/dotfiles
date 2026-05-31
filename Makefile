DOTFILES := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix

# Use bash so verify can use `fail=0; ...; exit $$fail` accumulation
# across a single recipe shell.
SHELL := /bin/bash

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

verify: ## verify declared symlinks, tools, and git identity (exits non-zero on failure)
	@fail=0; \
	echo "==> symlinks (derived from home.file in $(PLATFORM))"; \
	while IFS= read -r f; do \
		if test -L "$(HOME)/$$f"; then echo "  ✓ $$f"; else echo "  ✗ $$f"; fail=1; fi; \
	done < <(nix eval --impure --json $(NIX_FLAKE)#$(HM_FILES_ATTR) --apply 'fs: builtins.attrNames fs' 2>/dev/null \
		| jq -r '.[] | select(startswith("/") | not) | select(test("^(Applications/Home Manager Apps|Library/Fonts/)") | not) | select(endswith("/.keep") | not)'); \
	echo "==> tools"; \
	for tool in nix mise uv gh kubectl nvim; do \
		if command -v "$$tool" >/dev/null; then echo "  ✓ $$tool"; else echo "  ✗ $$tool"; fail=1; fi; \
	done; \
	echo "==> identity"; \
	if [ -f $(HOME)/.ssh/personal ]; then \
		if git whoami 2>/dev/null >/dev/null; then echo "  ✓ git identity"; else echo "  ✗ git identity (run make secrets)"; fail=1; fi; \
		if ssh -T git@personal 2>&1 | grep -q "jordanhoare"; then echo "  ✓ ssh personal"; else echo "  ✗ ssh personal"; fail=1; fi; \
		if ssh -T git@private  2>&1 | grep -q "Hi ";         then echo "  ✓ ssh private";  else echo "  ✗ ssh private";  fail=1; fi; \
	else \
		echo "  - identity checks skipped (no ~/.ssh/personal; run make secrets to enable)"; \
	fi; \
	exit $$fail

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg
