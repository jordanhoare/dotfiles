# Setup

All platforms use Nix and Home Manager to provision tools and dotfiles. The Windows side uses winget for Windows-native apps, with Nix running inside WSL.

`make switch` auto-detects the platform. Override with `make switch PLATFORM=jordan@linux` if needed.

Bootstrap requires two passes on a fresh machine - the first installs `bw` and `sops` via Nix, the second picks up the private git identity after secrets are restored.

---

## macOS

### 1. Install Nix

Follow the macOS instructions at https://nixos.org/download/#nix-install-macos

Open a new shell to pick up the Nix environment.

### 2. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
cd ~/repositories/dotfiles
```

### 3. First switch

```bash
make switch
```

### 4. Restore secrets

```bash
make secrets
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 5. Second switch

```bash
make switch
```

### 6. Verify

```bash
make verify
```

---

## Linux (Debian/Ubuntu)

### 1. Install prerequisites

```bash
sudo apt install -y git curl make
```

### 2. Install Nix

Follow the Linux instructions at https://nixos.org/download/#nix-install-linux

Open a new shell to pick up the Nix environment.

### 3. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
cd ~/repositories/dotfiles
```

### 4. First switch

```bash
make switch
```

### 5. Restore secrets

```bash
make secrets
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 6. Second switch

```bash
make switch
```

### 7. Verify

```bash
make verify
```

---

## Windows + WSL

See [windows/README.md](../windows/README.md) for the full Windows-side steps (winutil, winget, WSL install).

Once inside the WSL shell:

### 1. Install prerequisites

```bash
sudo apt install -y git curl make
```

### 2. Install Nix

Follow the Linux instructions at https://nixos.org/download/#nix-install-linux

Open a new shell.

### 3. Clone dotfiles

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
cd ~/repositories/dotfiles
```

### 4. First switch

```bash
make switch
```

### 5. Restore secrets

```bash
make secrets
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

### 6. Second switch

```bash
make switch
```

### 7. Verify

```bash
make verify
```

---

## Adding tools

Edit the appropriate module in `nix/modules/` and run `make switch`. Never install tools manually with `brew install`, `apt install`, or similar - all tools go through Nix.

To update all packages to latest nixpkgs, run `up` from anywhere in your shell.
