DOTFILES := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix

PLATFORM ?= $(shell \
	if [ -n "$$WSL_DISTRO_NAME" ]; then echo "jordan@wsl"; \
	elif [ "$$(uname)" = "Darwin" ]; then echo "jordan@macos"; \
	else echo "jordan@linux"; fi)

NIX_RUN = $(if $(filter jordan@macos,$(PLATFORM)),nix run nix-darwin --,nix run home-manager/master --)

.DEFAULT_GOAL := help

.PHONY: help switch secrets verify hooks decrypt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

switch: ## activate nix profile for the detected platform
	$(NIX_RUN) switch --flake $(NIX_FLAKE)#$(PLATFORM)

secrets: ## restore SSH keys from bitwarden and decrypt sops
	$(DOTFILES)/bin/secrets

decrypt: ## unpack any encrypted sops secrets into local repo
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(DOTFILES)/config/git/private $(DOTFILES)/config/git/private.enc

verify: ## verify key symlinks, tools, and git identity
	@echo "==> symlinks"
	@test -L $(HOME)/.zshrc             && echo "  ✓ .zshrc"       || echo "  ✗ .zshrc"
	@test -L $(HOME)/.zshenv            && echo "  ✓ .zshenv"      || echo "  ✗ .zshenv"
	@test -L $(HOME)/.zprofile          && echo "  ✓ .zprofile"    || echo "  ✗ .zprofile"
	@test -L $(HOME)/.ssh/config        && echo "  ✓ .ssh/config"  || echo "  ✗ .ssh/config"
	@test -L $(HOME)/.config/git/config && echo "  ✓ .config/git"  || echo "  ✗ .config/git"
	@test -L $(HOME)/.config/starship/starship.toml && echo "  ✓ starship" || echo "  ✗ starship"
	@test -L $(HOME)/.config/tmux/tmux.conf && echo "  ✓ tmux"    || echo "  ✗ tmux"
	@test -L $(HOME)/.config/uv/uv.toml && echo "  ✓ uv"          || echo "  ✗ uv"
	@test -L $(HOME)/.config/nvim       && echo "  ✓ nvim"         || echo "  ✗ nvim"
	@test -L $(HOME)/bin/up             && echo "  ✓ bin/up"       || echo "  ✗ bin/up"
	@echo "==> tools"
	@command -v nix          >/dev/null && echo "  ✓ nix"          || echo "  ✗ nix"
	@command -v mise         >/dev/null && echo "  ✓ mise"         || echo "  ✗ mise"
	@command -v uv           >/dev/null && echo "  ✓ uv"           || echo "  ✗ uv"
	@command -v gh           >/dev/null && echo "  ✓ gh"           || echo "  ✗ gh"
	@command -v kubectl      >/dev/null && echo "  ✓ kubectl"      || echo "  ✗ kubectl"
	@command -v nvim         >/dev/null && echo "  ✓ nvim"         || echo "  ✗ nvim"
	@echo "==> identity"
	@git whoami 2>/dev/null             && echo "  ✓ git identity" || echo "  ✗ git identity (run make secrets)"
	@ssh -T git@personal 2>&1 | grep -q "jordanhoare" && echo "  ✓ ssh personal" || echo "  ✗ ssh personal"
	@ssh -T git@private  2>&1 | grep -q "Hi "         && echo "  ✓ ssh private"  || echo "  ✗ ssh private"

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg
