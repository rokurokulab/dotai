---
name: github-pr
description: Draft concise, repository-aligned GitHub pull requests with proportional detail and correct issue linking.
user-invocable: true
---

# GitHub Pull Request

Prepare a GitHub pull request that is easy to review and proportionate to the change size.

## First step

Inspect, when present:

- `.github/PULL_REQUEST_TEMPLATE*`
- existing repository labels (`gh label list`)
- recent merged PRs for style
- the repository's own commit / PR conventions (e.g. `CONTRIBUTING.md`, `AGENTS.md`, any repo-specific rules file)

## Size classification

- **tiny**: typo, comment fix, trivial cleanup
- **normal**: localized bug fix, small feature, focused refactor
- **substantial**: cross-module change, API/schema change, compatibility impact

## Title convention

PR titles use conventional commit format: `type(scope): description`.

- **Describe what was done** (the action/solution), not the problem.
  - GOOD: `feat(api): add /doctor diagnostics endpoint`
  - BAD: `feat(api): missing diagnostics endpoint` ← this describes the problem; use it for the issue title instead
- The PR title will appear in git history as the merge commit summary.
- Scope follows the repository's commit conventions — typically the owning package / crate / module name.
- Do not include issue numbers in the title (link issues in the body with `Closes #N`).
- Do not include internal planning IDs (Block, Phase, Tier, EPIC, Batch, Wave) or file paths.

## Required writing rule

Prefer the minimum detail needed for a reviewer to answer:

- what changed?
- why?
- how was it checked?
- what issue does it link to?
- what risk remains?

## Linking, assignee, and labels

- Use GitHub closing syntax when a related issue exists (`Closes #N`).
  **Multiple issues**: each must have its own keyword — `Closes #1, Closes #2, Closes #3`. GitHub only parses the keyword immediately before a `#N` reference; `Closes #1 #2 #3` only links `#1`.
- **kind/ label** (if the repo uses kind-prefixed labels) must match the conventional commit type in the PR title:
  - `feat(...)` → `kind/feature`
  - `fix(...)` → `kind/bug`
  - `refactor(...)` → `kind/refactor`
  - `docs(...)` → `kind/docs`
  - `chore(...)` → `kind/chore`
  - `ci(...)` → `kind/cicd`
  - `test(...)` → `kind/test`
- **Agent-attribution label** (if the repo tracks which tool drove the work, e.g. `claude`, `codex`): apply the matching label on every PR the assistant creates.
- **Assignee**: pass `--assignee` per the repo's policy (often the human who owns the work).
- Inspect available labels first (`gh label list`); reuse existing labels, do not invent new ones.
- If the repo installs `dotai-conventions` with `GUARD_GIT_REQUIRE_PR_METADATA=1`, the guard enforces `--label` and `--assignee` on `gh pr create`.

## Body structure

Use the repository PR template (`.github/pull_request_template.md`) when it exists. Fill its sections:

### tiny PR body

```markdown
## Summary

<1 sentence>

## Related Issue

Closes #N

## Changes

- <1 bullet>

## Validation

- [x] Focused check or test only

Validation details: <which command was run>.
```

### normal PR body

```markdown
## Summary

<short paragraph>

## Related Issue

Closes #N

## Changes

- <bulleted list>

## Validation

- [x] Formatter
- [x] Linter
- [x] Focused check or test only

Validation details: <which commands were run and their results>

## Risk / Impact

- <known risks or "None">
```

### substantial PR body

```markdown
## Summary

<short paragraph>

## Related Issue

Closes #N, Closes #M

## Changes

- <bulleted list by area>

## Validation

- [x] Formatter
- [x] Linter
- [x] Tests for the changed package(s)

Validation details: <which commands, results, anything skipped and why>

## Suggested Merge Commit Title

`type(scope): summary`

## Risk / Impact

- <known risks, follow-up items>

## Breaking Changes

- [ ] None
- [ ] Yes, described below

Details: ...
```

## CI checks

Local validation (formatter, linter, focused tests) is the primary quality gate. Watch CI only if the user explicitly asks or if the repo's conventions require it.

## Non-goals

- Do not invent validation results
- Do not bundle unrelated changes unless explicitly requested
- Do not add tool-attribution footers (e.g. "Generated with Claude Code") to the PR body — use the attribution label instead
