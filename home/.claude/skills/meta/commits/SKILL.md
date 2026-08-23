---
name: commits
description: Guide for creating conventional commit messages. Use when making git commits or when user asks about commit message format.
---

# Conventional Commits

[Conventional Commits](https://www.conventionalcommits.org/). Where a project automates semantic versioning or changelog generation from commit history, the type is what drives the version bump, so the message is a released artifact.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Casing

**Always lowercase. Subject and body. Acronyms included (`api`, `cli`, `dsl`, `adr`, `ci`, `wsl`, `nix`, `pr`).**

Only two exceptions:

- The `BREAKING CHANGE:` footer token. The Conventional Commits spec mandates this exact uppercase form and tools parse for it literally. Prose after the token is still lowercase.
- Backticked code identifiers, since they are code rather than prose: `` `Transform` ``, `` `get_dag` ``, `` `ADR-0006` ``, `` `Cargo.toml` ``. Anything not backticked is lowercased.

✅ Good:

```text
feat(nix): expose home-manager files output to drop username from makefile
fix(cli): grid view not refreshing after task actions
refactor(git): extract profile switching into an alias, reducing duplication per `ADR-0004`
```

❌ Bad:

```text
feat(Nix): Expose home-manager files output to drop USERNAME from Makefile
fix(CLI): Grid view not refreshing after task actions
refactor(Git): Extract profile switching into an ALIAS, reducing duplication per ADR-0004
```

## Types

- `feat`: New feature (→ MINOR version bump)
- `fix`: Bug fix (→ PATCH version bump)
- `docs`: Documentation only
- `style`: Code style/formatting
- `refactor`: Code restructuring without behavior change
- `perf`: Performance improvement
- `test`: Adding/updating tests
- `build`: Build system or dependency changes
- `ci`: CI configuration changes
- `chore`: Maintenance tasks
- `revert`: Revert previous commit

## Scopes

The scope is the module or area affected. Take it from the repo's own vocabulary: a package name, a module path, or a term from the project glossary. Keep the set small and reuse it, so the changelog groups sensibly.

Examples from this dotfiles repo: `nix`, `git`, `zsh`, `secrets`, `skills`, `claude`.

## Breaking Changes

Add `BREAKING CHANGE:` footer or `!` after type/scope:

```
feat(api)!: change query syntax to method chains

BREAKING CHANGE: `Rule` class removed, use `Transform` instead
```

## Guidelines for Agents

### Commit Frequency

- Commit after each **verified logical unit**, not after each file edit.
- A logical unit is the smallest set of changes that makes sense on its own and has been proven to work (built, tested, validated by the user, or otherwise exercised end-to-end).
- Do NOT commit halfway through a feature. Do NOT commit individual files that are part of one larger change.
- Do NOT batch *unrelated* work into one commit either - one concern per commit still holds.

### One Concern Per Commit (a concern can span multiple files)

A "concern" is the thing the user asked for, not a single file change. Most concerns naturally span multiple files: a feature touches code + tests + docs; a refactor touches code + the ADR documenting it; a config change touches the source file + the consumer + the docs.

**Stage and commit all of them together as one commit.**

Single-file commits are a smell. If you find yourself writing five commits in a row that each touch one file in the same feature area, that is one commit, not five.

Good (one feature, four files, one commit):

```text
feat(win): add windows bootstrap script

introduces win/bootstrap.ps1 with winget import + per-file symlinks
for managed editor config. updates win/readme and the wiki to point
at the new entry point. records adr 0011 with the design rationale.
```

Files in that commit: `win/bootstrap.ps1`, `win/README.md`, `.github/wiki/Windows.md`, `.claude/docs/adr/0011-windows-bootstrap.md`.

Bad (same work fragmented across five commits):

```text
feat(win): add windows bootstrap script         # win/bootstrap.ps1
docs(adr): record windows bootstrap design      # adr/0011
docs(win): rewrite readme around bootstrap      # win/README.md
docs(wiki): rebuild windows page                # .github/wiki/Windows.md
docs(glossary): split bootstrap entry           # glossary.md
```

This is over-committing. Reviewers and changelog readers want one entry per concern, not five for the same thing.

### Batching Rules

When a request triggers changes across multiple files, batch them as **one commit per logical concern**, not one commit per file. Common batches:

- **Feature introduction**: source + tests + docs + glossary/ADR updates -> ONE commit.
- **Refactor**: all touched files + the doc explaining why -> ONE commit.
- **Cross-cutting docs sync**: README + wiki + glossary entries for the same concept -> ONE commit titled by the concern, not three commits titled by file.
- **Iterative fixes during the same session**: if a fresh commit immediately needs a follow-up fix you discovered while verifying, prefer `git commit --amend` over a "X, then fix(X)" pair in the log.

Only split into multiple commits when concerns are genuinely independent (different features, unrelated bug fixes, an opportunistic style cleanup discovered in passing).

### Verify Before Committing

Do not commit code that has not been validated. "Validated" means: it compiles, passes lints/tests, runs without throwing, or - for changes the agent cannot exercise locally - the user has confirmed the behaviour works.

A user saying "yes do it" is permission to start, not confirmation it worked. Wait for the verification signal before committing. For multi-file concerns, hold all of them in the working tree until the whole unit is verified, then commit them together.

Premature commits force ugly follow-ups when verification reveals a bug.

### When to Commit

Commit after:

- A verified feature is complete across all its touched files (source + tests + docs)
- A bug fix is verified to fix the bug
- A refactor is complete and existing tests still pass
- A standalone style/formatting cleanup that is genuinely independent of the surrounding work

Do not commit:

- Half-written code that does not compile
- Individual files that are part of a larger unverified change
- Multiple unrelated concerns together
- Same-session fixes for a buggy commit you just made - amend instead

### Never Push

Agents should commit locally but NEVER push to remote unless specifically requested by the user.

## Examples

```bash
# feature with scope
feat(parser): add support for nested function calls

allows expressions like max(min(a, b), c). parser now handles
recursive call structures with proper precedence.

# bug fix
fix(sync): prevent null-materialization for update targets

previously tolerant mode would null-materialize missing fields
for both add and update. now only add targets get this behavior,
preserving the hard rule that update requires existing fields.

# documentation
docs(api): update `Transform` api examples with new syntax

# refactoring
refactor(runtime): extract the interpreter into its own module

moves interpretation logic from `engine/local.py` to a new `runtime/`
module, reducing coupling per `ADR-0006`.

# test addition
test(parser): add parametrized test for builtin validation

# breaking change
feat(api)!: replace `Rule` with `Transform`

BREAKING CHANGE: `Rule` class has been removed. all dsl code must
use `Transform` instead. see migration guide in `docs/api/migration.md`
```

## Message Quality

Focus on **user impact**, not implementation details:

✅ Good: `fix(cli): grid view not refreshing after task actions`
❌ Bad: `fix(cli): initialize dag bundles in get_dag function`

✅ Good: `feat(parser): support nested function calls in expressions`
❌ Bad: `feat: add recursive parser`

## Semantic versioning

Where release tooling reads the history, the type drives the bump:

- `feat` → minor
- `fix` → patch
- `BREAKING CHANGE` → major
- Other types → no bump, but they still appear in the changelog

Write as though the changelog is generated and published, because it usually is.
