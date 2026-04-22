#!/bin/sh
# Copyright 2026 itscheems
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# install.sh — fetch dotai content into a target project.
#
# Vendored install: copies files from a versioned snapshot of the dotai
# repo into your project. Supports CC plugins, standalone skills, the
# cross-tool AGENTS.md, and the Codex example config.
#
# Quick start:
#   curl -sSL https://github.com/rokurokulab/dotai/releases/latest/download/install.sh \
#     | sh -s -- --tools claude,codex --bundle conventions
#
# This script is intentionally one POSIX-sh file (~no helpers) so it can
# be `curl | sh`-installed without any extra setup. Hard requirements:
# `curl`, `jq`, `tar` — all default-available on macOS, Ubuntu, Alpine.

set -eu

# ─────────────────────────────────────────────────────────────
# Constants & defaults
# ─────────────────────────────────────────────────────────────

DEFAULT_SOURCE="rokurokulab/dotai"
GITHUB_API="https://api.github.com"
GITHUB="https://github.com"

# Flag-driven config
tools=""
bundle=""
ref=""
target="."
source_repo="$DEFAULT_SOURCE"
force=0
dry_run=0
no_hooks=0
yes=0
debug=0

# ─────────────────────────────────────────────────────────────
# Logging helpers
# ─────────────────────────────────────────────────────────────

log()   { printf '%s\n' "$*" >&2; }
debug() {
    if [ "$debug" = "1" ]; then
        printf 'DEBUG: %s\n' "$*" >&2
    fi
}
die()   { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# ─────────────────────────────────────────────────────────────
# Usage
# ─────────────────────────────────────────────────────────────

usage() {
    cat >&2 <<'EOF'
Usage: install.sh [options]

Selection (at least --tools and --bundle required):
  --tools <list>     Comma-separated ecosystems: claude, codex, all
  --bundle <name>    Bundle name from bundles/<name>.toml (e.g. minimal,
                     conventions, everything)

Source:
  --ref <git-ref>    Git tag, branch, or commit. Default: latest release;
                     falls back to 'main' if no releases yet.
  --source <repo>    Source repo (default: rokurokulab/dotai)

Behavior:
  --target <dir>     Install destination (default: current directory)
  --force            Overwrite existing files
  --no-hooks         Strip any hooks/ subdir from installed plugins
  --yes / -y         Skip the 3-second hook confirmation countdown
  --dry-run          Print plan without writing
  --debug            Verbose tracing
  -h, --help         This message

Examples:
  install.sh --tools claude --bundle minimal
  install.sh --tools claude,codex --bundle conventions --target ~/myrepo
  install.sh --tools all --bundle everything --no-hooks
  install.sh --tools claude --bundle conventions --ref v0.1.0
EOF
    exit 2
}

# ─────────────────────────────────────────────────────────────
# Flag parsing
# ─────────────────────────────────────────────────────────────

while [ "$#" -gt 0 ]; do
    case "$1" in
        --tools)    tools="${2:-}";        shift 2 ;;
        --bundle)   bundle="${2:-}";       shift 2 ;;
        --ref)      ref="${2:-}";          shift 2 ;;
        --target)   target="${2:-}";       shift 2 ;;
        --source)   source_repo="${2:-}";  shift 2 ;;
        --force)    force=1;               shift ;;
        --dry-run)  dry_run=1;             shift ;;
        --no-hooks) no_hooks=1;            shift ;;
        --yes|-y)   yes=1;                 shift ;;
        --debug)    debug=1;               shift ;;
        -h|--help)  usage ;;
        *)          log "unknown flag: $1"; usage ;;
    esac
done

[ -n "$tools" ]  || { log "missing --tools"; usage; }
[ -n "$bundle" ] || { log "missing --bundle"; usage; }

# ─────────────────────────────────────────────────────────────
# Dependency check
# ─────────────────────────────────────────────────────────────

require() {
    if ! command -v "$1" >/dev/null 2>&1; then
        cat >&2 <<EOF
dotai install needs '$1' but it is not installed.

  macOS:  brew install $1
  Ubuntu: sudo apt install -y $1
  Alpine: apk add --no-cache $1

EOF
        exit 1
    fi
}

require curl
require jq
require tar

# ─────────────────────────────────────────────────────────────
# Parse --tools selection
# ─────────────────────────────────────────────────────────────

has_claude=0
has_codex=0
for t in $(printf '%s' "$tools" | tr ',' ' '); do
    case "$t" in
        all)    has_claude=1; has_codex=1 ;;
        claude) has_claude=1 ;;
        codex)  has_codex=1 ;;
        *)      die "unknown tool: $t (valid: claude, codex, all)" ;;
    esac
done
[ "$has_claude" = "1" ] || [ "$has_codex" = "1" ] || die "no tools selected"

# ─────────────────────────────────────────────────────────────
# Resolve ref (latest release tag, or fallback to 'main')
# ─────────────────────────────────────────────────────────────

if [ -z "$ref" ]; then
    log "fetching latest release tag from $source_repo..."
    ref=$(curl -sSL "$GITHUB_API/repos/$source_repo/releases/latest" \
        | jq -r '.tag_name // empty' 2>/dev/null || true)
    if [ -z "$ref" ] || [ "$ref" = "null" ]; then
        log "no published releases yet; falling back to main branch"
        ref="main"
    fi
fi
log "using ref: $ref"

# ─────────────────────────────────────────────────────────────
# Fetch source tarball into a temp dir (auto-cleanup on exit)
# ─────────────────────────────────────────────────────────────

tmp=$(mktemp -d 2>/dev/null || mktemp -d -t dotai-install)
trap 'rm -rf "$tmp"' EXIT INT HUP TERM

debug "tmp dir: $tmp"

# Try tag first, then branch.
url_tag="$GITHUB/$source_repo/archive/refs/tags/$ref.tar.gz"
url_head="$GITHUB/$source_repo/archive/refs/heads/$ref.tar.gz"
url=""
for u in "$url_tag" "$url_head"; do
    if curl -sSLfI -o /dev/null "$u" 2>/dev/null; then
        url="$u"
        break
    fi
done
[ -n "$url" ] || die "could not find $ref as tag or branch in $source_repo"
debug "downloading: $url"

curl -sSLf "$url" | tar -xz -C "$tmp" || die "tarball extraction failed"
src_dir=$(find "$tmp" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
[ -d "$src_dir" ] || die "tarball had unexpected layout"
debug "extracted source: $src_dir"

# ─────────────────────────────────────────────────────────────
# Read bundle (flat-TOML awk parser; supports our bundle schema only)
# ─────────────────────────────────────────────────────────────

bundle_file="$src_dir/bundles/$bundle.toml"
[ -f "$bundle_file" ] || die "bundle not found: $bundle (looked in $bundle_file)"
debug "bundle: $bundle_file"

# parse_bool <file> <section-after-contents.> <key> → "true" / "false" / ""
parse_bool() {
    awk -v want_section="contents.$2" -v key="$3" '
        /^\[/ {
            section = $0
            sub(/^\[/, "", section); sub(/\][[:space:]]*$/, "", section)
            next
        }
        section == want_section {
            n = split($0, a, "=")
            if (n < 2) next
            k = a[1]; gsub(/[[:space:]]/, "", k)
            if (k != key) next
            v = a[2]
            sub(/[[:space:]]*#.*$/, "", v)   # strip trailing comment
            gsub(/[[:space:]"]/, "", v)      # strip remaining whitespace + quotes
            print v
            exit
        }
    ' "$1"
}

# parse_array <file> <section-after-contents.> <key> → space-separated names
parse_array() {
    awk -v want_section="contents.$2" -v key="$3" '
        /^\[/ {
            section = $0
            sub(/^\[/, "", section); sub(/\][[:space:]]*$/, "", section)
            next
        }
        section == want_section {
            line = $0
            sub(/[[:space:]]*#.*$/, "", line)
            n = index(line, "=")
            if (n == 0) next
            k = substr(line, 1, n - 1); gsub(/[[:space:]]/, "", k)
            if (k != key) next
            v = substr(line, n + 1)
            gsub(/^[^[]*\[|\][^]]*$/, "", v)
            gsub(/["[:space:]]/, "", v)
            gsub(/,/, " ", v)
            print v
            exit
        }
    ' "$1"
}

agents_md=$(parse_bool   "$bundle_file" "shared" "agents_md")
shared_skills=$(parse_array "$bundle_file" "shared" "skills")
claude_plugins=$(parse_array "$bundle_file" "claude" "plugins")
example_config=$(parse_bool "$bundle_file" "codex" "example_config")

debug "bundle: agents_md=$agents_md skills=[$shared_skills] plugins=[$claude_plugins] codex_cfg=$example_config"

# ─────────────────────────────────────────────────────────────
# Build install plan (write to a temp file so we can show then execute)
# ─────────────────────────────────────────────────────────────

plan="$tmp/plan.txt"
hook_plugins=""        # plugins that contain hooks/hooks.json
: > "$plan"

# AGENTS.md (cross-tool)
if [ "$agents_md" = "true" ] && [ -f "$src_dir/shared/AGENTS.md" ]; then
    echo "  AGENTS.md → $target/AGENTS.md" >> "$plan"
fi

# Shared skills → CC standalone (if --tools claude)
if [ "$has_claude" = "1" ] && [ -n "$shared_skills" ]; then
    for skill in $shared_skills; do
        if [ -f "$src_dir/shared/skills/$skill/SKILL.md" ]; then
            echo "  skill $skill → $target/.claude/skills/$skill/SKILL.md" >> "$plan"
        fi
    done
fi

# Claude plugins (whole dir)
if [ "$has_claude" = "1" ] && [ -n "$claude_plugins" ]; then
    for plugin in $claude_plugins; do
        plugin_src="$src_dir/claude/plugins/$plugin"
        [ -d "$plugin_src" ] || die "plugin not found in source: $plugin"
        suffix=""
        if [ -f "$plugin_src/hooks/hooks.json" ]; then
            if [ "$no_hooks" = "1" ]; then
                suffix=" (hooks/ stripped)"
            else
                suffix=" (contains hooks)"
                hook_plugins="$hook_plugins $plugin"
            fi
        fi
        echo "  plugin $plugin → $target/.claude/plugins/$plugin/$suffix" >> "$plan"
    done
fi

# Codex example config
if [ "$has_codex" = "1" ] && [ "$example_config" = "true" ]; then
    if [ -f "$src_dir/codex/.codex/config.toml.example" ]; then
        echo "  codex config → $target/.codex/config.toml" >> "$plan"
    fi
fi

# ─────────────────────────────────────────────────────────────
# Show plan
# ─────────────────────────────────────────────────────────────

echo
echo "dotai install plan ($source_repo @ $ref → $target, bundle=$bundle):"
echo
cat "$plan"
echo

if [ "$dry_run" = "1" ]; then
    echo "(--dry-run; nothing written)"
    exit 0
fi

# ─────────────────────────────────────────────────────────────
# Hook security banner + countdown
# ─────────────────────────────────────────────────────────────

if [ -n "$hook_plugins" ] && [ "$yes" != "1" ]; then
    cat <<EOF
─────────────────────────────────────────────────────────────
  ATTENTION: This install contains hook(s) — shell commands
  that run automatically on certain Claude Code events.

  Review each hook below. Cancel with Ctrl-C, or pass
  --no-hooks to skip just the hooks, or --yes to acknowledge
  silently.
─────────────────────────────────────────────────────────────

EOF
    for plugin in $hook_plugins; do
        echo "[$plugin] hooks/hooks.json:"
        jq '.' "$src_dir/claude/plugins/$plugin/hooks/hooks.json" \
            | sed 's/^/    /'
        echo
    done

    printf 'Continuing in '
    for i in 3 2 1; do
        printf '%s.. ' "$i"
        sleep 1
    done
    printf '\n\n'
fi

# ─────────────────────────────────────────────────────────────
# Execute install
# ─────────────────────────────────────────────────────────────

write_count=0
skip_count=0

copy_or_skip() {
    src=$1
    dst=$2
    if [ -e "$dst" ] && [ "$force" != "1" ]; then
        echo "  skip (exists): $dst"
        skip_count=$((skip_count + 1))
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  wrote: $dst"
    write_count=$((write_count + 1))
}

# AGENTS.md
if [ "$agents_md" = "true" ] && [ -f "$src_dir/shared/AGENTS.md" ]; then
    copy_or_skip "$src_dir/shared/AGENTS.md" "$target/AGENTS.md"
fi

# Shared skills (CC standalone)
if [ "$has_claude" = "1" ] && [ -n "$shared_skills" ]; then
    for skill in $shared_skills; do
        if [ -f "$src_dir/shared/skills/$skill/SKILL.md" ]; then
            copy_or_skip "$src_dir/shared/skills/$skill/SKILL.md" \
                         "$target/.claude/skills/$skill/SKILL.md"
        fi
    done
fi

# CC plugins (whole dir)
if [ "$has_claude" = "1" ] && [ -n "$claude_plugins" ]; then
    for plugin in $claude_plugins; do
        plugin_src="$src_dir/claude/plugins/$plugin"
        plugin_dst="$target/.claude/plugins/$plugin"
        if [ -e "$plugin_dst" ] && [ "$force" != "1" ]; then
            echo "  skip (exists): $plugin_dst"
            skip_count=$((skip_count + 1))
            continue
        fi
        rm -rf "$plugin_dst"
        mkdir -p "$(dirname "$plugin_dst")"
        cp -R "$plugin_src" "$plugin_dst"
        if [ "$no_hooks" = "1" ]; then
            rm -rf "$plugin_dst/hooks"
        fi
        echo "  wrote: $plugin_dst"
        write_count=$((write_count + 1))
    done
fi

# Codex example config
if [ "$has_codex" = "1" ] && [ "$example_config" = "true" ]; then
    if [ -f "$src_dir/codex/.codex/config.toml.example" ]; then
        copy_or_skip "$src_dir/codex/.codex/config.toml.example" \
                     "$target/.codex/config.toml"
    fi
fi

# ─────────────────────────────────────────────────────────────
# Summary + star nudge
# ─────────────────────────────────────────────────────────────

echo
echo "✓ dotai $ref installed at $target  (wrote $write_count, skipped $skip_count)"
echo
echo "If dotai saved you time, ⭐ https://github.com/$source_repo"
