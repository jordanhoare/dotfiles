---
name: ask
description: Ask which skill or flow fits the situation. A router over the installed skills.
disable-model-invocation: true
---

# Ask

You don't remember every skill, so ask.

A **flow** is a path through the skills. Most work runs along one **main flow**, and three **on-ramps** merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath.

## The main flow: idea to ship

The route most work travels. You have an idea and want it built.

1. **`/grill`** sharpens the idea by interview, a round of questions at a time. It's stateful: what it learns lands in `.claude/CONTEXT.md`, the glossary at `docs/internal/glossary.md`, and ADRs in `docs/internal/adr/`. Start here whenever you're in a working directory. For an interview with no paper trail (no repo, or you don't want the docs touched), use **`/grilling`** instead: same primitive, no side effects.

2. **Branch: can you settle every question in conversation?** If a question needs a runnable answer (a state model, business logic, a UI you have to see), detour through **`/prototype`** to answer it with throwaway code, then come back.

3. **Branch: is this a multi-session build?**
   - **Yes** → **`/prd`** turns the thread into a PRD, then **`/issue`** splits it into tracer-bullet issues, each declaring its **blocking edges**. Work the **frontier**: any issue whose blockers are done. Kick off **`/implement`** per issue, clearing context between each one.
   - **No** → **`/implement`** right here, in the same window.

   Either way **`/implement`** drives **`/tdd`** internally at pre-agreed seams, one red-green slice at a time, then closes by running **`/review`** over the diff before committing. Reach for **`/tdd`** alone to build one concrete behaviour test-first without a full PRD, and **`/review`** alone to review a branch against a fixed point.

4. **`/commits`** carries the conventional-commit format and casing. It's model-invoked, so it fires on its own when you commit.

### Context hygiene

Keep steps 1 to 3 in **one unbroken context window** so the grilling, PRD, and issues all build on the same thinking. Each `/implement` then starts fresh from its issue, which is self-contained by construction, so the previous one's context is disposable.

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **Bugs and requests piling up** → **`/triage`**. Moves issues and external PRs through triage roles and produces agent-ready briefs, which `/implement` later picks up. Triage is only for issues **you didn't create**; what `/issue` produced is already agent-ready, so don't triage it.

- **Something's broken** → **`/debug`**. For the hard ones: the bug that resists a first glance, the intermittent flake, the regression between two known-good states. It refuses to theorise until it has a tight feedback loop that already goes red on *this* bug, then fixes with a regression test. When the real finding is that there's no good seam to lock the bug down, it hands off to `/architecture`.

- **A huge, foggy effort, too big for one session** → **`/wayfinder`**. When the way to the destination isn't visible yet, it charts a **shared map** of **decision tickets** on the tracker and resolves them one at a time, producing decisions rather than deliverables. Where `/grill` sharpens an idea you can hold in one session, wayfinder is for the one you can't. When the map clears it hands off rather than building: merge onto the main flow at `/prd`.

## Codebase health

Not feature work, just upkeep.

- **`/architecture`** surveys the codebase for **deepening opportunities** and presents them as an HTML report. Picking one generates an idea you take into the main flow at `/grill`. It's the survey that finds candidates; `/design` is the bench you design the chosen one on.

## Vocabulary underneath

Model-invoked references that run *beneath* the other skills, each the single source of truth for its vocabulary. Reach for them directly when the **words**, not the process, are the problem; or let the skills above pull them in.

- **`/design`**: the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's shape. `/tdd` and `/architecture` both speak it. Its design-it-twice pattern spins up parallel sub-agents to design one interface several radically different ways.
- **`/domain`**: sharpen the project's *domain* language. Challenge a fuzzy term, resolve an overloaded word, record a hard-to-reverse decision as an ADR. The active discipline `/grill` drives.

## Standalone

- **`/setup`** scaffolds a repo's engineering config: issue tracker, triage labels, domain doc layout. Run once, before first use of `/issue`, `/prd`, `/triage`, `/architecture` or `/wayfinder` in a new repo.
- **`/research`** investigates a question against primary sources and writes the findings to a Markdown file.
- **`/merge-conflicts`** resolves an in-progress merge or rebase, finding the intent behind each side before picking. It always resolves, never aborts.
- **`/wizard`** generates an interactive bash script that walks a **human** through steps only they can perform: provisioning, credentials, CI secrets, an unfamiliar dashboard, a one-off cutover. Reach for it the moment you hit a step the agent cannot do, instead of dumping numbered instructions into the chat.
- **`/writing-for-agents`** is the reference for writing any document an agent consumes: this file, a `SKILL.md`, a `CLAUDE.md`. Model-invoked, so it fires when you edit one.
- **`/wait-what`** is the one to type the moment a message doesn't land. It re-pitches with context, in Simplified Technical English, using the project's own vocabulary.

## Language-specific

These fire on their own when you touch the relevant files; they aren't part of any flow.

- **Python**: `/uv` (packages, virtualenvs), `/ruff` (lint, format), `/ty` (type check)
- **.NET**: `/dotnet` (CLI, analyzers, central package management)
- **Nix**: `/nix` (flake layout, adding tools, linking dotfiles, why a switch failed)
- **Docs**: `/mkdocs` (MkDocs Material + mkdocstrings)
