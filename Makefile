DOTFILES := $(shell pwd)
HOME_TARGET := $(HOME)
CONFIG_TARGET := $(HOME)/.config

.DEFAULT_GOAL := help

.PHONY: help stow unstow restow test install sync

help: ## show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

stow: ## symlink dotfiles into home and ~/.config
	stow -d $(DOTFILES) -t $(HOME_TARGET) home
	stow -d $(DOTFILES) -t $(CONFIG_TARGET) config

unstow: ## remove symlinks
	stow -d $(DOTFILES) -t $(HOME_TARGET) -D home
	stow -d $(DOTFILES) -t $(CONFIG_TARGET) -D config

restow: ## re-apply symlinks (unstow then stow)
	stow -d $(DOTFILES) -t $(HOME_TARGET) -R home
	stow -d $(DOTFILES) -t $(CONFIG_TARGET) -R config

test: ## verify key symlinks are in place
	@test -L $(HOME)/.zshrc       && echo "✓ .zshrc"       || echo "✗ .zshrc"
	@test -L $(HOME)/.zshenv      && echo "✓ .zshenv"      || echo "✗ .zshenv"
	@test -L $(HOME)/.zprofile    && echo "✓ .zprofile"    || echo "✗ .zprofile"
	@test -L $(HOME)/.ssh/config  && echo "✓ .ssh/config"  || echo "✗ .ssh/config"
	@test -L $(HOME)/.config/git  && echo "✓ .config/git"  || echo "✗ .config/git"
	@test -L $(HOME)/.config/starship.toml 2>/dev/null || test -L $(HOME)/.config/starship && echo "✓ starship" || echo "✗ starship"
	@test -L $(HOME)/.config/tmux && echo "✓ tmux"         || echo "✗ tmux"

install: ## install core tooling (requires apt or brew)
	@if command -v apt-get > /dev/null; then \
		sudo apt-get install -y git stow curl; \
	elif command -v brew > /dev/null; then \
		brew install git stow; \
	fi
	@curl -sS https://starship.rs/install.sh | sh
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	@cargo install sheldon
	@curl -LsSf https://astral.sh/uv/install.sh | sh
	@curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash

sync: ## sync second-brain repo
	cd $(HOME)/repositories/second-brain && mise run sync
