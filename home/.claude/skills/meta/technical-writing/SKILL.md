---
name: technical-writing
description: Sentence-level standard for technical prose. Use when writing or editing a doc under `docs/` (ADR, glossary, guide, README), a docstring, or a code comment.
---

The `plain` output style bans the filler constructions everywhere. This skill governs the sentence in written artefacts, where the reader arrives without the conversation around it.

Three surfaces, three audiences. Apply the shared method to all three, then the surface rules for the one you are writing.

For how a document is *structured* (what to inline, what to push behind a pointer, where a step ends), use `writing-for-agents`. That skill is the architecture; this one is the sentence.

## The shared method

Borrowed from ASD-STE100, the controlled-English standard for maintenance documentation. Take the method, not the standard: there is no approved-word dictionary here, because the project glossary is the dictionary.

- **One meaning per word.** A term means one thing across the whole repo. If `docs/internal/glossary.md` defines it, use that word and only that word.
- **Never synonym-swap a glossary term.** Writing "job", "task", and "run" for one concept reads as variety and costs the reader a re-derivation every time. Repeat the term.
- **One topic per sentence.** Two clauses joined by "and" are usually two sentences.
- **Active voice.** "The hook rejects the write", not "the write is rejected by the hook".
- **Imperative for instructions.** "Run `make switch`", not "you should run" or "the user can run".
- **No forward references.** "As we will see below" and "more on this later" mean the material is in the wrong order. Move it.
- **Delete transition-only sentences.** If a sentence's only job is to introduce the next one, the next one already does that job.

**Completion criterion:** every glossary term in the artefact appears in its glossary form, every sentence carries one topic, and no sentence exists only to introduce another.

## `docs/` prose

ADRs, guides, READMEs, glossary entries. A human reads these cold, months later, deciding something.

- **Claim first, evidence under it.** Open the paragraph with the thing being asserted. Do not build to it.
- **No throat-clearing introduction.** Cut any opening paragraph that describes what the document will cover; the headings already do.
- **Name the concrete thing.** The file path, the function, the flag, the version. "The config" is not a referent.
- **An ADR records the decision and what was given up.** If the alternatives section does not name a real cost of the chosen option, it is decoration.
- **A glossary entry defines, it does not describe.** One sentence stating what the term denotes, then the boundary against the term it is most often confused with.

## Docstrings

Google style, per the `mkdocs` skill. Read in an IDE tooltip, next to the signature.

- **First line is an imperative one-liner.** "Resolve the active git profile." Never "This function resolves..." or "A helper that...".
- **Do not restate the signature.** The reader can see the parameter names and the return type.
- **Do not document what the annotation gives.** `Args: timeout (int): the timeout as an int` is three words of nothing.
- **`Args` and `Returns` state constraints, units, and failure conditions.** "Seconds; must be positive." "None when the profile file is absent." That is what the annotation cannot carry.
- **`Raises` names the exception and the condition that produces it.**

## Inline comments

The rule is *when*, before it is *how*: a comment records a WHY the code cannot show. One line, inline, at the thing it explains.

Banned outright:

- **Narrating the next line.** `# increment the counter` above `counter += 1`.
- **Section-divider banners.** `# ---- helpers ----`. If the file needs signposting, it needs splitting.
- **Commented-out code.** Git has it.
- **`TODO` without an owner or issue reference.** An unattributed TODO is a wish.

A comment that survives answers "why is this here, and what breaks if I remove it".

## Verifying

Nothing checks this automatically. Re-read what you wrote against the shared method and the surface rules before you finish: that read is the check.
