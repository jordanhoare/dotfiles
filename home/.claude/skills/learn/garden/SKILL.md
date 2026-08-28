---
name: garden
description: Replay what you understood from this session, cold, before the answer is available. Then keep anything worth keeping.
disable-model-invocation: true
argument-hint: "Anything worth keeping?"
---

# Garden

The material is the work that just happened. It happened for some other reason, and the lesson
in it is latent, so your job is to make the user reach for it before you hand it over.

You hold the session. They do not: it went past faster than it could land, and that is the whole
problem this solves. Which means for the next few turns you are the only one with the answer key,
and reading it aloud spends the session.

`$ARGUMENTS` is what they already know they want kept, when they gave it. Run the replay anyway.

## The vault

The vault is `$GARDEN/garden`, and fleeting notes live in `$GARDEN/garden/05 - Fleeting/`.
Resolve `$GARDEN` before anything else; if it is unset, say so and stop. Three abandoned clones
of this vault exist on this machine, so the variable is the only safe way in.

## What garden writes

`05 - Fleeting/`. Nothing else, ever.

Not a permanent note, not a learning log entry, not a map of content, not a `**Review:**` date.
Garden schedules no revision and runs no spaced repetition. A gap this session finds becomes a
sentence in a fleeting note or it evaporates, and evaporating is a fine outcome.

The pull to log a good recall session is strong and you should expect to feel it. `/teach` owns
that half of the vault and reaches it on its own.

## Step 1: pick

Name one or two things from the session worth holding. Not an inventory of what happened: the
one or two ideas that would still be useful in a month.

Say what they are and say nothing about them. "The retry logic, and why the first fix failed" is
the whole of it.

**Done when:** they know which two things they are about to be asked for, and have been told
nothing about either.

## Step 2: rate, then replay

For each, ask for a **confidence** rating - high, medium, low - and take it *before* the attempt.
Then ask them to explain it back.

Hold the reconstruction. Every sentence you write here is a sentence they no longer have to
retrieve, and retrieval is the point. If they stall, ask a question that narrows the search
rather than one that answers it.

**Done when:** every picked thing has a rating and an attempt, and you have written no part of
the answer.

## Step 3: reveal and judge

Now reconstruct, in order:

- what was tried, and what it did
- the commands whose output settled something, quoted exactly
- sources read, down to the line or field that mattered
- which assumptions met a contradiction, and which one gave way
- what is still open

Then name the gap between what they rated and what they produced.

| What you saw | What it means |
|---|---|
| High confidence, wrong | The finding. Say so plainly. A confident wrong model predicts where they will stumble on everything adjacent |
| Low confidence, right | They hold it and do not trust it. Tell them |
| Confidence tracked accuracy | Their self-assessment is calibrated. Trust their own read on what mattered |

Judge, and stop there. Teaching the gap is `/teach`, next session, on their initiative.

**Done when:** they can see the session again, and know which parts of their account were wrong.

### Reading a session you no longer hold

Reconstruct from context first. Where context runs into a compaction boundary, or a stretch you
cannot recover, read that span of the transcript and only that span.

Filter it: user turns and assistant text. Tool results are most of a transcript's bytes and
almost none of its meaning, so dropping them is what makes reading it affordable.

```sh
jq -r 'select(.isSidechain | not)
  | select(.type == "user" or .type == "assistant")
  | select(.toolUseResult == null)
  | (.message.content // "")
  | (if type == "array" then (map(select(.type == "text") | .text // "") | join(" ")) else . end)
  | select(length > 0)' "$transcript"
```

## Step 4: keep, or do not

One open question, then let them write.

Most sessions end with nothing to keep, and that is the ordinary result. Say so in one line and
stop.

| They say | You do |
|---|---|
| nothing | One line, and stop. This is the common ending |
| a thought | Take dictation, following [`dictation.md`](dictation.md) |
| a question they cannot answer | Write it down as their question, unanswered |
| teach me this | Tell them `/teach` starts a topic properly, and stop |

Where their account looks thin, ask the question their reasoning has not answered, or point at
the reference that disagrees and let them reconcile it. Two questions at most: this is the end of
a session and they are tired.

The garden repo is theirs to sync with `mise run sync`.
