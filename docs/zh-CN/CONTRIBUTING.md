# 参与 dotai 开发

> [English](../../CONTRIBUTING.md) | **简体中文**

本文档面向参与 dotai 仓库本身开发的人。如果你只是想在项目中**使用** dotai，请阅读 [`README.md`](../../README.md) 与 [`installing.md`](installing.md)。

> [!NOTE]
> 仓库根目录的 `AGENTS.md` 是早期 bootstrap 阶段的贡献者笔记，与本文档冲突时以本文档为准。`shared/AGENTS.md` 是另一回事 —— 那是**分发给消费者的模板**，不是贡献者文档。

## dotai 是什么

一个跨工具的 **AI 编码 Agent 配置注册表 + 安装器**。消费者通过两条路径把 dotai 中的内容装入自己的仓库：

1. **Claude Code 原生 marketplace** —— 装 `claude/` 下的插件。
2. **通用 `curl | sh` 安装器**（`scripts/install.sh`）—— 装所有内容，包括 `AGENTS.md`、Codex 配置，以及（未来的）其他生态。

dotai **不是** GitHub template。不要 fork；从它安装。

## 仓库结构

```
dotai/
├── shared/                           # 单一来源（source of truth）
│   ├── AGENTS.md                     # 跨工具工作约定
│   └── skills/<name>/SKILL.md        # 可复用的 skill（模型自发调用）
├── claude/
│   └── plugins/
│       ├── dotai-base/               # skills + implementer 子 agent
│       │   ├── .claude-plugin/plugin.json
│       │   ├── agents/
│       │   └── skills/<name>/        # 由 shared/skills/ 渲染而来
│       └── dotai-conventions/        # hooks + /pr-summary 命令
│           ├── .claude-plugin/plugin.json
│           ├── commands/
│           ├── hooks/hooks.json
│           └── scripts/
├── codex/
│   ├── AGENTS.md                     # 由 shared/AGENTS.md 渲染而来
│   ├── skills/<name>/SKILL.md        # 由 shared/skills/ 渲染而来
│   └── .codex/config.toml.example
├── bundles/                          # 供 install.sh 使用的 TOML 清单
│   ├── minimal.toml
│   ├── conventions.toml
│   └── everything.toml
├── scripts/
│   ├── install.sh                    # 面向用户的安装器
│   └── render.sh                     # 仅维护者使用的渲染器
├── docs/                             # 面向用户的文档
│   ├── installing.md
│   └── zh-CN/
├── .claude-plugin/
│   └── marketplace.json              # CC marketplace 清单
├── Taskfile.yml                      # Task runner 配方
├── licenserc.toml                    # hawkeye 头部配置
└── cliff.toml                        # git-cliff changelog 配置
```

## 来源模型：`shared/` → 渲染产物

`shared/` 是规范源。`scripts/render.sh` 把它物化到各生态目录：

| 来源 | 渲染产物 |
|---|---|
| `shared/AGENTS.md` | `codex/AGENTS.md` |
| `shared/skills/<name>/SKILL.md` | `claude/plugins/dotai-base/skills/<name>/SKILL.md` **以及** `codex/skills/<name>/SKILL.md` |

渲染产物会被提交到仓库（不是在安装时动态生成）。`.gitattributes` 把它们标记为 `linguist-generated=true`，这样 GitHub 会在 PR review 中折叠这些差异。

CI 会跑 `bash scripts/render.sh --check`，阻止忘记重新渲染的 merge。

**永远不要手工编辑渲染产物。** 改 `shared/`，再重新渲染。

## Bundles

Bundle 是扁平的 TOML 清单，告诉 `install.sh` 要落地什么。当前的 bundle：

| Bundle | 落地内容 |
|---|---|
| `minimal` | 仅 `AGENTS.md`。不含 skill、插件、Codex 配置。 |
| `conventions` | `AGENTS.md` + 3 个 skill（`code-review`、`commit-message`、`changelog`）+ `dotai-base` CC 插件 + Codex `.codex/config.toml`。不含 hooks。 |
| `everything` | `conventions` 的全部 + 另 4 个 skill（`github-pr`、`github-issue`、`github-milestone`、`repo-exploration`）+ `dotai-conventions` CC 插件（PreToolUse git/gh guard、PostToolUse lint hook、`/pr-summary`）。 |

`install.sh` 的 TOML 解析器是 awk 脚本，**只支持单行数组**：

```toml
skills = ["code-review", "commit-message", "changelog"]   # OK
skills = [                                                # 不支持
  "code-review",
  "commit-message",
]
```

保持 bundle 文件扁平，列表写在单行里。

## 新增一个 skill

1. 创建 `shared/skills/<name>/SKILL.md`，带上 frontmatter：

   ```yaml
   ---
   name: <name>
   description: <何时调用；≤1024 字符>
   ---
   ```

   `name` 只能是小写字母 + 连字符，最长 64 字符。`description` 是模型发现 skill 的信号 —— 写清楚**什么场景应该调用**。

2. 重新渲染：

   ```sh
   task render
   # 或，无 Taskfile 时：
   bash scripts/render.sh --write
   ```

3. 提交 `shared/skills/<name>/SKILL.md` **以及**两份渲染产物（`claude/plugins/dotai-base/skills/<name>/SKILL.md`、`codex/skills/<name>/SKILL.md`）。

4. 如果这个 skill 要进 `everything` bundle，把 skill 名加入 `bundles/everything.toml` 的 `skills` 数组。（baseline 那几个还要出现在 `conventions.toml` 里；见下方定位注意。）

定位注意：dotai 的 skill 数量有意保持在小 baseline 范围（见 `shared/AGENTS.md` 与项目文档）。新 skill 默认归宿是 `yarimasune`，不是 dotai。在这里加 skill 前先问自己：**没有它，第一次 `install.sh --bundle conventions` 是否明显残缺？** 如果不是，这个 skill 应该去别处。

## 新增一个插件

1. 创建 `claude/plugins/<name>/.claude-plugin/plugin.json`：

   ```json
   {
     "name": "<name>",
     "description": "...",
     "version": "0.0.0",
     "author": { "name": "rokurokulab" }
   }
   ```

2. 按需要铺子目录（`agents/`、`commands/`、`hooks/hooks.json`、`scripts/`）。Hooks 放在 `hooks/hooks.json`，**不要**放在 `plugin.json` 里。

3. 在 `.claude-plugin/marketplace.json` 里注册插件 —— 与 `dotai-base` / `dotai-conventions` 并列加一项。

4. 如果插件也要通过 curl 安装器可选装，把插件名加到对应 `bundles/*.toml` 的 `plugins` 数组。

定位注意：dotai 只接受 infra 性质的插件（install / render / guard / convention enforcement）。内容密集型插件归 `yarimasune`。

## 本地 lint 与校验

装了 Taskfile：

```sh
task              # 列出配方
task lint         # hawkeye + jq + shellcheck
task render-check # scripts/render.sh --check
task render       # scripts/render.sh --write
task test-install # 把 install.sh 烟测到 /tmp 目标
```

没装 Taskfile 时，对应原始命令：

```sh
hawkeye check
find . -path ./.git -prune -o -name "*.json" -print | xargs -I{} jq empty {}
find . -path ./.git -prune -o \( -name "*.sh" -o -name "*.bash" \) -print | xargs -r shellcheck
bash scripts/render.sh --check
```

CI（`.github/workflows/ci.yml`）会在每个 PR 上跑同样的检查。

## License 头

License 头策略写在 [`licenserc.toml`](../../licenserc.toml)，由 [hawkeye](https://github.com/korandoru/hawkeye) 校验。

覆盖范围：

- **需要头部**：`scripts/` 下和 `claude/plugins/*/scripts/` 下的 shell 脚本 —— 文件顶部加 Apache-2.0 头。
- **排除**：`shared/`、`claude/`、`codex/`、`bundles/`、`docs/`，以及仓库内所有 `.md` / `.json` / `.yaml` / `.toml` 文件。

面向用户的内容不带头部 —— 它会被原样装进别人的项目，我们的版权头在那里是噪声。

如果你新增的 shell 脚本不在排除路径里，从 `scripts/` 下某个现成脚本 copy 头部即可。

## Commits 与 PR

- **Conventional Commits** —— `feat(scope): ...`、`fix(scope): ...`、`docs(scope): ...` 等。changelog 管道按 type 分组。
- Scope = 归属包 / 顶层区域：`shared`、`claude`、`codex`、`bundles`、`scripts`、`docs`、`ci`、`workspace`。
- commit subject 保持简短。diff 大小合理；不相关的改动拆开。
- **用 merge，不要 squash。** PR 以普通 merge commit 方式落地，使每个 commit 的 scope 在历史中保留。
- **不带 tool-attribution 署名**（`🤖 Generated with …`、`Co-Authored-By: Claude` 等）。写清楚改动本身，不附加署名。
- **Tags / releases / `CHANGELOG.md`** 由用户手动操作。CI 会在 tag push 时重新生成 `CHANGELOG.md` —— 不要在 PR 里手工改它，也不要在 PR 里打 tag。

## 外部贡献

dotai 是**策展性质**的注册表，baseline 有意控制得小。当前**不接受**外部插件或 skill 进入本仓。

可以做的事：

- **Fork 并自建 marketplace** —— 结构就是为此设计的。让用户 `/plugin marketplace add <你的 fork>`，你自己维护 bundle。
- **开 issue** 报 bug、提文档缺漏、就安装器 / 渲染管道 / bundle schema 提问。
- **开 PR** 修 `shared/` 已有内容、安装器 bug、CI 改进、文档。以上属于 in scope。

如 [`.github`](../../.github/) 下有 issue / PR 模板，按其约定；否则 PR 标题用 Conventional Commits 格式，PR body 直接描述改动本身。

## License

Apache-2.0 —— 见 [`LICENSE`](../../LICENSE)。
