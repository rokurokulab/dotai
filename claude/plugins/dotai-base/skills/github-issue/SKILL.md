---
name: github-issue
description: Draft concise, repository-aligned GitHub issues with proportional detail based on change size.
user-invocable: true
---

# GitHub Issue

Prepare a GitHub issue that is clear, actionable, and proportionate.

## Core behavior

- Follow repository-specific issue templates and contribution rules when they exist.
- Prefer the shortest structure that still makes the issue understandable and actionable.
- Do not pad small issues with empty sections.
- Do not invent evidence or repo conventions.
- If a likely duplicate exists, mention that before drafting a new issue.
- Inspect existing repository labels before creating an issue with `gh`.
- If clear matching labels already exist, apply them explicitly when creating the issue.

## First step

Inspect, when present:

- `.github/ISSUE_TEMPLATE/` — **use templates when they exist** (`--template` flag)
- existing repository labels (`gh label list`)
- recent similar issues
- the repository's own commit / issue conventions (e.g. `CONTRIBUTING.md`, `AGENTS.md`)

If the repository has issue templates, use the matching template. Common template → type mapping:

| Commit type | Template file | Title prefix |
|-------------|--------------|--------------|
| `feat` | `feature_request.yml` | `feat(scope): ...` |
| `fix` | `bug_report.yml` | `fix(scope): ...` |
| `refactor` | `maintenance_task.yml` | `refactor(scope): ...` |
| `chore` | `maintenance_task.yml` | `chore(scope): ...` |
| `docs` | (none — use generic) | `docs(scope): ...` |
| `ci` | (none — use generic) | `ci(scope): ...` |
| `test` | (none — use generic) | `test(scope): ...` |

If no repo-specific issue templates are found, fall back to the generic structures below.

## Size classification

Classify the issue into one of:

- **tiny**: typo, wording inconsistency, obvious low-scope cleanup
- **normal**: localized bug, small feature request, focused docs gap, small refactor
- **substantial**: cross-module bug, feature affecting multiple workflows, API/schema/config discussion, proposal with compatibility or migration implications

## Required writing rule

Prefer the minimum detail needed for a maintainer to answer:

- what is the issue?
- where is it?
- why does it matter?
- what should happen next?

## Templates

### tiny issue template

```markdown
## Summary

<1 short paragraph or 1-2 sentences>

## Suggested fix

<optional, 1 short sentence if obvious>
```

### normal issue template

```markdown
## Summary

<short paragraph>

## Current behavior

<what happens now>

## Expected behavior

<what should happen>

## Evidence

<logs / code refs, only if available>
```

### substantial issue template

```markdown
## Summary

<short paragraph>

## Background

<context and affected area>

## Current behavior

<what happens now>

## Expected behavior

<what should happen>

## Evidence

<logs / code refs / benchmark deltas>

## Scope / impact

<who is affected and how>

## Suggested direction

<optional and lightweight>
```

## Title convention

Issue titles use conventional commit format: `type(scope): description`.

- **Describe the problem or need**, not the solution.
  - GOOD: `fix(api): retry exhausts after 3 attempts with no model fallback`
  - BAD: `fix(api): add model fallback on consecutive overload errors` ← this describes the solution; use it for the PR title instead
- Scope follows the repository's commit conventions (typically the owning package / crate / module name).
- Do not include issue numbers, internal planning IDs (Block, Phase, Tier, EPIC, Batch, Wave), or file paths in the title.

## Output contract

When asked to draft an issue:

1. State the chosen size class: tiny / normal / substantial
2. Output: proposed title + issue body
3. If asked to create it with gh CLI, include labels and assignee per the repo's policy.

## Assignee and labels

- **kind/ label** (if the repo uses kind-prefixed labels): always apply the `kind/` label that matches the conventional commit type in the title:
  - `feat(...)` → `kind/feature`
  - `fix(...)` → `kind/bug`
  - `refactor(...)` → `kind/refactor`
  - `docs(...)` → `kind/docs`
  - `chore(...)` → `kind/chore`
  - `ci(...)` → `kind/cicd`
  - `test(...)` → `kind/test`
- **Agent-attribution label** (if the repo tracks which tool drove the work, e.g. `claude`, `codex`): apply the matching label on every issue the assistant creates.
- **Assignee**: pass `--assignee` per the repo's policy.
- Inspect available labels first (`gh label list`); reuse existing labels, do not invent new ones.
- If the repo installs `dotai-conventions` with `GUARD_GIT_REQUIRE_PR_METADATA=1`, the guard enforces `--label` and `--assignee` on `gh issue create`.
- If no clear label fits beyond these, say so instead of guessing.

## Style rules

- neutral, polite, concrete
- no emotional language, no blame, no fake certainty
- no unnecessary verbosity
- no tool-attribution footers in the body — use the attribution label instead
