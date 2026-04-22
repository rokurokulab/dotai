# Contributing to dotai

> [!IMPORTANT]
> **This file is for contributors to dotai.** It is not the template that gets distributed to consumers — that lives at `shared/AGENTS.md` and is rendered into every supported ecosystem under `claude/`, `codex/`, etc.

## What dotai is

A **registry + installer** for cross-tool AI coding agent configs. Users install *from* dotai into their own repos, via either:

1. **Claude Code's native marketplace** (`/plugin marketplace add rokurokulab/dotai claude`) — for plugins, skills, agents, hooks, and slash commands that live under `claude/`.
2. **Generic curl installer** (`scripts/install.sh`) — for everything else, including AGENTS.md, Codex configs, and (later) Cursor rules.

dotai is **not** a GitHub template repo. Don't fork it; install from it.

## Layout (target end-state)

```
shared/             ← single source of truth (AGENTS.md + SKILL.md masters)
claude/             ← rendered output + CC marketplace + plugins
codex/              ← rendered output + Codex example configs
bundles/            ← TOML manifests describing curated combos
scripts/            ← install.sh (user-facing) and render.sh (maintainer-only)
docs/               ← user docs (installing.md, etc.)
.github/workflows/  ← CI, smoke tests, release pipeline
```

Currently bootstrapping — most directories will arrive in PRs #2–#6.

## Local development

```sh
task              # list available tasks
task lint         # static checks (license headers, JSON/YAML/shell)
```

Future tasks (`render`, `test-install`) are wired up as their backing scripts land.

## Conventions

- **Commits**: [Conventional Commits](https://www.conventionalcommits.org). Drives changelog grouping.
- **No giant commits**: keep diffs ≤200 lines where reasonable. Two pre-approved exceptions: the LICENSE itself (~200 lines, single bootstrap commit) and `scripts/install.sh` (~400 lines, a single coherent installer is better than artificially split halves).
- **License headers**: Apache-2.0 header on our **executable code only** (`scripts/`). User-facing content (`shared/`, `claude/`, `codex/`, `bundles/`, `docs/`) is intentionally header-free — it gets installed verbatim into other people's projects, where our header would be noise.
- **Smoke-test scripts locally before committing.** Run `bash scripts/install.sh --dry-run …` against `/tmp/dotai-test-$$`, verify, **clean up the temp dir**. Temporary `set -x` / debug echoes are fine while iterating but **must be stripped before commit**.
- **Render products are committed**, with `.gitattributes linguist-generated=true` folding rendered diffs in PR review. CI's `render-check` blocks merges that forget to run `task render`.

## What goes in `shared/` vs ecosystem dirs

- **`shared/AGENTS.md`** — generic, tool-agnostic instructions every consumer will receive.
- **`shared/skills/<name>/SKILL.md`** — generic skill the model can invoke; gets copied verbatim into every ecosystem that supports `SKILL.md` natively (CC, Codex Tier 1).
- **`claude/plugins/<name>/`** — CC-specific bundling (plugin manifest + skills + agents + hooks + slash commands together). Skills inside a plugin are populated by `render.sh` from `shared/skills/`.
- **`codex/`** — Codex-specific files (rendered `AGENTS.md`, example `.codex/config.toml`).

## Out-of-scope (for v0.1.0)

Cursor `.mdc`, custom agents beyond `implementer`, prompts library, real-AI smoke test in CI, auto-generated bundle docs in README.
