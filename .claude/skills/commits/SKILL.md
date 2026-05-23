---
name: commits
description: Guide for creating conventional commit messages. Use when making git commits or when user asks about commit message format.
---

# Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning and changelog generation via `python-semantic-release`.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
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

Common scopes for this project (use the module/area affected):
- `compiler` - DSL compilation logic
- `reconcile` - Schema reconciliation layer
- `executor` - Execution backends (local, Spark)
- `diagnostics` - Error handling system
- `api` - Public API changes
- Or use specific file/module names

## Breaking Changes

Add `BREAKING CHANGE:` footer or `!` after type/scope:
```
feat(compiler)!: change DSL syntax to method chains

BREAKING CHANGE: Rule class removed, use Transform instead
```

## Guidelines for Agents

### Commit Frequency
- Commit after EACH logical change unit
- DO NOT wait until task completion to commit
- Break work into digestible commits

### One Concern Per Commit
Good sequence:
```bash
test(compiler): add test for nested calls
feat(compiler): implement nested call support
docs(api): document nested call syntax
refactor(compiler): extract call resolution
```

Bad sequence:
```bash
feat: add feature  # Too vague
wip                # Not descriptive
fix everything     # Too broad
```

### When to Commit

✅ Commit after:
- Adding a new test (red phase)
- Making test pass (green phase)
- Completing a refactor
- Adding/updating docs for specific change
- Fixing a specific bug/lint issue

❌ Don't commit:
- Half-written code that doesn't compile
- Code breaking existing tests (except documented red phase)
- Multiple unrelated changes together

### Pre-Commit Verification

Before each commit:
```bash
make prepare              # Format, lint, build docs
uv run ty check src       # Type safety (if touching src)
uv run pytest <area> -v   # Run affected tests
```

Pre-commit hooks will auto-enforce basic checks.

### Never Push

Agents should commit locally but NEVER push to remote. The user controls when to push.

## Examples

```bash
# Feature with scope
feat(compiler): add support for nested function calls

Allows expressions like max(min(a, b), c). Parser now handles
recursive call structures with proper precedence.

# Bug fix
fix(reconcile): prevent null-materialization for update targets

Previously tolerant mode would null-materialize missing fields
for both add and update. Now only add targets get this behavior,
preserving the hard rule that update requires existing fields.

# Documentation
docs(api): update Transform API examples with new syntax

# Refactoring
refactor(executor): extract bytecode interpreter into runtime pillar

Moves interpretation logic from executor/local.py to new runtime/
module, reducing coupling per ADR-0006.

# Test addition
test(compiler): add parametrized test for builtin validation

# Breaking change
feat(compiler)!: replace Rule with Transform

BREAKING CHANGE: Rule class has been removed. All DSL code must
use Transform instead. See migration guide in docs/api/migration.md
```

## Message Quality

Focus on **user impact**, not implementation details:

✅ Good: `fix: Grid view not refreshing after task actions`
❌ Bad: `fix: Initialize Dag bundles in CLI get_dag function`

✅ Good: `feat(compiler): support nested function calls in expressions`
❌ Bad: `feat: add recursive parser`

## Integration with Semantic Release

Commit types affect version bumping:
- `feat` → 1.x.0 (minor)
- `fix` → 1.0.x (patch)
- `BREAKING CHANGE` → x.0.0 (major)
- Other types → no version bump (but appear in changelog)

The changelog is auto-generated from commit messages, so clarity matters for users reviewing release notes.
