# Resources

`RESOURCES.md` is the private working index of trusted sources for a topic. Lessons draw their
claims from here and cite them inline. Communities listed here are where wisdom comes from.

Never trust your parametric knowledge. Populate this file before teaching much, because an
empty `RESOURCES.md` means the next lesson gets built from your own recall, which is the one
source that can offer no citation and no way for the user to check you.

## Material they supply

A problem sheet, lecture slides, a spec, a repo, a rubric, a problem statement. Where it exists,
it outranks everything found online **for scope**: it defines the boundary of what is in play and
what is not, and teaching outside that boundary is teaching the wrong course.

Read it before the first lesson and record it under `## Supplied` with what it bounds. Ask for it
once, at the start of a topic, and drop the subject if there is none - self-directed topics are
the common case and have no syllabus to find.

## Format

```md
# {Topic} Resources

## Supplied

- `~/uni/discrete-maths/problem-set-3.pdf`
  Assessed exercises, weeks 5-6. Bounds the topic: relations and closures, no graph theory.

## Knowledge

- [Book: _The Science and Practice of Strength Training_ by Zatsiorsky & Kraemer](https://example.com)
  Foundational text on programming and adaptation. Use for: periodisation, recovery, intensity zones.
- [Article: "How Much Should I Train?" by Greg Nuckols (Stronger By Science)](https://example.com)
  Evidence-based review of volume landmarks. Use for: weekly set targets per muscle group.

## Wisdom (Communities)

- [r/weightroom](https://reddit.com/r/weightroom)
  High-signal subreddit, moderated against bro-science. Use for: programme critique, plateaus.
- Local: Tuesday strength class at {gym name}
  Use for: real-time coaching feedback on lifts.

## Gaps

- No good source found on {area the mission needs}. Drives the next search.
```

## Rules

- **Supplied material wins on scope.** Where a source and the problem sheet disagree about what
  matters, the problem sheet is right about what matters and the source is right about the facts.
- **High trust only.** Primary sources, recognised experts, peer-reviewed work, communities with
  real moderation. Marketing dressed as education stays out.
- **Annotate every entry.** One line: what it covers and when to reach for it. A bare link is
  useless in three months.
- **Name the gaps.** An area the mission needs and no source covers is a `## Gaps` entry, which
  is what drives the next round of searching.
- **Prune ruthlessly.** Five sharp sources beat thirty mediocre ones. A source that turned out
  wrong, shallow, or off-mission gets deleted, not buried.
- **Record community preferences.** If they have opted out of communities, write it here so
  later sessions stop proposing them.

## Promoting a source

Working through a source properly earns it a literature note in `03 - Resources/<Topic>/` in the
garden. `RESOURCES.md` keeps the one-line annotation; the literature note carries the actual
reading, in the vault's house style described in [`promotion.md`](promotion.md).

A literature note is what the source said, in their words, with the passage quoted. A permanent
note is what they now think. Keep them separate files.
