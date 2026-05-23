DOTFILES := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
NIX_FLAKE := $(DOTFILES)/nix

.DEFAULT_GOAL := help

.PHONY: help switch switch-linux switch-wsl switch-macos verify hooks decrypt

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

switch: ## activate Home Manager config for the detected platform
	@if [[ -n "$$WSL_DISTRO_NAME" ]]; then \
		$(MAKE) switch-wsl; \
	elif [[ "$$(uname)" == "Darwin" ]]; then \
		$(MAKE) switch-macos; \
	else \
		$(MAKE) switch-linux; \
	fi

switch-wsl: ## activate WSL Home Manager config
	home-manager switch --flake $(NIX_FLAKE)#jordan@wsl

switch-linux: ## activate Linux Home Manager config
	home-manager switch --flake $(NIX_FLAKE)#jordan@linux

switch-macos: ## activate macOS nix-darwin config (includes Home Manager)
	darwin-rebuild switch --flake $(NIX_FLAKE)#jordan

secrets: ## restore SSH keys from Bitwarden and decrypt git identity
	@echo "==> logging in to Bitwarden"
	@BW_SESSION=$$(bw login jordanhoare0@gmail.com --raw 2>/dev/null || bw unlock --raw); \
	echo "==> restoring personal SSH key"; \
	mkdir -p $(HOME)/.ssh; \
	bw get item "personal SSH key" --session $$BW_SESSION | jq -r '.notes' > $(HOME)/.ssh/personal; \
	echo "==> restoring private SSH key"; \
	bw get item "private SSH key" --session $$BW_SESSION | jq -r '.notes' > $(HOME)/.ssh/private; \
	chmod 600 $(HOME)/.ssh/personal $(HOME)/.ssh/private; \
	echo "==> locking Bitwarden session"; \
	bw lock
	@echo "==> decrypting git identity"
	$(MAKE) decrypt
	@echo "==> run 'make switch' to link the decrypted identity"

update: ## update flake.lock to latest nixpkgs
	nix flake update --flake $(NIX_FLAKE)

verify: ## verify key symlinks and tools
	@echo "==> symlinks"
	@test -L $(HOME)/.zshrc            && echo "  ✓ .zshrc"       || echo "  ✗ .zshrc"
	@test -L $(HOME)/.zshenv           && echo "  ✓ .zshenv"      || echo "  ✗ .zshenv"
	@test -L $(HOME)/.zprofile         && echo "  ✓ .zprofile"    || echo "  ✗ .zprofile"
	@test -L $(HOME)/.ssh/config       && echo "  ✓ .ssh/config"  || echo "  ✗ .ssh/config"
	@test -L $(HOME)/.config/git/config && echo "  ✓ .config/git"  || echo "  ✗ .config/git"
	@test -L $(HOME)/.config/starship/starship.toml && echo "  ✓ starship" || echo "  ✗ starship"
	@test -L $(HOME)/.config/tmux/tmux.conf && echo "  ✓ tmux"    || echo "  ✗ tmux"
	@test -L $(HOME)/.config/uv/uv.toml && echo "  ✓ uv"         || echo "  ✗ uv"
	@test -L $(HOME)/.config/nvim      && echo "  ✓ nvim"         || echo "  ✗ nvim"
	@test -L $(HOME)/bin/up            && echo "  ✓ bin/up"       || echo "  ✗ bin/up"
	@echo "==> tools"
	@command -v nix          >/dev/null && echo "  ✓ nix"        || echo "  ✗ nix"
	@command -v home-manager >/dev/null && echo "  ✓ home-manager" || echo "  ✗ home-manager"
	@command -v mise         >/dev/null && echo "  ✓ mise"        || echo "  ✗ mise"
	@command -v uv           >/dev/null && echo "  ✓ uv"          || echo "  ✗ uv"
	@command -v gh           >/dev/null && echo "  ✓ gh"          || echo "  ✗ gh"
	@command -v kubectl      >/dev/null && echo "  ✓ kubectl"     || echo "  ✗ kubectl"
	@command -v nvim         >/dev/null && echo "  ✓ nvim"        || echo "  ✗ nvim"

hooks: ## install pre-commit hooks
	pre-commit install
	pre-commit install --hook-type commit-msg

decrypt: ## decrypt SOPS-encrypted files
	SOPS_AGE_SSH_PRIVATE_KEY_FILE=$(HOME)/.ssh/personal sops --decrypt --output $(DOTFILES)/config/git/private $(DOTFILES)/config/git/private.enc
