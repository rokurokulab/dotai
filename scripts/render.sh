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

# scripts/render.sh — materialize shared/ into ecosystem dirs.
#
# Maintainer-only. Run before committing anything that derives from shared/.
# CI runs `--check` mode to block PRs that forget to re-render.
#
# Mappings (keep in sync with claude/plugins/dotai-base/.claude-plugin/plugin.json):
#   shared/AGENTS.md             → codex/AGENTS.md
#   shared/skills/<n>/SKILL.md   → claude/plugins/dotai-base/skills/<n>/SKILL.md
#
# POSIX sh: no bashisms.

set -eu

usage() {
    cat >&2 <<'EOF'
Usage: scripts/render.sh [--check | --write]
    --write    (default) Copy shared/ files into their ecosystem destinations.
    --check    Diff shared/ vs ecosystem destinations; exit 1 on any drift.
EOF
    exit 2
}

mode=write
case "${1:-}" in
    --write|"") mode=write ;;
    --check)    mode=check ;;
    -h|--help)  usage ;;
    *)          usage ;;
esac

# Resolve repo root from this script's location.
script_dir=$(cd "$(dirname "$0")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
cd "$repo_root"

drift=0
rendered_count=0
checked_count=0

render_one() {
    src=$1
    dst=$2

    if [ ! -f "$src" ]; then
        echo "ERROR: source missing: $src" >&2
        exit 3
    fi

    if [ "$mode" = check ]; then
        checked_count=$((checked_count + 1))
        if [ ! -f "$dst" ]; then
            echo "DRIFT: missing destination: $dst" >&2
            drift=1
            return
        fi
        if ! cmp -s "$src" "$dst"; then
            echo "DRIFT: $dst differs from $src" >&2
            diff -u "$dst" "$src" | head -40 >&2 || true
            drift=1
        fi
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        rendered_count=$((rendered_count + 1))
        echo "rendered: $dst"
    fi
}

# 1. AGENTS.md → codex
render_one shared/AGENTS.md codex/AGENTS.md

# 2. Skills → CC dotai-base plugin
for skill_dir in shared/skills/*/; do
    # Guard against empty glob (no skills yet).
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    render_one \
        "shared/skills/$skill_name/SKILL.md" \
        "claude/plugins/dotai-base/skills/$skill_name/SKILL.md"
done

if [ "$mode" = check ]; then
    if [ "$drift" -ne 0 ]; then
        echo >&2
        echo "render-check failed. Run \`task render\` and commit the result." >&2
        exit 1
    fi
    echo "render-check: $checked_count file(s) up to date."
else
    echo "render: $rendered_count file(s) materialized."
fi
