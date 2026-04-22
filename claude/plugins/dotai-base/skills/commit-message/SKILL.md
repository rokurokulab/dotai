---
name: commit-message
description: Generate a Conventional Commits message from staged or unstaged changes. Use when the user asks for a commit message, says "commit this", or wants help writing the subject/body for changes already in the working tree.
---

# commit-message

Produce a clean, [Conventional Commits](https://www.conventionalcommits.org/)-formatted message that matches the repo's house style.

## When to invoke

- User asks "write a commit message", "what should I commit this as?", "commit this for me"
- User stages changes and asks for help wording them
- Don't invoke for `git status` summaries — that's not a commit message request

## What to do

1. **Read the change**, in this priority order:
   - `git diff --cached` (staged) if non-empty → use this
   - `git diff` (unstaged) if no staged changes
   - Specific files the user named
2. **Skim the last 10 commits** with `git log --oneline -10` to learn the project's tone (scope conventions, voice, length).
3. **Pick a type**: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `perf`, `ci`, `build`, `revert`. When in doubt:
   - New behavior → `feat`
   - Restoring intended behavior → `fix`
   - No behavior change, code shape only → `refactor`
   - Test-only → `test`
   - CI/CD → `ci`
4. **Pick a scope** (optional) only if it adds clarity: `feat(api):`, `fix(auth):`. Don't manufacture scopes for cosmetic consistency.
5. **Write the subject**: ≤72 chars, imperative mood, no trailing period. "Add retry on 5xx" not "Added retry on 5xx".
6. **Write a body** (only if needed) explaining *why* the change is needed — not what (the diff shows that). Reference issue/PR numbers if available. Wrap at 72 cols.
7. **Mark breaking changes** with `BREAKING CHANGE:` footer or `!` after type: `feat(api)!: drop /v1 endpoint`.

## Output format

Print the message in a fenced block ready to paste:

```
feat(api): add retry on 5xx responses

Upstream service is occasionally flaky during deploys; retrying with
exponential backoff cuts our error rate by ~60% during deploy windows.
Capped at 3 attempts to avoid amplifying real outages.

Refs: #1234
```

If multiple distinct changes are mixed in the diff, **say so** and propose splitting them rather than producing one Frankenstein commit.
