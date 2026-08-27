# Lessons

A **lesson** is one self-contained HTML file that teaches one tightly-scoped thing tied to the
mission. It is the main thing you produce.

Lessons live at `$GARDEN/garden/private/teach/<topic>/lessons/0001-<dash-case-name>.html`,
numbered in the order they were taught. Scan the directory for the highest number and add one.

## Shape

Short. Completable in one sitting, well inside working memory, giving one tangible win they can
build on. A lesson that teaches three things is three lessons.

Teach the knowledge the skill needs and no more, then put them to work on it. The practice is
the point; the exposition is setup.

Every lesson carries:

- **Citations**, inline, linking the `RESOURCES.md` entry behind each claim. Dense citation is
  what makes a generated lesson trustworthy.
- **One recommended primary source** to read or watch: the single best thing you found.
- **Anchors out**: to sibling lessons, to the reference sheets, and to the permanent notes in
  the garden that the lesson draws on.
- **A line telling them to ask you followups.** You are their teacher and the lesson is one
  turn of the conversation.

## Typography

They will come back to these, so make them worth returning to. Think Tufte: generous measure,
one serif face, real hierarchy, wide margins carrying sidenotes. Set a print stylesheet so a
lesson prints cleanly on one or two pages.

## Components first

Lessons are assembled from reusable **components** in `assets/`: the stylesheet, quiz widgets,
simulators, diagram helpers, anything a second lesson could reuse.

Read `assets/` before authoring, and build from what is there. When a lesson needs something a
future lesson would want, write it into `assets/` and link it, so the library grows with the
workspace.

The shared stylesheet is the first component every workspace earns. Every lesson links it, which
is what makes the set read as one course rather than a pile of one-offs.

## Practice

Practice runs on a **feedback loop**, and the loop is tight: feedback lands immediately, and
automatically wherever the browser can judge the answer.

- **In-browser tasks and quizzes** for anything the page can check.
- **Real-world step sequences** for anything it cannot: a lift, a yoga sequence, a drill they run
  away from the screen and report back on.

Design for **retrieval**: ask them to produce the answer from memory before the page shows it.
A lesson that only re-presents material builds fluency strength and stops there.

**Quiz answers are uniform.** Every option in a question gets the same word count, and the same
character count where the wording allows. Formatting, length, and specificity all leak the
answer, so hold them constant across options.

## Reference sheets

The compressed essence of a lesson goes two places, because they serve different needs.

- A **permanent note** in the garden joins the graph and gets revisited by link. See
  [`promotion.md`](promotion.md).
- A **reference sheet** at `lessons/reference/<name>.html` is built for scanning and printing:
  syntax tables, algorithm walkthroughs, pose sequences, routines. It shares the lesson
  stylesheet.

Lessons are rarely revisited; reference sheets are. Write them for the glance, not the read.

## Open it

Finish by opening the file for them:

- macOS: `open <file>`
- WSL: `wslview <file>`
- Linux: `xdg-open <file>`
