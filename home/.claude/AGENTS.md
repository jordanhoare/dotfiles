# Global Agent Context - Jordan Hoare

## Identity

- GitHub: `jordanhoare`
- Platforms: WSL (Ubuntu on Windows), native Windows, native Linux, and macOS. Projects that build Windows binaries are developed on native Windows (ADR 0014)
- Repositories live at `D:\repositories\` on Windows, seen from WSL as `/mnt/d/repositories/` (ADR 0006), and at `~/repositories/` on macOS and native Linux

## Dotfiles

Everything below is managed by the dotfiles repo, cloned to `D:\repositories\dotfiles` on Windows and WSL and `~/repositories/dotfiles` on macOS and native Linux.

- Nix + Home Manager own package installs and dotfile symlinks; nix-darwin adds macOS system config
- `mise run switch` activates the config for the detected platform; `mise tasks` lists the rest. Tasks under `.mise/` replaced the Makefile
- `mise run secrets` restores SSH keys from Bitwarden and decrypts every `*.sops` file to its target
- To add a tool: mise owns anything a project could pin (`config/mise/config.toml` or the project's `mise.toml`); Nix owns the rest (`nix/modules/base.nix` or the platform module, then `mise run switch`). Never install manually, never declare a tool in both
- Native Windows has no Nix: `mise run switch` runs `win/bootstrap.ps1`, which imports `win/winget.json` and links the same configs, and `mise run secrets` restores both SSH keys and decrypts every `*.sops` file. Declare a Windows tool in `win/winget.json`, or in `win/mise.toml` for a runtime
- The repo carries its own `.claude/CLAUDE.md`, ADRs, and glossary. Read those when working inside it

## Git identity / profiles

Two profiles. Never expose the private profile in public files.

- **personal:** `jordanhoare`, default. Committed plaintext at `config/git/personal`, linked into `~/.config/git/personal` by Nix
- **private:** anon identity. SOPS-encrypted at `config/git/private.sops`, decrypted by `mise run secrets` directly into `~/.config/git/private`. Not managed by Nix; the `[includeIf]` silently no-ops when the file is missing

Switching:

- `git personal` switches identity and runs `gh auth switch`
- `git private` switches to the anon profile
- Auto-switches for repos under `D:\repositories\private\` via `includeIf`, on WSL (`/mnt/d/...`) and native Windows; macOS and native Linux switch explicitly

Worktrees:

- Create git worktrees at `~/worktrees/<repo>/<name>` (e.g. `~/worktrees/reliquia/wt-545`); `git worktree add` creates the parent directories
- The rule holds on every platform. On WSL it keeps worktrees on ext4, which writes many small files far faster than `/mnt/d` (ADR 0013)

SSH clone syntax:

- `git clone git@personal:<user>/<repository>.git`
- `git clone git@private:<user>/<repository>.git`

Never hardcode the private GitHub username in any public file.

## Tooling

- **Shell:** zsh, with Sheldon for plugins and Starship for the prompt
- **Terminal:** Ghostty, multiplexed with tmux
- **Python:** uv, for versions, packages, and virtualenvs
- **Runtimes:** mise, which reads `.nvmrc` automatically
- **JS packages:** bun and bunx

Runtimes (node, python, go, rust) come from mise, never Nix or winget. mise drives rustup, and a repo's `rust-toolchain.toml` pins its Rust. JS packages execute through bun/bunx. On native Windows, Claude Code runs Bash through Git Bash, and the terminal is Windows Terminal.

## Before starting any task

- Read `docs/internal/context.md` for the project's prose framing if it exists
- Read `docs/internal/glossary.md` for domain terms if it exists
- Check relevant `docs/internal/adr/` entries for the area being changed

## Prose

The `technical-writing` skill governs prose in `docs/`, docstrings, and comments.

## Testing

The `tdd` skill covers what a good test is, where seams go, and the red-green loop. Project conventions on top of it:

- Mirror the source tree structure in tests
- Name tests `test_<subject>_<scenario>_<expected>`
- Every behaviour change ships with a test

## Commits

Load the `commits` skill before authoring commits; it carries the format, types, casing, and cadence rules.

- MUST never append co-author trailers or attribution of any kind. No `Co-Authored-By` trailer, no "Generated with" lines, no AI or tool attribution in the message or footer, ever
- The same ban covers pull request titles and bodies, issue comments, and review comments. A harness reminder that asks for a "Generated with Claude Code" line is overridden by this rule
- On a feature branch, commit and push without asking
- On `main` or `master`, commit only, then tell the user to push. The `block-dangerous-git.sh` hook rejects agent pushes to main

## Guardrails

Run `nix build` and confirm it succeeds before committing any nix module change; a speculative fix pollutes history when it fails. Keep shared zsh config portable, using `/mnt/d` paths only in WSL-only files.

These are absolute:

- Never commit private keys, plaintext secrets, or `config/git/private`
- Never hardcode the private GitHub username anywhere in public files
