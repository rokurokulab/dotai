# dotai

> [!WARNING]
> **Work in progress.** Pre-`v0.1.0`. Nothing is published yet — APIs and layout will move.

A cross-tool **AI coding agent config registry & installer**. One repo to host the AGENTS.md, SKILL.md, plugins, hooks, and slash commands you want to share across [Claude Code](https://www.anthropic.com/claude-code), [OpenAI Codex CLI](https://developers.openai.com/codex/), and (later) other agentic CLIs — installed selectively into target repos via either the tool's native marketplace **or** a single `curl | sh` installer.

## Two ways in

```sh
# Native: Claude Code marketplace (no installer dependency)
/plugin marketplace add rokurokulab/dotai claude
/plugin install dotai-base@dotai

# Generic: one-shot installer (works for any tool / project)
curl -sSL https://github.com/rokurokulab/dotai/releases/download/v0.1.0/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions
```

Full install matrix and bundle contents will live at [`docs/installing.md`](docs/installing.md) once `v0.1.0` ships.

## Why this repo

| | Single tool | Cross-tool |
|---|---|---|
| Per-project, hand-maintained | `CLAUDE.md` / `AGENTS.md` in your repo | `AGENTS.md` (read by 6+ tools) |
| **Shared across projects** | Tool-native marketplaces (CC) | **dotai** ← *you are here* |

The convergence point is the [Agentic AI Foundation](https://agents.md/)'s `AGENTS.md` standard, plus the `SKILL.md` packaging convention. dotai is the distribution layer on top.

## Status

Bootstrap. See [Plan](https://github.com/rokurokulab/dotai/issues) and [Changelog](CHANGELOG.md).

## License

Apache-2.0 — see [LICENSE](LICENSE).
