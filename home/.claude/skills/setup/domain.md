# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`docs/internal/context.md`** — prose domain framing (what the project is, its domain, users, scope) and the navigation hub for internal docs. Read this first to orient.
- **`docs/internal/glossary.md`** — the canonical term list.
- **`docs/internal/adr/`** — ADRs that touch the area you're about to work in. In multi-context repos, also check `src/<context>/docs/internal/adr/` for context-scoped decisions.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The producer skill (`/grill`) creates them lazily when terms or decisions actually get resolved.

## File structure

Single-context repo (most repos):

```
/
├── docs/internal/context.md
├── docs/internal/glossary.md
├── docs/internal/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── .../
```

Multi-context repo:

```
/
├── docs/internal/context.md
├── docs/internal/glossary.md
├── docs/internal/adr/                          ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── docs/internal/context.md
    │   └── docs/internal/adr/                  ← context-specific decisions
    └── billing/
        ├── docs/internal/context.md
        └── docs/internal/adr/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `docs/internal/glossary.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/grill`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
