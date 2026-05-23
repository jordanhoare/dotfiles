# Git Identity

Two profiles - personal and private - with zero coupling between them.

## Switching

```bash
git personal   # switch to jordanhoare + gh auth switch
git private    # switch to private profile
git whoami     # print current identity
```

## Cloning

```bash
git clone git@personal:jordanhoare/repo.git
git clone git@private:<user>/repo.git
```

## Auto-switch

On WSL, repos under `/mnt/d/repositories/private/` automatically use the private identity via `includeIf` in `.gitconfig`. On macOS or native Linux this requires updating the `includeIf` path to match the local repo location.

## Private config

The private git config lives encrypted at `config/git/private.enc`. It is never committed in plaintext. See [SOPS Encryption](SOPS-Encryption) for decrypt instructions.
