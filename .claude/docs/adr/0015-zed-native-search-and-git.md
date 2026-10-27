# ADR 0015 - Zed native project search and git views over Television tasks

## Context

`config/zed/keymap.json` bound `cmd-shift-f` to `zed::NoAction` and then to a task that ran `tv text` in the integrated terminal, and `cmd-p` to a task that ran `tv files`. Each task opened a single file. That predated Zed's native git stack and hid the built-in project search, which returns every hit as an editable multibuffer with regex and replace. No binding reached Project Diff, the staged and unstaged multibuffers, the commit editor, or the branch picker; `cmd-g` opened the Git Panel, the weakest of the three git views.

Zed has no plugin ecosystem comparable to VSCode. Extensions supply languages, themes, icon themes, slash commands, and MCP servers. Everything else is the built-in feature set configured through `settings.json` and `keymap.json`.

## Decision

Use Zed's native search and git views. The Television tasks and their bindings are removed; `tv` stays installed for shell use.

- `base_keymap: "VSCode"` supplies `cmd-shift-f` (project search), `cmd-p` (file finder), and `cmd-shift-h` (project replace)
- `cmd-g` opens Project Diff (`git::Diff`); `cmd-shift-g` focuses the Git Panel; `cmd-k` chords open commit, branch, staged, unstaged, stash, and worktree views
- `diff_view_style` is `unified`; `git_panel.tree_view` is on; hunks use `staged_hollow` with stage and restore buttons
- `auto_update` is on, and `homebrew.onActivation.upgrade` is on so `make switch` upgrades casks; the git views shipped between Zed 1.4 and 1.13 (2026) and the installed 1.5.3 lacked them

## Consequences

- `tasks.json` holds only shell-launch tasks
- A stale Zed shows an older diff view; `auto_update` keeps the binary current, at the cost of untracked upgrades
- Revisit `diff_view_style` after a week of use; `split` is Zed's default
