# Setup

All platforms use Nix and Home Manager to provision tools and dotfiles. The Windows side uses winget for Windows-native apps, with Nix running inside WSL.

## macOS

### 1. Install Nix

```bash
sh <(curl -L https://nixos.org/nix/install)
```

### 2. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
```

### 3. Activate

```bash
cd ~/repositories/dotfiles
make switch-macos
```

This runs `darwin-rebuild switch`, which installs all tools via nixpkgs, links all dotfiles via Home Manager, and manages Docker Desktop via the nix-darwin Homebrew integration.

### 4. Restore SSH keys

See [Bitwarden SSH Key Restore](Bitwarden-SSH), then switch the remote to SSH:

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 5. Decrypt git identity

```bash
make decrypt
```

### 6. Verify

```bash
make verify
git whoami              # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal     # authenticates as jordanhoare
```

---

## Linux (Debian/Ubuntu)

### 1. Install prerequisites

```bash
sudo apt install -y git curl
```

### 2. Install Nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Open a new shell to pick up the Nix environment.

### 3. Install Home Manager

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### 4. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
```

### 5. Activate

```bash
cd ~/repositories/dotfiles
make switch-linux
```

### 6. Restore SSH keys and decrypt

See [Bitwarden SSH Key Restore](Bitwarden-SSH), then:

```bash
make decrypt
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 7. Verify

```bash
make verify
```

---

## Windows + WSL

See [Windows bootstrap](windows/README.md) for the full Windows-side steps (winutil, winget, WSL install).

Once inside the WSL shell:

### 1. Install Nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Open a new shell.

### 2. Install Home Manager

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### 3. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
```

### 4. Activate

```bash
cd ~/repositories/dotfiles
make switch-wsl
```

### 5. Restore SSH keys and decrypt

See [Bitwarden SSH Key Restore](Bitwarden-SSH), then:

```bash
make decrypt
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 6. Verify

```bash
make verify
git whoami              # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal     # authenticates as jordanhoare
```

---

## Adding tools

Edit the appropriate module in `nix/modules/` and run `make switch`. Never install tools manually with `brew install`, `apt install`, or similar - all tools go through Nix.

To update all packages to the latest nixpkgs:

```bash
make update   # updates flake.lock
make switch   # applies the update
```
