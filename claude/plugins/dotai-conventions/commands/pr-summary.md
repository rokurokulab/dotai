---
description: Draft a Conventional-Commits-style PR title and description from the current branch's diff against its base.
allowed-tools: ["Bash", "Read"]
---

# /pr-summary

You are drafting a PR for the current branch. The user will paste your output into the GitHub PR form.

## Step 1 — Establish the diff range

Determine the base branch:

```sh
# Try the conventional defaults; pick whichever exists.
git rev-parse --verify origin/main 2>/dev/null && base=origin/main
[ -z "${base:-}" ] && git rev-parse --verify origin/master 2>/dev/null && base=origin/master
[ -z "${base:-}" ] && base=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/@@')
```

If a base can't be determined, ask the user which branch this PR targets and stop.

## Step 2 — Read the change

Run, in order:

```sh
git log --oneline "$base"..HEAD
git diff --stat "$base"..HEAD
git diff "$base"..HEAD
```

If the full diff is large (>5000 lines), prefer per-file `git diff "$base"..HEAD -- <path>` and concentrate on the most substantive files (skip lock files, generated code, migrations).

## Step 3 — Draft the PR

Output **exactly** this format, in a fenced markdown block ready to paste:

```markdown
## Summary
<1–3 bullets explaining what changes and why>

## Test plan
- [ ] <how to verify locally>
- [ ] <CI checks expected to pass>
```

### Title rules

- **Conventional Commits prefix**: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `style:`, `perf:`, `ci:`, `build:`, `revert:`. Optional scope.
- ≤72 characters.
- Imperative mood: "Add retry on 5xx", not "Added retry".
- If the change is purely mechanical (rename, dependency bump, format), use `chore:` or `style:`. Don't dress up boring changes with `feat:`.

### Summary rules

- Lead with **why**, not what. The diff already shows what.
- 1–3 bullets is the target. If you need 5+, the PR is probably too large — surface this.
- Reference issue/PR numbers if you find them in commit messages.

### Test plan rules

- Concrete commands the reviewer can run, not vague "I tested it".
- If the change has no testable surface (docs, config), say so explicitly.

## Edge cases

- **No diff against base**: tell the user the branch matches the base; nothing to summarize.
- **Multiple unrelated changes mixed**: don't write one Frankenstein PR — flag the mix and propose splitting (one PR per logical change).
- **Generated code dominates the diff**: focus the summary on the source files; mention the regeneration in passing.

## Output

Print the title on its own line above the fenced block, like:

```
fix(api): retry 5xx responses with exponential backoff
```

```markdown
## Summary
- Upstream service is occasionally flaky during deploys; retry cuts our error rate by ~60%.
- Capped at 3 attempts to avoid amplifying real outages.

## Test plan
- [ ] `cargo test --package api -- retry`
- [ ] CI's integration suite (`api-integration`) passes
```
