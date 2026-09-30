# ADR 0012 - One personal agent layer for Claude Code, Cursor and Codex

## Context

The personal agent layer (global instructions, skills, hooks) was written for Claude Code alone. Cursor and Codex are also in use. The AincradOT server repo researched how the three tools read instructions, skills and hooks, and recorded the result as its ADR 0007 ([AincradOT/server#169](https://github.com/AincradOT/server/issues/169)). This ADR applies the parts that are not specific to AincradOT to the home directory.

What each tool reads at user level:

| | Claude Code | Cursor | Codex |
|---|---|---|---|
| Instructions | `~/.claude/CLAUDE.md` | User Rules in its settings, not a file | `~/.codex/AGENTS.md` |
| Skills | `~/.claude/skills` | `~/.claude/skills` (behind the third-party toggle) and `~/.agents/skills` | `~/.agents/skills` |
| Hooks | `~/.claude/settings.json` | its own `~/.cursor/hooks.json`, plus an import of `~/.claude/settings.json` | `~/.codex/hooks.json` |

Three facts shape the links:

- Codex follows a symlinked skill directory but skips a symlinked file.
- Cursor 3.22 lists a skill once when two roots lead to the same real path.
- Codex reads only `name` and `description` from frontmatter, and takes manual-only from an `agents/openai.yaml` sidecar.

## Decision

**Instructions.** `home/.claude/AGENTS.md` is the one instruction file, written tool-neutral. Home Manager links it to `~/.codex/AGENTS.md` and `~/.claude/AGENTS.md`. `~/.claude/CLAUDE.md` imports it with `@~/.claude/AGENTS.md` and adds only Claude Code lines: the `plain` output style and the `/ask` router. The import names the home path, so it resolves whichever path Claude Code takes as the base of a symlinked file. Cursor User Rules cannot be managed as a file, so the text is pasted by hand (see the wiki Home page).

**Skills.** Every skill follows the frontmatter rule in the `writing-for-agents` skill (`mechanics.md`):

- Only `name`, `description` and `disable-model-invocation`. The description is one line of at most 1024 characters, quoted when it holds a colon followed by a space.
- Arguments are described in prose, never as `$ARGUMENTS`.
- A manual-only skill sets `disable-model-invocation: true`, ships `agents/openai.yaml` with `policy.allow_implicit_invocation: false`, and has no `paths`.

`argument-hint` is dropped with the placeholders. Codex and Cursor ignore it, and the prose carries the same hint.

**Reachability.** `nix/modules/base.nix` links each skill twice:

- `~/.claude/skills/<skill>`, per file (`recursive = true`), as before.
- `~/.agents/skills/<skill>`, as one directory link.

Both resolve to the same store path, so Cursor lists each skill once, and Codex sees a directory it follows. Only named children of `~/.agents/skills` are linked; the directory itself stays a real directory. A skill that a third-party installer put there, such as `find-skills` from `npx skills`, is left alone and stays unmanaged.

**Push guard.** `home/.claude/hooks/block-dangerous-git.sh` is the one guard script:

- Claude Code registers it in `~/.claude/settings.json` with the matcher `Bash|Shell`.
- Cursor imports that registration. `Shell` covers Cursor's name for the tool in case its `Bash` mapping does not apply inside a regex.
- Codex registers it in `~/.codex/hooks.json`, linked from `home/.codex/hooks.json`.

The script reads `tool_input.command`, with Cursor's top-level `command` as a fallback. On a block it prints the deny JSON on stdout, the reason on stderr, and exits 2, which all three tools treat as a block. It adds the Nix profile to `PATH`, because Cursor can launch it from a GUI environment without it.

## Alternatives rejected

- **Switch `~/.claude/skills/<skill>` to a directory link too.** Activation would find a real directory of links where the new link goes, and stop with a collision or a `.bak` rename on every machine. The per-file links already resolve to the same store path, so nothing is gained.
- **Link all of `~/.agents/skills` as one directory.** It would take over `find-skills` and anything else an installer writes there.
- **A native `~/.cursor/hooks.json`.** Cursor already runs the imported hook, and a second registration would run the guard twice. It becomes worth adding only if the third-party toggle is turned off.
- **`commandWindows` in the Codex hook.** The dotfiles manage no Windows-side `%USERPROFILE%\.codex`. Codex under WSL runs the Linux command.

## Consequences

- `make switch` after merge activates the links. Until then the machine keeps the old layer.
- Each machine trusts the Codex hook once in Codex's `/hooks`, and again whenever `home/.codex/hooks.json` changes. Editing the script needs no new approval.
- Cursor User Rules drift from `AGENTS.md` unless they are re-pasted after an edit.
- Cursor with the third-party toggle off sees the skills through `~/.agents/skills` but loses the imported guard.
- Unverified: whether Cursor expands `~` in an imported hook command, and whether each model auto-invokes a skill. Explicit `/name` (Claude Code, Cursor) and `$name` (Codex) are the supported paths.
