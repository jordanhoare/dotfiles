DOTFILES := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
HOME_TARGET := $(HOME)
CONFIG_TARGET := $(HOME)/.config
BIN_TARGET := $(HOME)/bin
ETC_TARGET := /etc

.DEFAULT_GOAL := help

.PHONY: help stow decrypt verify hooks brew

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

stow: ## symlink all packages (home, config, bin, etc)
	cd $(DOTFILES) && stow -t $(HOME_TARGET) -R home
	cd $(DOTFILES) && stow -t $(CONFIG_TARGET) -R config
	mkdir -p $(BIN_TARGET)
	cd $(DOTFILES) && stow -t $(BIN_TARGET) -R bin
	cd $(DOTFILES) && sudo stow -t $(ETC_TARGET) -R etc

verify: ## verify key symlinks, tools, and nvim health
	@echo "==> symlinks"
	@test -L $(HOME)/.zshrc            && echo "  ✓ .zshrc"       || echo "  ✗ .zshrc"
	@test -L $(HOME)/.zshenv           && echo "  ✓ .zshenv"      || echo "  ✗ .zshenv"
	@test -L $(HOME)/.zprofile         && echo "  ✓ .zprofile"    || echo "  ✗ .zprofile"
	@test -L $(HOME)/.ssh/config       && echo "  ✓ .ssh/config"  || echo "  ✗ .ssh/config"
	@test -L $(HOME)/.config/git/config && echo "  ✓ .config/git"  || echo "  ✗ .config/git"
	@test -L $(HOME)/.config/starship   && echo "  ✓ starship"     || echo "  ✗ starship"
	@test -L $(HOME)/.config/tmux       && echo "  ✓ tmux"         || echo "  ✗ tmux"
	@test -L $(HOME)/.config/uv/uv.toml && echo "  ✓ uv"          || echo "  ✗ uv"
	@test -L $(HOME)/.config/nvim       && echo "  ✓ nvim"         || echo "  ✗ nvim"
	@test -L $(HOME)/bin/up            && echo "  ✓ bin/up"       || echo "  ✗ bin/up"
	@echo "==> tools"
	@command -v mise     >/dev/null && echo "  ✓ mise"      || echo "  ✗ mise"
	@command -v uv       >/dev/null && echo "  ✓ uv"        || echo "  ✗ uv"
	@command -v go       >/dev/null && echo "  ✓ go"        || echo "  ✗ go"
	@command -v bun      >/dev/null && echo "  ✓ bun"       || echo "  ✗ bun"
	@command -v gh       >/dev/null && echo "  ✓ gh"        || echo "  ✗ gh"
	@command -v glab     >/dev/null && echo "  ✓ glab"      || echo "  ✗ glab"
	@command -v terraform>/dev/null && echo "  ✓ terraform"  || echo "  ✗ terraform"
	@command -v tofu     >/dev/null && echo "  ✓ opentofu"  || echo "  ✗ opentofu"
	@command -v kubectl  >/dev/null && echo "  ✓ kubectl"   || echo "  ✗ kubectl"
	@command -v docker   >/dev/null && echo "  ✓ docker"    || echo "  ✗ docker"
	@echo "==> nvim"
	@command -v nvim >/dev/null 2>&1 \
		&& nvim --headless +qa 2>/dev/null && echo "  ✓ nvim starts cleanly (run :LazyHealth for full check)" \
		|| echo "  ✗ nvim not installed"

brew: ## install all brew packages, casks, and vscode extensions from Brewfile (macOS only)
	@if ! command -v brew >/dev/null 2>&1; then echo "brew not found - skipping"; exit 0; fi
	brew bundle --file=$(DOTFILES)/home/Brewfile

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg

decrypt: ## decrypt SOPS-encrypted files
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(DOTFILES)/config/git/private $(DOTFILES)/config/git/private.enc
