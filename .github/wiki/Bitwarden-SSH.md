# Bitwarden SSH Key Restore

SSH keys are stored as SSH Key type items in Bitwarden and restored to disk via `bin/secrets`, which is installed by Nix on first switch. You do not need to install `bw` or `jq` manually.

## Restore

```bash
make secrets
```

This logs in to Bitwarden, fetches both SSH keys, writes them to `~/.ssh/`, and decrypts the private git identity via SOPS. See `bin/secrets` for the full script.

## Verify

```bash
ssh-keygen -y -f ~/.ssh/personal
ssh-keygen -y -f ~/.ssh/private
```

## Notes

- Never export `BW_SESSION` in `.zshenv` or any persisted shell config - it is session-only
- On WSL, run `make secrets` inside WSL - the Bitwarden Desktop app on Windows does not share a CLI session
