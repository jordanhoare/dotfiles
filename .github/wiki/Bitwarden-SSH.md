# Bitwarden SSH Key Restore

SSH keys are stored as SSH Key type items in Bitwarden and restored to disk via the CLI.

## Install

```bash
# Ubuntu/WSL
wget "https://vault.bitwarden.com/download/?app=cli&platform=linux" -O bw.zip
unzip bw.zip && chmod +x bw && sudo mv bw /usr/local/bin/
sudo apt install jq

# macOS
brew install bitwarden-cli jq
```

## Restore

```bash
bw login
export BW_SESSION=$(bw unlock --raw)

ID=$(bw list items --search "personal" | jq -r '.[] | select(.type == 5) | .id')
bw get item "$ID" | jq -r '.sshKey.privateKey' > ~/.ssh/personal

ID=$(bw list items --search "private" | jq -r '.[] | select(.type == 5) | .id')
bw get item "$ID" | jq -r '.sshKey.privateKey' > ~/.ssh/private

chmod 600 ~/.ssh/personal ~/.ssh/private
bw lock
```

## Verify

```bash
ssh-keygen -y -f ~/.ssh/personal
ssh-keygen -y -f ~/.ssh/private
```

## Notes

- Never export `BW_SESSION` in `.zshenv` or any persisted shell config - it is session-only
- On WSL, run all `bw` commands inside WSL - the Bitwarden Desktop app on Windows does not share a session
