# Global Claude Code Context - Jordan Hoare

## Identity

- GitHub: `jordanhoare`
- Primary platform: WSL (Ubuntu on Windows), also native Linux and macOS
- Repositories live at `/mnt/d/repositories/` on WSL, `~/repositories/` on macOS and native Linux (ADR 0006)

## Dotfiles

Everything below is managed by the dotfiles repo, cloned to `/mnt/d/repositories/dotfiles` on WSL and `~/repositories/dotfiles` on macOS and native Linux.

- Nix + Home Manager own package installs and dotfile symlinks; nix-darwin adds macOS system config
- `make switch` activates the config for the detected platform
- `make secrets` restores SSH keys from Bitwarden and decrypts the private git identity
- To add a tool, declare it in `nix/modules/base.nix` or the platform module and run `make switch`. Never install manually
- The repo carries its own `.claude/CLAUDE.md`, ADRs, and glossary. Read those when working inside it

## Git identity / profiles

Two profiles. Never expose the private profile in public files.

- **personal:** `jordanhoare`, default. Committed plaintext at `config/git/personal`, linked into `~/.config/git/personal` by Nix
- **private:** anon identity. SOPS-encrypted at `config/git/private.enc`, decrypted by `make secrets` directly into `~/.config/git/private`. Not managed by Nix; the `[includeIf]` silently no-ops when the file is missing

Switching:

- `git personal` switches identity and runs `gh auth switch`
- `git private` switches to the anon profile
- Auto-switches for repos under `/mnt/d/repositories/private/` via `includeIf` (WSL only; other platforms switch explicitly)

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

Runtimes (node, python, go) come from mise, never Nix. JS packages execute through bun/bunx.

## Before starting any task

- Read `.claude/CONTEXT.md` for the project's prose framing if it exists
- Read `docs/internal/glossary.md` for domain terms if it exists
- Check relevant `docs/internal/adr/` entries for the area being changed
- Skills live in `.claude/skills/<name>/SKILL.md`; their descriptions are already in context. Run `/ask` for how they chain into flows

## Code style

- Comment only to record a WHY the code cannot show: a hidden constraint, a subtle invariant, a workaround for a specific bug. One line, inline, at the thing it explains
- Build exactly what the task requires; leave removed code removed, with no compatibility shim
- Catch the specific exception you expect

## Writing style

- Punctuate with `-` (hyphen with spaces), commas, or colons. Never em-dashes (`—`) or en-dashes (`–`)
- Name things in full words: `user_age`, not `age`

## Testing

The `tdd` skill covers what a good test is, where seams go, and the red-green loop. Project conventions on top of it:

- Mirror the source tree structure in tests
- Name tests `test_<subject>_<scenario>_<expected>`
- Every behaviour change ships with a test

## Commits

Load the `commits` skill before authoring commits; it carries the format, types, casing, and cadence rules.

- MUST never append co-author trailers or attribution of any kind. No `Co-Authored-By: Claude`, no "Generated with" lines, no AI or tool attribution in the message or footer, ever
- Never commit without explicit approval. A past "commit" instruction does not authorise follow-up commits; wait for confirmation that a fix actually works before committing iterations
- Never push to remote unless explicitly asked

## Guardrails

Run `nix build` and confirm it succeeds before committing any nix module change; a speculative fix pollutes history when it fails. Keep shared zsh config portable, using `/mnt/d` paths only in WSL-only files.

These are absolute:

- Never commit private keys, plaintext secrets, or `config/git/private`
- Never hardcode the private GitHub username anywhere in public files
