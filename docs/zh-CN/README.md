# dotai

[![CI](https://github.com/rokurokulab/dotai/actions/workflows/ci.yml/badge.svg)](https://github.com/rokurokulab/dotai/actions/workflows/ci.yml)
[![Smoke Test](https://github.com/rokurokulab/dotai/actions/workflows/smoke-test.yml/badge.svg)](https://github.com/rokurokulab/dotai/actions/workflows/smoke-test.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../../LICENSE)
[![Release](https://img.shields.io/github/v/release/rokurokulab/dotai)](https://github.com/rokurokulab/dotai/releases)

> [English](../../README.md) | **简体中文**

跨工具的 **AI 编码 Agent 配置注册表与安装器**。一个仓库集中托管你想跨 [Claude Code](https://www.anthropic.com/claude-code)、[OpenAI Codex CLI](https://developers.openai.com/codex/) 以及（未来）其他 Agentic CLI 共享的 AGENTS.md、SKILL.md、插件、hooks 和 slash commands —— 通过工具自带的 marketplace **或** 一行 `curl | sh` 安装器，按需装入目标仓库。

## 两种使用方式

```sh
# 原生方式：Claude Code marketplace（无需安装器）
/plugin marketplace add rokurokulab/dotai
/plugin install dotai-base@dotai

# 通用方式：一键安装器（适用于任何工具/项目）
curl -sSL https://github.com/rokurokulab/dotai/releases/download/v0.1.0/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions
```

完整安装矩阵、bundle 内容与参数说明：[`installing.md`](installing.md)（中文） / [`docs/installing.md`](../installing.md)（English）。

## 为什么需要这个仓库

| | 单一工具 | 跨工具 |
|---|---|---|
| 单项目，手工维护 | 项目内的 `CLAUDE.md` / `AGENTS.md` | `AGENTS.md`（6+ 工具原生支持） |
| **跨项目共享** | 工具自带的 marketplace（如 CC） | **dotai** ← *你正在看的* |

收敛点是 [Agentic AI Foundation](https://agents.md/) 提出的 `AGENTS.md` 标准，加上 `SKILL.md` 打包约定。dotai 是建立在其上的分发层。

## v0.1.0 包含什么

- **`AGENTS.md`** —— 通用工作约定，被 Codex、Cursor、Copilot、Windsurf、Amp、Devin 等原生读取。
- **`dotai-base` CC 插件** —— 三个可复用 skill（`code-review`、`commit-message`、`changelog`），以及 `implementer` 子 agent。无任何 shell 副作用。
- **`dotai-conventions` CC 插件** —— 一个 PostToolUse lint hook（best-effort，不阻塞）和 `/pr-summary` slash command。
- **Codex `.codex/config.toml.example`** —— 带注释的参考配置。
- **3 个 bundle**（供 `install.sh` 使用）：`minimal` / `conventions` / `everything`。

完整发布说明见 [`CHANGELOG.md`](../../CHANGELOG.md)；使用方式见 [`installing.md`](installing.md)。

## License

Apache-2.0 —— 见 [LICENSE](../../LICENSE)。
