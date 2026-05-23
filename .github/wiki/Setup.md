# Setup

All platforms use Nix and Home Manager to provision tools and dotfiles. The Windows side uses winget for Windows-native apps, with Nix running inside WSL.

Bootstrap requires two passes of `make switch` on a fresh machine - the first installs `bw` and `sops` via Nix, the second picks up the private git identity after secrets are restored.

---

## macOS

### 1. Install Nix

Follow the macOS instructions at https://nixos.org/download/#nix-install-macos

### 2. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
cd ~/repositories/dotfiles
```

### 3. First switch

Installs all tools (including `bw` and `sops`). Private git identity is skipped - it does not exist yet.

```bash
make switch-macos
```

### 4. Restore secrets

Authenticates with Bitwarden, restores SSH keys, and decrypts the private git identity.

```bash
make secrets
```

Switch the remote to SSH now that `~/.ssh/config` and the personal key are in place:

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 5. Second switch

Links the now-decrypted private git identity.

```bash
make switch-macos
```

### 6. Verify

```bash
make verify
git whoami              # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal     # authenticates as jordanhoare
ssh -T git@private      # authenticates as private account
```

---

## Linux (Debian/Ubuntu)

### 1. Install prerequisites

```bash
sudo apt install -y git curl
```

### 2. Install Nix

Follow the Linux instructions at https://nixos.org/download/#nix-install-linux

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
cd ~/repositories/dotfiles
```

### 5. First switch

```bash
make switch-linux
```

### 6. Restore secrets

```bash
make secrets
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 7. Second switch

```bash
make switch-linux
```

### 8. Verify

```bash
make verify
git whoami
ssh -T git@personal
```

---

## Windows + WSL

See [windows/README.md](../windows/README.md) for the full Windows-side steps (winutil, winget, WSL install).

Once inside the WSL shell:

### 1. Install Nix

Follow the Linux instructions at https://nixos.org/download/#nix-install-linux

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
cd ~/repositories/dotfiles
```

### 4. First switch

```bash
make switch-wsl
```

### 5. Restore secrets

```bash
make secrets
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 6. Second switch

```bash
make switch-wsl
```

### 7. Verify

```bash
make verify
git whoami              # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal     # authenticates as jordanhoare
ssh -T git@private      # authenticates as private account
```

---

## Adding tools

Edit the appropriate module in `nix/modules/` and run `make switch`. Never install tools manually with `brew install`, `apt install`, or similar - all tools go through Nix.

To update all packages to latest nixpkgs:

```bash
make update   # updates flake.lock
make switch   # applies the update
```
