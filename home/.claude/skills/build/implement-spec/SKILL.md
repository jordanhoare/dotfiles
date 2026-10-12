---
name: implement-spec
description: "Implement a whole PRD and its issues in one run: parallel implementer subagents onto one integration branch, shipped as one PR with green CI, reviewed over the PR. Never merges."
disable-model-invocation: true
---

You have been provided a PRD. It should have issues associated with it, produced by `/issue`, describing how to implement it.

The issue tracker should have been provided to you. If not, tell the user to run `/setup`.

The goal is the entire PRD implemented on a single **integration branch**, shipped as a pull request with green CI, reviewed, with every issue closed by that PR. Merging the integration branch to the default branch is the user's call: never merge it, enable auto-merge, or enqueue it.

The issues are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of issues which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the PRD, issues, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** should be run in the background where possible for maximum concurrency.

## Steps

1. Read the PRD and issues to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the issues: relevant codebase files or external documentation. Ensure the exploration subagent can save files: it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch from the default branch, named `<type>/<slug>` from the PRD, with `<type>` from the `commits` skill.

4. Use **implementer subagents** to implement each issue, each in its own worktree on its own branch. Each implementer subagent:
   - confirms its worktree is based on the integration branch before starting, and resets onto it if not;
   - calls the Skill tool with `tdd` to build the issue;
   - merges the integration branch tip into its own branch before reporting done.

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**.

6. If this changes the **frontier** of available issues, kick off more **implementer subagents** to work on the new issues. This allows for maximum concurrency.

7. Once all issues are complete, ship the integration branch through `/implement`'s steps 4 to 8, as one PR whose body is shaped by the `pr` skill and closes the PRD and every issue (`Closes #<n>` on GitHub):
   - wait for CI and fix failures;
   - once green, review the PR on the standards and spec axes, with the PRD as the spec. Apply the accepted findings in a single **implementer subagent** and push; post the declined findings, each with a reason, as one PR comment;
   - wait for CI to be green again;
   - report the PR link. Do not merge, enable auto-merge, or enqueue.

8. Clean up all **implementer subagent** worktrees.
