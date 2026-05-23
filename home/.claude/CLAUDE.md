# Global Claude Code Context — Jordan Hoare

## Identity

- GitHub: `jordanhoare`
- Primary platform: WSL (Ubuntu on Windows), also native Linux and macOS
- Repositories live at `~/repositories/`

## Git identity / profiles

Two profiles — never expose the private profile in public files:

- **personal:** `jordanhoare` — default
- **private:** anon identity — stored encrypted at `config/git/private.enc`, decrypts to `config/git/private` (gitignored, symlinked to `~/.config/git/private` via stow)

Switching:

- `git personal` — switch to jordanhoare + gh auth switch
- `git private` — switch to anon profile
- Auto-switches in `~/repositories/private/` via `includeIf` in `.gitconfig`

SSH clone syntax:

- `git clone git@personal:jordanhoare/repo.git`
- `git clone git@private:<user>/repo.git`

Never hardcode the private GitHub username in any public file.

## Tooling

- **Shell:** zsh
- **Terminal:** Ghostty
- **Multiplexer:** tmux
- **Prompt:** Starship
- **Plugin manager:** Sheldon
- **Symlinks:** Home Manager `home.file` (dotfiles managed at `~/repositories/dotfiles`)
- **Python:** uv (versions, packages, and virtualenvs — never use pip or virtualenv directly)
- **Node:** nvm

## Before starting any task

- Read `docs/internal/glossary.md` for domain terms if it exists
- Check relevant `docs/internal/adr/` entries for the area being changed
- Load appropriate skills from `.claude/skills/` for specialised workflows

## Available skills

Load a skill when the task matches its domain. Skills live in `.claude/skills/<name>/SKILL.md`.

| Skill | When to load |
|---|---|
| `commits` | Any commit authoring — follow conventional commits format |
| `tdd` | Writing or refactoring tests |
| `architecture` | Architectural review or refactor proposals |
| `issue` | Breaking work into GitHub/Gitlab issues |
| `triage` | Triaging or labelling issues on the tracker |
| `prd` | Writing a product requirements document |
| `grill` | Deep codebase exploration with domain awareness |
| `setup` | Scaffolding per-repo engineering config |
| `uv` | Python dependency or virtualenv management |
| `ruff` | Python linting or formatting |
| `ty` | Python type checking |
| `mkdocs` | Documentation site generation |

## Code style

- No comments unless the WHY is non-obvious (hidden constraint, subtle invariant, workaround for a specific bug)
- No multi-line comment blocks or documentation stubs
- Prefer editing existing files over creating new ones
- No features, refactoring, or abstractions beyond what the task requires
- No backwards-compatibility shims for removed code
- Explicit code over clever one-liners
- Always catch specific exceptions — no bare/catch-all error handlers
- Never reference ADRs or design docs from code comments — write a short inline why instead

## Writing style

- No em-dashes (`—`) or en-dashes (`–`) — use `-` (hyphen with spaces) or commas
- Active voice, succinct prose
- Self-documenting names — full words, no abbreviations (`user_age` not `age`)

## Testing

- Use the project's canonical test runner (check `CLAUDE.md` or `CONTRIBUTING.md`)
- Prefer integration tests over unit tests where applicable
- Mirror the source tree structure in tests
- Descriptive test names: `test_<subject>_<scenario>_<expected>`
- Always add a test for changed behaviour

## Commits

Load the `commits` skill (`.claude/skills/commits/SKILL.md`) before authoring commits. Follow [Conventional Commits](https://www.conventionalcommits.org/). Format: `<type>[scope]: <description>`.

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Breaking changes: append `!` or add `BREAKING CHANGE:` footer.

- MUST never append co-author trailers or attribution of any kind to commits. No `Co-Authored-By: Claude`, no "Generated with" lines, no AI/tool attribution in the message or footer - ever.
- Commit after each logical unit — never one monolithic commit at the end
- One concern per commit
- Never push to remote unless explicitly asked

## What NOT to do

- Never use `/mnt/d` paths in shared zsh config — WSL-only
- Never commit private keys, plaintext secrets, or `config/git/private`
- Never hardcode the private GitHub username anywhere in public files
