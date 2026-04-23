# Contributing to dotai

> [English](CONTRIBUTING.md) | [简体中文](docs/zh-CN/CONTRIBUTING.md)

This file is for people hacking on the dotai repo itself. If you just want to *use* dotai in a project, read [`README.md`](README.md) and [`docs/installing.md`](docs/installing.md) instead.

> [!NOTE]
> `AGENTS.md` at the repo root is an older bootstrap-era contributor note. When it conflicts with this file, this file wins. `shared/AGENTS.md` is unrelated — that's the **template distributed to consumers**, not a contributor doc.

## What dotai is

A **registry + installer** for cross-tool AI coding agent configs. Consumers install *from* dotai into their own repos via two paths:

1. **Claude Code native marketplace** — for plugins under `claude/`.
2. **Generic `curl | sh` installer** (`scripts/install.sh`) — for everything, including `AGENTS.md`, Codex configs, and (later) other ecosystems.

dotai is not a GitHub template. Don't fork; install from it.

## Repository structure

```
dotai/
├── shared/                           # Source of truth
│   ├── AGENTS.md                     # Cross-tool working agreement
│   └── skills/<name>/SKILL.md        # Reusable skills (model-invoked)
├── claude/
│   └── plugins/
│       ├── dotai-base/               # Skills + implementer sub-agent
│       │   ├── .claude-plugin/plugin.json
│       │   ├── agents/
│       │   └── skills/<name>/        # Rendered from shared/skills/
│       └── dotai-conventions/        # Hooks + /pr-summary command
│           ├── .claude-plugin/plugin.json
│           ├── commands/
│           ├── hooks/hooks.json
│           └── scripts/
├── codex/
│   ├── AGENTS.md                     # Rendered from shared/AGENTS.md
│   ├── skills/<name>/SKILL.md        # Rendered from shared/skills/
│   └── .codex/config.toml.example
├── bundles/                          # TOML manifests for install.sh
│   ├── minimal.toml
│   ├── conventions.toml
│   └── everything.toml
├── scripts/
│   ├── install.sh                    # User-facing installer
│   └── render.sh                     # Maintainer-only renderer
├── docs/                             # User-facing docs
│   ├── installing.md
│   └── zh-CN/
├── .claude-plugin/
│   └── marketplace.json              # CC marketplace manifest
├── Taskfile.yml                      # Task runner recipes
├── licenserc.toml                    # hawkeye header config
└── cliff.toml                        # git-cliff changelog config
```

## Source-of-truth model: `shared/` → rendered outputs

`shared/` is canonical. `scripts/render.sh` materializes it into the per-ecosystem directories:

| Source | Rendered output(s) |
|---|---|
| `shared/AGENTS.md` | `codex/AGENTS.md` |
| `shared/skills/<name>/SKILL.md` | `claude/plugins/dotai-base/skills/<name>/SKILL.md` **and** `codex/skills/<name>/SKILL.md` |

Rendered files are committed (not generated at install time). `.gitattributes` marks them `linguist-generated=true` so GitHub folds them in PR review.

CI runs `bash scripts/render.sh --check` to block merges whose rendered outputs diverge from `shared/`.

**Never edit the rendered copies by hand.** Edit `shared/` and re-render.

## Bundles

Bundles are flat TOML manifests that tell `install.sh` what to lay down. Current bundles:

| Bundle | Installs |
|---|---|
| `minimal` | `AGENTS.md` only. No skills, no plugins, no Codex config. |
| `conventions` | `AGENTS.md` + 3 skills (`code-review`, `commit-message`, `changelog`) + `dotai-base` CC plugin + Codex `.codex/config.toml`. No hooks. |
| `everything` | Everything in `conventions` + 4 more skills (`github-pr`, `github-issue`, `github-milestone`, `repo-exploration`) + `dotai-conventions` CC plugin (PreToolUse git/gh guard, PostToolUse lint hook, `/pr-summary`). |

The `install.sh` TOML parser is an awk script and supports **single-line arrays only**:

```toml
skills = ["code-review", "commit-message", "changelog"]   # OK
skills = [                                                # NOT supported
  "code-review",
  "commit-message",
]
```

Keep bundle files flat and on one line per list.

## Adding a skill

1. Create `shared/skills/<name>/SKILL.md` with frontmatter:

   ```yaml
   ---
   name: <name>
   description: <when to invoke; ≤1024 chars>
   ---
   ```

   `name` is lowercase + hyphens, max 64 chars. `description` is the discovery signal — write it so the model can tell when to invoke.

2. Re-render:

   ```sh
   task render
   # or, without Taskfile:
   bash scripts/render.sh --write
   ```

3. Commit `shared/skills/<name>/SKILL.md` *and* both rendered copies (`claude/plugins/dotai-base/skills/<name>/SKILL.md`, `codex/skills/<name>/SKILL.md`).

4. If the skill should ship in the `everything` bundle, add its name to the `skills` array in `bundles/everything.toml`. (Baseline skills also live in `conventions.toml`; adjust with care — see scope note below.)

Scope note: dotai's skill count is capped at a small baseline (see `shared/AGENTS.md` and project docs). New skills default to `yarimasune`, not dotai. Before adding a skill here, ask: *without this, would a first-time `install.sh --bundle conventions` feel broken?* If no, it belongs elsewhere.

## Adding a plugin

1. Create `claude/plugins/<name>/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "<name>",
     "description": "...",
     "version": "0.0.0",
     "author": { "name": "rokurokulab" }
   }
   ```

2. Lay out sub-directories as needed (`agents/`, `commands/`, `hooks/hooks.json`, `scripts/`). Hooks live in `hooks/hooks.json`, **not** in `plugin.json`.

3. Register the plugin in `.claude-plugin/marketplace.json` — add an entry alongside `dotai-base` / `dotai-conventions`.

4. If the plugin should be selectable via the curl installer, add its name to the relevant `bundles/*.toml` `plugins` array.

Scope note: dotai only accepts infra-flavoured plugins (install / render / guard / convention enforcement). Content-heavy plugins belong in `yarimasune`.

## Local linting and verification

With Taskfile:

```sh
task             # list recipes
task lint        # hawkeye + jq + shellcheck
task render-check # scripts/render.sh --check
task render      # scripts/render.sh --write
task test-install # smoke-test install.sh into a /tmp target
```

Without Taskfile, the raw commands:

```sh
hawkeye check
find . -path ./.git -prune -o -name "*.json" -print | xargs -I{} jq empty {}
find . -path ./.git -prune -o \( -name "*.sh" -o -name "*.bash" \) -print | xargs -r shellcheck
bash scripts/render.sh --check
```

CI (`.github/workflows/ci.yml`) runs the same checks on every PR.

## License headers

License-header policy is in [`licenserc.toml`](licenserc.toml), checked by [hawkeye](https://github.com/korandoru/hawkeye).

Header coverage:

- **Required**: shell scripts under `scripts/` and under `claude/plugins/*/scripts/` — Apache-2.0 header at the top.
- **Excluded**: `shared/`, `claude/`, `codex/`, `bundles/`, `docs/`, and every `.md` / `.json` / `.yaml` / `.toml` file anywhere in the tree.

User-facing content is header-free because it gets installed verbatim into other people's projects; our copyright header there would be noise.

If you add a new shell script outside the excluded paths, copy the header from an existing script under `scripts/`.

## Commits and PRs

- **Conventional Commits** — `feat(scope): ...`, `fix(scope): ...`, `docs(scope): ...`, etc. The changelog pipeline groups commits by type.
- Scope = the owning package / top-level area: `shared`, `claude`, `codex`, `bundles`, `scripts`, `docs`, `ci`, `workspace`.
- Keep commit subjects short. Keep diffs reasonably sized; split unrelated changes.
- **Merge, don't squash.** PRs land with a regular merge commit so the per-commit scope survives in history.
- **No tool-attribution footers** (`🤖 Generated with …`, `Co-Authored-By: Claude`, etc.). Describe the change; skip the attribution.
- **Tags / releases / `CHANGELOG.md`** are user-manual. CI regenerates `CHANGELOG.md` on tag push — don't hand-edit it, don't create tags in PRs.

## External contributions

dotai is a **curated** registry with an intentional small baseline. We don't currently accept external plugins or skills into this repo.

What you can do instead:

- **Fork and run your own marketplace** — the structure is designed for this. Point `/plugin marketplace add <your-fork>` at it and publish your own bundles.
- **Open an issue** for bugs, doc gaps, or questions about the installer / render pipeline / bundle schema.
- **Open a PR** for fixes to existing `shared/` content, installer bugs, CI improvements, or docs. These are in scope.

Follow the issue / PR conventions in [`.github`](.github/) if present; otherwise keep titles in Conventional Commits form and describe the change directly in the body.

## License

Apache-2.0 — see [`LICENSE`](LICENSE).
