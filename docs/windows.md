1. Enable NTFS metadata for proper symlinks

In WSL, edit or create /etc/wsl.conf:
```
[automount]
options = "metadata,uid=1000,gid=1000"
```

Then from Windows PowerShell run:
```wsl --shutdown```

This makes /mnt/d/... honour Linux perms and symlinks.


2. 
```
sudo apt update
sudo apt install -y stow
```

3.
```
cd /mnt/d/repositories/dotfiles
stow --target="$HOME" zsh
```
