# Domain Doc Format

Two files carry the domain model, and they have different jobs.

- **`.claude/CONTEXT.md`** - prose framing. What this project is, its domain, its users, what is in and out of scope. A few paragraphs, no term list.
- **`docs/internal/glossary.md`** - the canonical term list. Nothing else.

Create both lazily: only when you have something to write.

## `.claude/CONTEXT.md` structure

```md
# {Project Name}

{One or two paragraphs: what this project is, the domain it operates in, and why it exists.}

## Users

{Who uses it, and what they are trying to do.}

## Scope

{What this project is responsible for, and the explicit non-goals.}
```

Keep it free of implementation detail. It orients a reader who has never seen the codebase; it is not a spec.

## `docs/internal/glossary.md` structure

```md
# Glossary

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
