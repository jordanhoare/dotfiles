# ADR 0012 - One personal agent layer for Claude Code, Cursor and Codex

## Context

The personal agent layer (global instructions, skills, hooks) was written for Claude Code alone. Cursor and Codex are also in use. AincradOT/server ADR 0007 ([AincradOT/server#169](https://github.com/AincradOT/server/issues/169)) researched how the three tools read each piece. This ADR applies the parts that aren't specific to AincradOT to the home directory.

What each tool reads at user level:

| | Claude Code | Cursor | Codex |
|---|---|---|---|
| Instructions | `~/.claude/CLAUDE.md` | User Rules in its settings, not a file | `~/.codex/AGENTS.md` |
| Skills | `~/.claude/skills` | `~/.claude/skills` (behind the third-party toggle) and `~/.agents/skills` | `~/.agents/skills` |
| Hooks | `~/.claude/settings.json` | an import of `~/.claude/settings.json` | `~/.codex/hooks.json` |

Codex follows a symlinked skill directory but skips a symlinked file. Cursor lists a skill once when two roots lead to the same real path.

## Decision

**Instructions.** `home/.claude/AGENTS.md` is the one instruction file, written tool-neutral, and is linked to `~/.codex/AGENTS.md` and `~/.claude/AGENTS.md`. `~/.claude/CLAUDE.md` imports it with `@~/.claude/AGENTS.md` and keeps the two Claude Code-only lines, the `plain` output style and `/ask`; server ADR 0007's "only `@AGENTS.md`" has no such lines to place. Cursor User Rules are pasted by hand.

**Skills.** Every skill follows the frontmatter rule in `writing-for-agents/mechanics.md`. Review enforces it.

**Reachability.** `nix/modules/base.nix` links each skill per file into `~/.claude/skills` and as one directory link into `~/.agents/skills`. Only named children of `~/.agents/skills` are linked, so a skill an installer put there, such as `find-skills`, stays unmanaged.

**Push guard.** Two layers stop an agent pushing `main` or `master`:

- `home/.claude/hooks/block-dangerous-git.sh`, registered in `~/.claude/settings.json` (Cursor imports it) and `~/.codex/hooks.json`, blocks the agent's command before it runs.
- `config/git/hooks/agent-push-guard`, a git config hook (`hook.agent-push-guard` in `config/git/config`), refuses the push when an agent's environment variable is set. Git runs it before a repo's own `pre-push` hook, so repo hooks still run. In AincradOT repos it runs next to the repo's guard from `AincradOT/skills`; both refuse the same push.

## Alternatives rejected

- **A directory link for `~/.claude/skills/<skill>` too:** activation collides with the existing per-file links on every machine.
- **One link for all of `~/.agents/skills`:** it would take over `find-skills` and anything else an installer writes there.
- **A native `~/.cursor/hooks.json`:** Cursor already runs the imported hook, so the guard would run twice.
- **A global `core.hooksPath` for the pre-push layer:** it disables every repo's own `.git/hooks`, pre-commit's included.

## Consequences

- Each machine trusts the Codex hook in `/hooks`, and again whenever `home/.codex/hooks.json` changes.
- Cursor User Rules drift from `AGENTS.md` unless re-pasted after an edit.
- Cursor with the third-party toggle off sees the skills through `~/.agents/skills` but loses the agent hook; the git hook still applies.
- The git hook needs git 2.54 or later, which Nix installs. Apple's `/usr/bin/git` ignores it.
