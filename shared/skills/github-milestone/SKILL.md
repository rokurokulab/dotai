---
name: github-milestone
description: Create and maintain GitHub milestones that group related issues and PRs under a single deliverable, following open-source conventions.
user-invocable: true
---

# GitHub Milestone

Milestones exist to answer one question: "is this body of work done yet?" They aggregate the issues / PRs that belong to a single coordinated deliverable so the remaining gap is visible at a glance.

## When to create one

- The work spans **multiple issues or multiple PRs** and has a common completion criterion.
- An external stakeholder (reviewer, downstream consumer) will ask "is initiative X done".
- Single-issue / single-PR work does **not** need a milestone — labels and linked issues are enough.

## Title

- Describe the **outcome**, not the release, sprint number, or planning phase.
- No version numbers (`v1.0`, `v0.0.13`) — versions belong to release tags, not milestones. A milestone outlives a single release if work spans tags; a version number ossifies it.
- No internal planning tokens (`phase-1`, `M1`, `tier-A`, `epic-3`) — the public surface stays self-describing.
- Short noun phrase, title case or sentence case matching the repo's existing milestone style.
- Good: `Token Economy`, `Cache Correctness`, `Plugin Sandbox Hardening`.
- Bad: `v0.0.13 cache work`, `Phase B`, `Milestone 2`, `Q2 goals`.

## Description

One paragraph covering:

1. **What is included** — the scope in plain language.
2. **Completion criterion** — what must be true for the milestone to close (usually "every attached issue closed").
3. Optional: a one-sentence pointer to the high-level driver (the problem, not internal plan files). Do not quote or name project-private / gitignored planning paths.

Keep it short — the issue list carries the detail. If the description is growing past ~5 lines, the work probably needs splitting, not a longer milestone blurb.

### Partial-scope milestones

If the milestone will span multiple delivery waves and issues are filed per wave rather than up-front, **say so explicitly in the description**. Otherwise the attached-issue count is read as the full scope, and the milestone will appear "complete" as soon as the first wave merges. A single sentence is enough: e.g. "Issues are filed per delivery wave, so the attached-issue count reflects only the work currently in flight."

## Due date

Optional. Omit unless there is a real external deadline. A speculative "we'd like this in 6 weeks" due date becomes noise as soon as it slips; the list of remaining issues is a better status signal than a stale date.

## Attachment

- Attach every existing issue that is in scope immediately after creating the milestone.
- Attach PRs when they are opened — GitHub propagates closure to the milestone on merge.
- Do **not** attach follow-up issues that are merely "related" — only ones whose resolution the milestone depends on.

## Labels and milestones are orthogonal

- Labels classify (`kind/feature`, `area/runtime`) — they answer "what kind of change is this".
- Milestones aggregate (`Token Economy`) — they answer "which deliverable does this belong to".
- An issue normally has several labels but at most one milestone.

## Lifecycle

- State starts `open`. Close only when every attached issue is closed.
- Do not reopen a closed milestone to tack on new work. Create a follow-up milestone and link it in the description if continuity matters.
- If scope changes materially mid-flight, update the description in place; do not rename the milestone (external links break).

## Hygiene

- External-surface hygiene: no project-private paths, no task / phase / tier tokens, no tool-attribution footers in title or description.
- Prefer creating via `gh api repos/OWNER/REPO/milestones` so the title and description can be passed programmatically and reviewed before opening.
