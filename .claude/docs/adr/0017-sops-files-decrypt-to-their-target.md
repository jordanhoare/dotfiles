# ADR 0017 - Sops files decrypt to their target path

## Context

The repo had one encrypted file, `config/git/private.enc`, with its own `decrypt` and `encrypt` Tasks and a sops line inside `bin/secrets`. More files are coming: the Reliquia node's ssh host entry is the first, and it must keep the node's address out of the public repo. A per-file Task pair and a per-file line in two restore scripts would grow with every file, and `bin/secrets` would keep a hard path into the repo.

Native Windows is also a development platform (ADR 0014) and needs the same decrypted files, so the mechanism cannot be bash-only.

## Decision

- **A Sops file is a `*.sops` file in the Package that matches its target.** `home/<path>.sops` decrypts to `~/<path>`, `config/<path>.sops` to `~/.config/<path>`. The path is the manifest; no list of files exists to drift.
- **One creation rule in `.sops.yaml`.** `\.sops$` encrypts to the personal SSH key as an age recipient, declared once as a yaml anchor. A file with other readers gets a narrower rule above it, since sops takes the first match.
- **Whole-file binary encryption.** The `.sops` extension is unknown to sops, so it stores each file as one encrypted blob. Config fragments are not yaml, and their diffs stay unreadable.
- **`mise run decrypt` writes every committed Sops file to its target.** It is a `.sh`/`.ps1` pair in `.mise/tasks/`, so the same Task runs on macOS, Linux, WSL and native Windows. It reads `git ls-files '*.sops'`, so an untracked plaintext copy is never touched. Each target is readable by its owner alone: mode 600 on Unix, an `icacls` grant on Windows.
- **The `secrets` Task runs `decrypt` after it.** `depends_post` in `.mise/config.toml` orders the two. `bin/secrets` and `win/secrets.ps1` restore keys and `gh` logins only, and know nothing of sops or the repo layout.
- **A committed config includes each decrypted file.** Home Manager never links a Sops file: the Nix store is world-readable. `config/git/config` picks up `~/.config/git/private` through `[includeIf]`; `home/.ssh/config` opens with `Include ~/.ssh/config.d/*`. Both no-op when the file is missing.
- **Edit a Sops file in place with `sops edit <path>.sops`**, then run `mise run decrypt`. `~/.zshenv` exports `SOPS_AGE_SSH_PRIVATE_KEY_FILE`, so plain `sops` finds the key. There is no `encrypt` Task.

## Considered options

- **A manifest mapping each encrypted file to its target.** Allows any target path. Rejected: the Package layout already maps repo paths to home paths, and a manifest is one more file to keep in step.
- **Decrypt from inside `bin/secrets` and `win/secrets.ps1`.** Rejected: it couples a linked `~/bin` script to the repo layout and duplicates the walk in two languages outside the Task layer.
- **sops-nix or agenix.** Rejected: neither covers native Windows, and both need the key at activation time, which a fresh machine lacks until `mise run secrets` runs.
- **`encrypted_regex` with yaml files, as the Reliquia platform repo does.** Keeps keys reviewable in a diff. Rejected: ssh and git config fragments are not yaml.

## Consequences

- A change made to a decrypted target is lost on the next `mise run decrypt`. The Sops file is the source.
- The private Profile's identity now decrypts on native Windows too, and `config/git/config` matches the Windows paths of the private repos, so the private Profile works there (ADR 0014).
- `sops` joins `win/mise.toml`.
- A Sops file outside `home/` or `config/` is skipped with a warning.
