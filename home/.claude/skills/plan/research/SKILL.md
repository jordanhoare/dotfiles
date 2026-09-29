---
name: research
description: Investigate a question against high-trust primary sources and capture the findings on the ticket that asked it. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings as Markdown, citing each claim's source and ending on a recommendation that answers the question.
3. File the findings where the question lives:
   - **A ticket asked it:** post them as a comment on that ticket through the repo's issue tracker. The ticket is their only home. Split findings that exceed the tracker's comment limit across consecutive comments.
   - **No ticket:** save a single Markdown file where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.

Findings are point-in-time evidence. They reach the repo only through the ADR or doc that acts on them, which links back to the ticket.
