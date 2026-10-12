---
name: implement
description: "Implement a piece of work from a PRD, spec, issue, or set of tickets, and ship it: feature branch, commits, pushed PR, green CI, review over the PR, green CI again, PR link. Never merges."
disable-model-invocation: true
---

Implement the work described by the user in the PRD or issues, then ship it as a pull request with green CI. The work is done when every PR is open, reviewed, its checks are green (or the fix budget is spent), and the user has the links. Never merge: the user does that.

## 1. Branch

Run `git rev-parse --abbrev-ref HEAD`.

- On `main` or `master`: create a feature branch named `<type>/<slug>` from the issue or PRD, with `<type>` from the `commits` skill. Stay on main only when the user says so; then take the **main path** at step 4.
- On any other branch: work there.

## 2. Build

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

## 3. Commit

Load the `commits` skill and commit on the feature branch. Commit without asking; feature-branch commits are pre-authorised.

## 4. Push and open the PR

**Main path**: there is no PR to review, so review locally instead. Call the Skill tool with "review" against `origin/<default-branch>`, apply the findings you accept, and commit. Then stop and tell the user to push with `! git push`, listing any declined findings with a reason each. The push hook blocks agent pushes to main.

**Feature branch**:

1. `git push -u origin <branch>`
2. `gh pr create --base <default-branch>`. Call the Skill tool with "pr" to shape the body, and link the originating issue (`Closes #<n>` on GitHub).

When one invocation covers several issues, give each issue its own branch and PR, in dependency order, and run steps 5 to 7 on each.

## 5. Wait for CI

Run `gh pr checks <n> --repo <owner>/<repo> --watch` in the background and wait for it to exit. Name the repo explicitly; a worktree or fork can resolve the wrong one.

- **Green**: go to step 6.
- **No checks reported**: go to step 6, and say the repo has no CI on this PR.
- **Red**: read the failing job with `gh run view <run-id> --log-failed`, fix the cause, commit, push, and watch again. Fix the cause the log names; a skipped or loosened test is a failure, not a fix.

Stop after 3 red rounds on one PR and report what still fails and why. Do not review a red PR.

## 6. Review the PR

Once CI is green, call the Skill tool with "review" over the PR on the standards and spec axes: the fixed point is the merge-base with the PR's base branch, and the spec is the issue the PR closes.

Decide each finding:

- **Accept**: fix it, commit, and push.
- **Decline**: keep a one-line reason. "Out of scope", "the ADR decides otherwise", or "false positive: <why>" are reasons; "not needed" is not.

Post every declined finding, each with its reason, as **one** PR comment: `gh pr comment <n> --repo <owner>/<repo> --body-file -` with a heredoc. Skip the comment when nothing was declined.

## 7. Wait for CI again

If step 6 pushed anything, repeat step 5 until green, under the same 3-round budget.

## 8. Report

End with the PR URL for every PR, its CI state, the accepted and declined review findings, and any follow-ups CI surfaced.

The PR stays open for the user. Do not merge, enable auto-merge, or add it to a merge queue.
