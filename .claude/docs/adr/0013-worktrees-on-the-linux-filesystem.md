# ADR 0013 - Worktrees on the Linux filesystem

## Context

ADR 0006 puts every WSL repository on `/mnt/d/repositories/`, where drvfs/9p makes each file write slow. Agents create git worktrees beside the checkout, so a worktree pays the same cost: a worktree of reliquia (about 17.7k tracked files) took several minutes to check out.

A worktree is throwaway. It is built and reviewed on the branch, then removed, so the Windows toolchain and Windows apps that justify ADR 0006 do not need to reach it.

## Decision

Agents create git worktrees at `~/worktrees/<repo>/<name>` on every platform. On WSL that path is on ext4. `git worktree add` creates the parent directories, so Home Manager does not manage `~/worktrees`.

`config/git/config` also sets `checkout.workers = 8` and `checkout.thresholdForParallelism = 100`, so a checkout on `/mnt/d` writes files in parallel.

## Consequences

- Worktree checkout and builds run at native filesystem speed on WSL
- Windows-side tools cannot open a worktree by a `D:\` path; work that needs them happens in the main checkout
- On macOS and native Linux the rule changes nothing about speed and keeps one path for every platform
