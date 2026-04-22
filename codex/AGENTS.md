# AGENTS.md

> Generic working agreement for AI coding agents operating on this repository.
> Read by [Codex CLI](https://developers.openai.com/codex/), [Cursor](https://cursor.com), [GitHub Copilot](https://github.com/features/copilot), [Windsurf](https://codeium.com/windsurf), [Amp](https://ampcode.com), [Devin](https://www.cognition.ai/devin), and most other agentic CLIs natively. Claude Code reads it via the dotai CC plugin (or in addition to its own `CLAUDE.md`).

## Project context

> **Replace this paragraph with 1–3 sentences describing what this project is, who it serves, and the dominant tech stack.** Example: _"A Go HTTP API gateway that fronts our payments service. Single binary, deployed to k8s, talks to PostgreSQL and Redis. Maintained by the platform team."_ Keep it short — agents will read it on every session.

## What good looks like here

- **Reproduce before you fix.** If a test or build is broken, reproduce locally first; don't propose changes from logs alone.
- **One concern per change.** Refactors, behavior changes, and dependency bumps each go in their own commit.
- **Match existing style.** Read 2–3 nearby files before adding code; prefer the local convention over textbook "best practice."
- **Edit existing files; don't create parallel ones.** Don't introduce `*_v2.go` / `Component2.tsx`. Update in place.

## Commit hygiene

- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `style:`, `perf:`, `ci:`, `build:`, `revert:`. Optional scope: `feat(api):`, `fix(auth):`.
- **Keep diffs small.** Aim for ≤200 lines per commit; if a change is genuinely larger, split it. (LICENSE files, generated code, and full-file rewrites are reasonable exceptions — call them out in the message.)
- **Subject ≤72 chars, imperative mood.** "Add X", not "Added X" or "Adding X".
- **Body explains _why_, not _what_** — the diff already shows what.

## Tooling

- **Don't bypass safety checks.** No `--no-verify`, no `--force-with-lease` on shared branches, no `git push --force` to default branches without explicit human approval.
- **Don't auto-merge other people's PRs** unless asked. Reviewing humans get to merge.
- **Run the local test/lint suite before declaring "done."** If the project has `make test`, `cargo test`, `pnpm test`, `task test` — run it. CI is a cross-check, not the first check.

## Asking for help

- **When uncertain, ask.** If a task is ambiguous, the file structure is unclear, or you can't reproduce a bug, surface it before guessing. Cheap question > expensive wrong patch.
- **Surface assumptions.** If you have to make one to move forward, say so explicitly in the PR description: _"I assumed X because Y; flag if wrong."_

## Forbidden

- **Do not commit secrets.** No API keys, tokens, passwords, `.env`, private keys, or anything matching `*.pem`. If you find one already committed, surface it immediately — don't just delete it (the git history still has it).
- **Do not run destructive commands without confirmation.** `rm -rf`, `git reset --hard`, `DROP TABLE`, force pushes to default branches. Surface the intent first.
- **Do not exfiltrate code or data outside the repo.** Don't post snippets to external services (paste bins, third-party AI tools) unless explicitly directed.

---

_This file came from [dotai](https://github.com/rokurokulab/dotai). Edit freely — once installed, it's yours._
