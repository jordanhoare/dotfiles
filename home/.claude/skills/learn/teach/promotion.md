# Promotion

Promotion is how learning leaves the private lane and enters the garden. It produces two
artefacts, and they do different jobs:

- A **permanent note** in `04 - Permanent/<Topic>/` is the knowledge: one atomic concept, in the
  user's own words, linked into the graph. It says what they now think.
- The **learning log** in `02 - Areas/<Topic>/Learning Log.md` is the ledger: dated entries
  recording what they demonstrated, how, and what it unlocks. It says how they came to think it.

Upstream teaching frameworks fold both into one "learning record". Splitting them keeps the
permanent note about the concept rather than about the learner, and matches how this vault
already works: Areas are containers for related permanent notes *and status updates*.

Read both at the start of a session. Together they are the zone of proximal development.

## The gate

Promote when any of these is true:

1. **They used the concept correctly**, unprompted, in a way that shows they hold it rather than
   recognise it.
2. **They disclosed real prior depth**, not just familiarity. Record the depth they claimed.
3. **A misconception was corrected.** These are the highest value, because a wrong model predicts
   where they will stumble on adjacent topics.

Everything else stays in `NOTES.md` in the private lane: material covered but not yet evidenced,
prior knowledge claimed without demonstration, teaching preferences. Coverage is not learning.

Mission shifts edit `MISSION.md` and get a log entry. They do not earn a permanent note.

## Permanent note format

`04 - Permanent`, `03 - Resources` and `00 - Maps of Content` carry no YAML frontmatter (1 of 20,
0 of 8, and 0 of 3 notes respectively). Match that. `04 - Permanent/Age of Enlightenment.md` is
the reference.

```md
{One paragraph defining the concept, in prose, in their words. What it IS, not how to do it.}

{One or two more paragraphs on why it matters and where it connects. Optional.}

> [!quote] [{Source title}]({url})
> {The passage that grounds the claim.}

### Related Notes

- [[04 - Permanent/{Topic}/{Sibling concept}]]
- [[03 - Resources/{Topic}/{The source it came from}]]
```

- **Wikilinks carry the full vault path**, as the existing notes do.
- **Inline `#tags`** where the vault already uses one for the area.
- **One concept per file.** If the note needs "and", it is two notes.
- **Filename is the concept**, in the vault's title case: `04 - Permanent/Rust/Ownership.md`.

## Glossary discipline

The set of permanent notes for a topic *is* its glossary, so the same rules apply.

- **Be opinionated.** Where the field has several words for one concept, pick one, and list the
  rest in the note as aliases the vault avoids.
- **Keep definitions tight.** One or two sentences before the elaboration starts.
- **Use the vault's own terms inside definitions.** Once a concept has a note, every later note
  and every later lesson uses that word and links that note. This is what makes hard terms
  reachable later.
- **Resolve ambiguity explicitly.** When the wider field uses a term loosely, state the
  resolution in the note: "here, a *set* always means a working set."

## Learning log format

Dated notes in this vault carry Quartz frontmatter, so the log does too. Newest entry at the top.

```md
---
title: {Topic} Learning Log
draft: true
tags:
  - {topic-tag}
---

## 2026-08-27 - {What was established}

{One to three sentences: what they now understand, or what prior knowledge was established.}

**Evidence:** {How they demonstrated it. A question answered cold, an exercise completed, a
misconception they talked themselves out of, prior experience cited.}

**Implications:** {What this unlocks or rules out for the next lesson. Write it only when
non-obvious.}

**Note:** [[04 - Permanent/{Topic}/{Concept}]]
```

- **Evidence is required.** It is the thing that distinguishes the log from a session diary, and
  the thing a later session needs when deciding whether to re-teach.
- **Implications are optional.** Write one when the consequence for the next lesson is not
  obvious from the entry itself.
- **`draft: true` while the topic is in flight**, so the log stays off the public site until they
  decide otherwise. Flip it when they want it published.
- **The log is not a diary.** One entry per promotion, not one per session. A session that
  produced no evidence produces no entry.

## Supersession

A definition written in week one is often wrong by week six. Three layers hold the history, and
each is doing a job the others cannot:

1. **The permanent note is edited in place.** Zettelkasten notes evolve, so the graph holds one
   current note per concept rather than a stack of superseded files.
2. **When the change is a correction rather than a refinement, the note names what it replaced.**
   One line, at the end: "Earlier framing, now wrong: {X}. It breaks because {Y}." A corrected
   misconception is the highest-value thing in the graph and it must survive the edit.
3. **The learning log records the correction as its own dated entry**, with the evidence. The
   note holds the current truth; the log holds the arc.

The full audit trail is git. `git -C "$GARDEN" log -p -- "garden/04 - Permanent/{Topic}"` shows
every version of every note in the topic. Reach for it when the arc matters and the log is thin.

## Index it

Every new permanent note adds a row to `00 - Maps of Content/<Topic>.md`, which is a markdown
table: the wikilink in column one, one line on what the concept is for in column two. Follow
`00 - Maps of Content/Data Structures & Algorithms.md`, which groups rows under `##` subheadings
once a topic has enough of them.

Create the MOC on the first promoted note. An unindexed note is one they will not find again.
