# ADR 0004 — Internal docs layout

## Context

Agent-facing documentation needs a stable, predictable layout so Claude Code skills can navigate the repo without per-project instruction.

## Decision

Agent-facing docs live under `.claude/docs/`:

- `context.md` - domain framing and navigation hub for agents, no term definitions
- `glossary.md` - every canonical term, the single source of truth for vocabulary
- `adr/` - decision records, sequentially numbered

Wiki pages under `.github/wiki/` are user-facing setup material and are kept separate.

## Consequences

- `CLAUDE.md` is the operational source of truth, distinct from `context.md`
- Skills referencing `docs/internal/` resolve to `.claude/docs/` in this repo
