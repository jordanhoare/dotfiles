---
name: mkdocs
description: Load this file whenever Python library code changes and documentation needs updating or when scaffolding/auditing docs for a project using MkDocs Material + mkdocstrings.
---

# mkdocs

This project uses [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) with [mkdocstrings](https://mkdocstrings.github.io/) to generate documentation from source docstrings.

## When to use

This skill is the docs side of the documentation-discipline loop defined in
the project's [AGENTS.md](../../../AGENTS.md). Code changes are not complete
until the docs change in the same commit. Load this skill when any of these
trigger:

- **Public API changes** - new function, class, type, or exception, or a
  rename / signature change. Update the relevant `docs/api/*.md` page and
  any snippets referenced from guides.
- **A docstring is added, changed, or missing** - mkdocstrings renders
  these into the API pages.
- **A new domain term enters the codebase** - add it to
  `docs/internal/glossary.md` using the format in
  `.claude/skills/grill/format.md`.
- **A load-bearing architectural decision is made** - write an ADR in
  `docs/internal/adr/` using the format in
  `.claude/skills/grill/adr.md`. Update the Decisions nav.
- **A new Issue `code` is introduced** - declare a `CodeDef` constant in
  `src/quill/diagnostics/_codes.py`; the error-codes page
  auto-renders from the registry.
- **A docs page needs creating, updating, or removing** - update the
  `mkdocs.yaml` nav at the same time. `--strict` will catch orphans.
- **The nav in `mkdocs.yaml` needs updating**.
- **A pattern or convention documented in another skill changes** - update
  that skill file so it reflects the current codebase.

Verify every doc-touching change with `uv run mkdocs build --strict`
before committing. The pre-commit gate runs this too, but running it
yourself catches issues before the hook fails.

## Commands

```bash
uv run mkdocs serve --livereload   # Preview locally at http://127.0.0.1:8000
uv run mkdocs build --strict       # Build - fails on any warning (used in CI)
```

Always verify with `--strict` before committing docs changes.

## Project layout

```
docs/
├── api/          # Reference pages - rendered from docstrings via :::
├── concepts/     # High-level concept explanations for public-API consumers
├── guide/        # Practical how-to guides
├── internal/     # Glossary, principles, structure, pipeline, release, ADRs
│   ├── glossary.md   # Canonical domain glossary (single source of truth)
│   ├── overview.md   # Navigational hub linking everything internal
│   └── adr/          # Architectural decision records
├── snippets/     # Reusable Python examples (named sections)
└── index.md      # Home page
mkdocs.yaml       # Site config, nav, plugins, extensions
```

Source lives in `src/quill/`. API reference pages use `:::` directives pointing to `quill.*` paths.

The domain glossary at `docs/internal/glossary.md` is the canonical vocabulary;
consult it before naming pages, sections, classes, or terms in prose.

## Writing style

**Never use em-dashes (`—`).** Always use a standard hyphen with spaces (` - `) instead.

```
# Wrong
A lightweight engine — minimal footprint.

# Correct
A lightweight engine - minimal footprint.
```

This applies to all docs, docstrings, comments, and prose throughout the repo.

## Grid cards

Material grid cards must use `-` (dash + 3 spaces) for list items and `---` (4-space indent) as the separator. This is the only format that survives `mdformat` without being rewritten.

```markdown
<div class="grid cards" markdown>

-   :material-icon: **[Title](path.md)**

    ---

    Description text.

    [:octicons-arrow-right-24: Link text](path.md)

-   :material-icon: **[Title](path.md)**

    ---

    Description text.

    [:octicons-arrow-right-24: Link text](path.md)

</div>
```

Do not use `-` (single space) or `---` without 4-space indent - mdformat will convert the separator to `***` and break the card layout.

## Updating API reference

API pages live in `docs/api/` and are hand-maintained - no auto-generation script.

When a public symbol changes, update its docstring in source first (mkdocstrings renders from source), then verify the relevant `docs/api/*.md` page has a `:::` directive for it.

Directive format:

```markdown
::: quill.sdk.executors.local.LocalExecutor
```

Global options are set in `mkdocs.yaml` - do not add per-directive `options:` blocks unless overriding a specific setting.

## Docstring style

This project uses **Google style** with fenced code blocks (not `>>>`). Collapsible examples use `???` admonitions directly in the docstring body:

```python
def compile_source(source: Source, schema: Schema) -> Program:
    """Compile a Source against a Schema into an executable Program.

    Parse and compile once, then reuse across many Datasets.

    ??? example "Example"
        ```python
        program = compile_source(source, schema)
        plan = reconcile(program, dataset, introspector=executor.introspector)
        outcome = executor.execute(plan, dataset)
        ```
    """
```

## Code snippets

Reusable examples live in `docs/snippets/` as named sections:

```python
# --8<-- [start:basic]
from quill import compile_source, reconcile
program = compile_source(source, schema)
# --8<-- [end:basic]
```

Reference in markdown:

```markdown
```python
--8<-- "docs/snippets/executors.py:basic"
```

```

All snippet files are linted by ruff. Per-file ignores for snippet-specific rules are set in `pyproject.toml` under `[tool.ruff.lint.per-file-ignores]`.

## Nav

The nav is defined in `mkdocs.yaml`. Every `.md` file must appear in the nav - `--strict` will catch orphans. When adding or removing pages, update the nav at the same time.

## Common pitfalls

- **Do not use em-dashes** - use ` - ` (hyphen with spaces) everywhere
- **Do not use `- ` for grid card items** - use `-   ` (3 spaces) so mdformat preserves `---` separators
- **Do not duplicate parameter docs in guide pages** - mkdocstrings renders those from source
- **Do not add `options:` to `:::` directives** - global options in `mkdocs.yaml` apply everywhere
- **Snippet imports must use `quill`** - not `rff` or any other alias
- **`merge_init_into_class: true` is set globally** - do not document `__init__` separately
