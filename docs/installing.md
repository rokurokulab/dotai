# Installing dotai

Two ways to consume dotai content. They use the same source repo and can be combined freely.

## Option A — Claude Code native marketplace

If you only need the CC plugins (skills, sub-agents, hooks, commands), use Claude Code's built-in marketplace. Nothing to install or curl.

```text
/plugin marketplace add rokurokulab/dotai
/plugin install dotai-base@dotai             # safe content: skills + implementer agent
/plugin install dotai-conventions@dotai      # adds the post-edit-lint hook + /pr-summary
```

CC clones dotai under `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` and loads it for the current session. Updates are managed by `/plugin update`.

This path is **CC-only** — it doesn't materialize `AGENTS.md`, the Codex example config, or anything else outside CC's plugin system.

## Option B — Generic `curl | sh` installer

For everything else (AGENTS.md, Codex configs, multi-tool installs, fine-grained selection), use `install.sh`:

```sh
# Pinned to a specific release — recommended
curl -sSL https://github.com/rokurokulab/dotai/releases/download/v0.1.0/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions

# Always-latest (less reproducible, but auto-tracks releases)
curl -sSL https://github.com/rokurokulab/dotai/releases/latest/download/install.sh \
  | sh -s -- --tools claude,codex --bundle conventions
```

The installer requires `curl`, `jq`, and `tar` (default on macOS / Ubuntu / Alpine).

### Bundles

| Bundle | What lands |
|---|---|
| `minimal` | `AGENTS.md` only. |
| `conventions` | `AGENTS.md` + 3 standalone skills (`code-review`, `commit-message`, `changelog`) + `dotai-base` CC plugin (skills + `implementer` sub-agent) + Codex `.codex/config.toml` example. **No hooks.** |
| `everything` | Everything above + `dotai-conventions` CC plugin, which adds a `PostToolUse` lint hook on Edit/Write and the `/pr-summary` slash command. |

### Flags

| Flag | Meaning |
|---|---|
| `--tools <list>` | Comma-separated: `claude`, `codex`, or `all`. Required. |
| `--bundle <name>` | Bundle from `bundles/`. Required. |
| `--ref <ref>` | Git tag / branch / commit. Default: latest release; falls back to `main`. |
| `--target <dir>` | Where to install. Default: current directory. |
| `--source <repo>` | Source repo. Default: `rokurokulab/dotai`. |
| `--force` | Overwrite existing files. Default: skip and report. |
| `--no-hooks` | Strip any hooks/ subdirectory from installed plugins. |
| `--yes`, `-y` | Skip the 3-second hook confirmation countdown. |
| `--dry-run` | Print the plan without writing. |
| `--debug` | Verbose tracing. |

### Hooks security

If a bundle contains a plugin with a hook (currently: `dotai-conventions`), the installer prints the hook JSON and waits 3 seconds before installing. Cancel with Ctrl-C, or pass `--no-hooks` to install the plugin without its hooks/, or `--yes` to acknowledge silently.

## Updating

Re-run the same `curl … | sh` command — pass `--ref` to a newer tag, or use `--force` to overwrite files that have local edits. The installer skips files that already exist by default, so accidental re-runs don't trash your customizations.

For CC-marketplace-installed plugins: `/plugin update`.

## Uninstalling

Vendored install: delete the files the installer wrote. `git diff` against the install commit shows the exact paths.

CC marketplace: `/plugin uninstall dotai-base@dotai`.

---

If dotai saved you time, ⭐ [github.com/rokurokulab/dotai](https://github.com/rokurokulab/dotai).
