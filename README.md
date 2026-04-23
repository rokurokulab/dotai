# dotai

[![CI](https://github.com/rokurokulab/dotai/actions/workflows/ci.yml/badge.svg)](https://github.com/rokurokulab/dotai/actions/workflows/ci.yml)
[![Smoke Test](https://github.com/rokurokulab/dotai/actions/workflows/smoke-test.yml/badge.svg)](https://github.com/rokurokulab/dotai/actions/workflows/smoke-test.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/rokurokulab/dotai)](https://github.com/rokurokulab/dotai/releases)

> **English** | [简体中文](docs/zh-CN/README.md)

A cross-tool **AI coding agent config registry & installer**. One repo to host the AGENTS.md, SKILL.md, plugins, hooks, and slash commands you want to share across [Claude Code](https://www.anthropic.com/claude-code), [OpenAI Codex CLI](https://developers.openai.com/codex/), and (later) other agentic CLIs — installed selectively into target repos via either the tool's native marketplace **or** a single `curl | sh` installer.

## Components

| Component      | Count                                                                                     |
| -------------- | ----------------------------------------------------------------------------------------- |
| Plugins        | 2 (`dotai-base`, `dotai-conventions`)                                                     |
| Skills         | 7 (`code-review`, `commit-message`, `changelog`, `github-pr`, `github-issue`, `github-milestone`, `repo-exploration`) |
| Sub-agents     | 1 (`implementer`)                                                                         |
| Hooks          | 2 (`guard-git` PreToolUse, `post-edit-lint` PostToolUse)                                  |
| Slash commands | 1 (`/pr-summary`)                                                                         |

## Install

### Claude Code marketplace

```sh
/plugin marketplace add https://github.com/rokurokulab/dotai
/plugin install dotai-base@dotai
/plugin install dotai-conventions@dotai
```

### `curl | sh` installer (any tool / project)

```sh
curl -sSL https://github.com/rokurokulab/dotai/releases/download/v0.1.0/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions
```

Full install matrix, bundle contents, and flag reference live at [`docs/installing.md`](docs/installing.md).

## Why this repo

| | Single tool | Cross-tool |
|---|---|---|
| Per-project, hand-maintained | `CLAUDE.md` / `AGENTS.md` in your repo | `AGENTS.md` (read by 6+ tools) |
| **Shared across projects** | Tool-native marketplaces (CC) | **dotai** ← *you are here* |

The convergence point is the [Agentic AI Foundation](https://agents.md/)'s `AGENTS.md` standard, plus the `SKILL.md` packaging convention. dotai is the distribution layer on top.

## What's in v0.1.0

- **`AGENTS.md`** — generic working agreement read by Codex, Cursor, Copilot, Windsurf, Amp, Devin, etc. natively.
- **`dotai-base` CC plugin** — three reusable skills (`code-review`, `commit-message`, `changelog`) plus the `implementer` sub-agent. No shell side effects.
- **`dotai-conventions` CC plugin** — a PostToolUse lint hook (best-effort, never blocks) and the `/pr-summary` slash command.
- **Codex `.codex/config.toml.example`** — annotated reference config.
- **3 bundles** for `install.sh`: `minimal` / `conventions` / `everything`.

See [`CHANGELOG.md`](CHANGELOG.md) for the full release notes and [`docs/installing.md`](docs/installing.md) for usage.

## License

Apache-2.0 — see [LICENSE](LICENSE).
