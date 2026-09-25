---
name: implement
description: "Implement a piece of work from a PRD, spec, issue, or set of tickets, and ship it: feature branch, commits, pushed PR, green CI, PR link."
disable-model-invocation: true
---

Implement the work described by the user in the PRD or issues, then ship it as a pull request with green CI. The work is done when every PR is open, its checks are green (or the fix budget is spent), and the user has the links.

## 1. Branch

Run `git rev-parse --abbrev-ref HEAD`.

- On `main` or `master`: create a feature branch named `<type>/<slug>` from the issue or PRD, with `<type>` from the `commits` skill. Stay on main only when the user says so; then take the **main path** at step 5.
- On any other branch: work there.

## 2. Build

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

## 3. Review

Use /review against the merge-base with the default branch, and fix what it finds.

## 4. Commit

Load the `commits` skill and commit on the feature branch. Commit without asking; feature-branch commits are pre-authorised.

## 5. Push and open the PR

**Main path**: the commits sit on main. Stop here and tell the user to push with `! git push`. The push hook blocks agent pushes to main.

**Feature branch**:

1. `git push -u origin <branch>`
2. `gh pr create --base <default-branch>` with a body that states what changed and links the originating issue (`Closes #<n>` on GitHub).

When one invocation covers several issues, give each issue its own branch and PR, in dependency order.

## 6. Watch CI

Run `gh pr checks <n> --watch` in the background and wait for it to exit.

- **Green**: done.
- **No checks reported**: done; say the repo has no CI on this PR.
- **Red**: read the failing job with `gh run view <run-id> --log-failed`, fix the cause, commit, push, and watch again. Fix the cause the log names; a skipped or loosened test is a failure, not a fix.

Stop after 3 red rounds on one PR and report what still fails and why.

## 7. Report

End with the PR URL for every PR, its CI state, and any follow-ups the review or CI surfaced.
