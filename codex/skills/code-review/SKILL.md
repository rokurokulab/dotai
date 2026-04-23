---
name: code-review
description: Review a diff (staged, branch, or PR) for correctness, hidden state changes, missing tests, and convention drift. Use this when the user asks for a review, second opinion, or sanity check on changes they're about to commit or merge.
---

# code-review

A lightweight peer-review pass. Aims for the kind of comments a thoughtful colleague would leave — not exhaustive linting (the linter already does that) and not full-redesign feedback (out of scope).

## When to invoke

- User says "review this", "any issues with this change?", "second opinion before I merge"
- User asks you to look at `git diff`, a PR URL, or a specific file/range
- Don't auto-invoke on every Edit — too noisy

## What to do

1. **Read the change.** Get the diff from `git diff`, `git diff --cached`, `git diff <base>...HEAD`, or `gh pr diff <num>`. If a PR URL was given, also read the PR description for declared intent.
2. **Read 1–2 nearby files** to understand local convention (naming, error-handling style, log format).
3. **Pass the change through this checklist** (skip categories that don't apply):
   - **Correctness**: Does it do what the message claims? Edge cases? Off-by-one, nil/None, empty input, concurrent access.
   - **Hidden state changes**: Touches global state, env vars, file system, network outside its declared scope?
   - **Tests**: New behavior without a test? Removed behavior with a now-dead test?
   - **Backward compat**: Public API broken without a major bump or deprecation note?
   - **Convention drift**: Departs from `AGENTS.md` rules or local patterns without justification?
   - **Comment hygiene**: Comments explain *what* (redundant) instead of *why* (useful)?
   - **Naming**: Names readable a year from now? Abbreviations that won't be obvious?
   - **Errors**: Swallowed errors? Lost context in re-raise? Generic error type for actionable failure?

## Output format

Group findings into **Must fix** (correctness, security, broken tests) and **Consider** (style, naming, cleanups). Include file:line references. End with a one-sentence overall take ("Looks good apart from the two must-fix items" / "Suggest reworking the error handling, then re-review").

Don't pad with praise. If there's nothing significant to flag, say so in one line and stop.
