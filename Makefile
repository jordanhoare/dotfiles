DOTFILES := $(shell pwd)
HOME_TARGET := $(HOME)
CONFIG_TARGET := $(HOME)/.config

.DEFAULT_GOAL := help

.PHONY: help stow verify

stow: ## Symlink dotfiles into home and ~/.config
	stow -d $(DOTFILES) -t $(HOME_TARGET) -R home
	stow -d $(DOTFILES) -t $(CONFIG_TARGET) -R config

verify: ## Verify key symlinks are in place
	@test -L $(HOME)/.zshrc       && echo "✓ .zshrc"       || echo "✗ .zshrc"
	@test -L $(HOME)/.zshenv      && echo "✓ .zshenv"      || echo "✗ .zshenv"
	@test -L $(HOME)/.zprofile    && echo "✓ .zprofile"    || echo "✗ .zprofile"
	@test -L $(HOME)/.ssh/config  && echo "✓ .ssh/config"  || echo "✗ .ssh/config"
	@test -L $(HOME)/.config/git  && echo "✓ .config/git"  || echo "✗ .config/git"
	@test -L $(HOME)/.config/starship     && echo "✓ starship"     || echo "✗ starship"
	@test -L $(HOME)/.config/tmux && echo "✓ tmux"         || echo "✗ tmux"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
