---
name: changelog
description: Add a CHANGELOG.md entry in Keep-a-Changelog style for unreleased work, or generate the next version's entries from git log since the last tag. Use when preparing a release, updating CHANGELOG after merging features, or when the user asks "what's in the next release?"
---

# changelog

Keep `CHANGELOG.md` honest and human-readable, in [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format with [SemVer](https://semver.org/) versioning.

## When to invoke

- User says "update the changelog", "add to CHANGELOG", "generate release notes"
- User is preparing a release (tagging, version bump)
- After merging a feature/fix, if the project keeps CHANGELOG in lockstep with merges (check the recent commit pattern to confirm)

## What to do

1. **Read existing `CHANGELOG.md`** to learn the project's category vocabulary, ordering, and link style. Match it.
2. **Determine scope of update**:
   - "Add to unreleased": the user just merged something; append to the `[Unreleased]` section.
   - "Cut a release": user is bumping version; rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`, add a fresh empty `[Unreleased]`, update version-comparison links at the bottom.
3. **Categorize entries** under the standard headings (skip empty ones):
   - **Added** — new features
   - **Changed** — non-breaking changes to existing behavior
   - **Deprecated** — soon-to-be-removed features
   - **Removed** — features removed in this release
   - **Fixed** — bug fixes
   - **Security** — vulnerability fixes
4. **Source the entries** from `git log <last-tag>..HEAD --oneline` (Conventional Commits map cleanly: `feat:` → Added, `fix:` → Fixed, `refactor:` / `perf:` → Changed, etc.). Skip noise (`chore:`, `ci:`, `docs:` unless user-facing).
5. **Phrase entries from the user's perspective**, not the developer's. "Added retry on flaky upstream calls" — not "Implemented exponential backoff in HTTPClient.do_request".
6. **One bullet per change**, reference PR/issue if available: `- Added retry on 5xx upstream errors. (#123)`.

## Output format

Print the diff to apply (or the new section, if appending). Don't reformat unrelated parts of the file.

If you're cutting a release, include the version-link footer update:

```markdown
[Unreleased]: https://github.com/owner/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/owner/repo/compare/v1.1.0...v1.2.0
```

If the user has [git-cliff](https://git-cliff.org) configured, mention that running `git-cliff` may be the better path and just generate the section it would produce as a preview.
