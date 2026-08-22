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

Never add language runtimes (node, python, go) to Nix. Runtimes come from mise; JS packages execute through bun/bunx.

## Before starting any task

- Read `.claude/CONTEXT.md` for the project's prose framing if it exists
- Read `docs/internal/glossary.md` for domain terms if it exists
- Check relevant `docs/internal/adr/` entries for the area being changed
- Load appropriate skills from `.claude/skills/` for specialised workflows

## Available skills

Load a skill when the task matches its domain. Skills live in `.claude/skills/<name>/SKILL.md`.

| Skill | When to load |
|---|---|
| `commits` | Any commit authoring - follow conventional commits format |
| `tdd` | Writing or refactoring tests |
| `design` | Deep-module vocabulary: interfaces, seams, depth, adapters |
| `architecture` | Architectural review or refactor proposals (HTML report) |
| `domain` | Building the glossary or recording an ADR |
| `grill` | Relentless interview that also writes the domain docs |
| `grilling` | Relentless interview on its own, no doc side effects |
| `wayfinder` | Planning work too big for one session as decision tickets |
| `prd` | Writing a product requirements document |
| `issue` | Breaking work into GitHub/GitLab issues with blocking edges |
| `triage` | Triaging or labelling issues and external PRs |
| `prototype` | Throwaway prototype to answer a design question |
| `debug` | Diagnosing hard bugs or performance regressions |
| `review` | Reviewing a branch against repo standards and its spec |
| `research` | Investigating a question against primary sources |
| `setup` | Scaffolding per-repo engineering config |
| `uv` | Python dependency or virtualenv management |
| `ruff` | Python linting or formatting |
| `ty` | Python type checking |
| `mkdocs` | Documentation site generation |
| `dotnet` | General .NET / C# tooling - `dotnet` CLI, analyzers, formatting, central package management |

## Code style

- No comments unless the WHY is non-obvious (hidden constraint, subtle invariant, workaround for a specific bug)
- No multi-line comment blocks or documentation stubs
- Prefer editing existing files over creating new ones
- No features, refactoring, or abstractions beyond what the task requires
- No backwards-compatibility shims for removed code
- Explicit code over clever one-liners
- Always catch specific exceptions, no bare or catch-all error handlers
- Never reference ADRs or design docs from code comments; write a short inline why instead

## Writing style

- No em-dashes (`—`) or en-dashes (`–`). Use `-` (hyphen with spaces) or commas
- Active voice, succinct prose
- Self-documenting names, full words, no abbreviations (`user_age` not `age`)

## Testing

The `tdd` skill covers what a good test is, where seams go, and the red-green loop. Project conventions on top of it:

- Use the project's canonical test runner (check `CLAUDE.md` or `CONTRIBUTING.md`)
- Mirror the source tree structure in tests
- Descriptive test names: `test_<subject>_<scenario>_<expected>`
- Always add a test for changed behaviour

## Commits

Load the `commits` skill before authoring commits; it carries the format, types, casing, and cadence rules.

- MUST never append co-author trailers or attribution of any kind. No `Co-Authored-By: Claude`, no "Generated with" lines, no AI or tool attribution in the message or footer, ever
- Never commit without explicit approval. A past "commit" instruction does not authorise follow-up commits; wait for confirmation that a fix actually works before committing iterations
- Never push to remote unless explicitly asked

## What NOT to do

- Never use `/mnt/d` paths in shared zsh config; those are WSL-only
- Never commit nix module changes without running `nix build` first. Speculative fixes pollute history when they fail
- Never commit private keys, plaintext secrets, or `config/git/private`
- Never hardcode the private GitHub username anywhere in public files
