# 安装 dotai

> [English](../installing.md) | **简体中文**

两种消费 dotai 内容的方式。它们使用同一份源仓库，可任意组合。

## 方式 A —— Claude Code 原生 marketplace

如果你只需要 CC 插件（skills / sub-agent / hooks / commands），用 Claude Code 内建的 marketplace 即可，无需安装、无需 curl。

```text
/plugin marketplace add rokurokulab/dotai
/plugin install dotai-base@dotai             # 安全内容：skills + implementer agent
/plugin install dotai-conventions@dotai      # 增加 post-edit-lint hook 和 /pr-summary
```

CC 会把 dotai clone 到 `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`，并在当前 session 加载。更新由 `/plugin update` 管理。

此路径**仅限 CC** —— 不会落地 `AGENTS.md`、Codex 示例配置以及 CC 插件体系外的任何内容。

## 方式 B —— 通用 `curl | sh` 安装器

其他场景（AGENTS.md、Codex 配置、多工具安装、细粒度选择），使用 `install.sh`：

```sh
# 锁定到具体 release —— 推荐
curl -sSL https://github.com/rokurokulab/dotai/releases/download/v0.1.0/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions

# 永远 latest（可复现性较弱，但自动跟踪 release）
curl -sSL https://github.com/rokurokulab/dotai/releases/latest/download/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions
```

安装器需要 `curl`、`jq`、`tar`（macOS / Ubuntu / Alpine 默认带）。

### Bundles

| Bundle | 落地内容 |
|---|---|
| `minimal` | 仅 `AGENTS.md`。 |
| `conventions` | `AGENTS.md` + 3 个独立 skill（`code-review`、`commit-message`、`changelog`）+ `dotai-base` CC 插件（skills + `implementer` 子 agent）+ Codex `.codex/config.toml` 示例。**不含 hooks。** |
| `everything` | 上述全部内容 + `dotai-conventions` CC 插件（增加 Edit/Write 的 `PostToolUse` lint hook 和 `/pr-summary` slash command）。 |

### 参数

| 参数 | 含义 |
|---|---|
| `--tools <list>` | 逗号分隔：`claude`、`codex` 或 `all`。必填。 |
| `--bundle <name>` | `bundles/` 中定义的 bundle 名。必填。 |
| `--ref <ref>` | Git tag / 分支 / commit。默认：最新 release；找不到则回退到 `main`。 |
| `--target <dir>` | 安装目录。默认：当前目录。 |
| `--source <repo>` | 源仓库。默认：`rokurokulab/dotai`。 |
| `--force` | 覆盖已存在的文件。默认：跳过并报告。 |
| `--no-hooks` | 从被安装的插件中剥除 hooks/ 子目录。 |
| `--yes`, `-y` | 跳过 hook 安装前的 3 秒确认倒计时。 |
| `--dry-run` | 只打印计划，不写入。 |
| `--debug` | 输出详细 trace。 |

### Hooks 安全

如果某个 bundle 包含带 hook 的插件（当前：`dotai-conventions`），安装器会先打印 hook JSON，等待 3 秒再执行。可以 Ctrl-C 取消、传 `--no-hooks` 在不带 hooks 的情况下安装该插件，或传 `--yes` 静默确认。

## 更新

重新运行同样的 `curl … | sh` 命令即可 —— 传 `--ref` 指定更新的 tag，或 `--force` 覆盖已被本地修改过的文件。安装器默认跳过已存在的文件，所以重复运行不会破坏你的本地定制。

通过 CC marketplace 安装的插件：`/plugin update`。

## 卸载

vendored 安装：删除安装器写入的文件即可。`git diff` 对比安装时的 commit 可以看到精确路径。

CC marketplace 安装：`/plugin uninstall dotai-base@dotai`。

---

如果 dotai 帮你节省了时间，欢迎 ⭐ [github.com/rokurokulab/dotai](https://github.com/rokurokulab/dotai)。
