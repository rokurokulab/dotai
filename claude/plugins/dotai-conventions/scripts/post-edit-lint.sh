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

# post-edit-lint.sh — PostToolUse hook for Edit|Write events.
#
# CC pipes a JSON payload to stdin (the tool-use record). We extract
# the file_path field and run the appropriate linter if it is installed.
# We *always* exit 0 — this hook is informational, not a gate. The
# agent should hear about lint findings but not be blocked from writing.
#
# Adding a new file type: add a case branch below mapping the
# extension to a linter command. Each linter is invoked only if
# `command -v` finds the binary.

set -eu

# ────────────────────────────────────────────────────────────────────
# Parse stdin (CC tool-use payload) → extract file_path
# ────────────────────────────────────────────────────────────────────

if ! command -v jq >/dev/null 2>&1; then
    # No jq → can't parse payload. Quietly skip (we promised not to block).
    exit 0
fi

payload=$(cat)

# CC's PostToolUse payload schema (Edit/Write):
#   .tool_input.file_path  → absolute or workspace-relative path
file_path=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
    # No file path or file vanished — nothing to lint.
    exit 0
fi

# ────────────────────────────────────────────────────────────────────
# Pick a linter by extension; skip if linter not installed
# ────────────────────────────────────────────────────────────────────

ext=${file_path##*.}
output=""
linter=""

case "$ext" in
    sh|bash)
        if command -v shellcheck >/dev/null 2>&1; then
            linter="shellcheck"
            output=$(shellcheck "$file_path" 2>&1) || true
        fi
        ;;
    json)
        if command -v jq >/dev/null 2>&1; then
            linter="jq"
            output=$(jq empty "$file_path" 2>&1) || true
        fi
        ;;
    yml|yaml)
        if command -v python3 >/dev/null 2>&1; then
            linter="python yaml"
            output=$(python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$file_path" 2>&1) || true
        fi
        ;;
    py)
        if command -v ruff >/dev/null 2>&1; then
            linter="ruff"
            output=$(ruff check "$file_path" 2>&1) || true
        fi
        ;;
    go)
        if command -v gofmt >/dev/null 2>&1; then
            linter="gofmt"
            output=$(gofmt -l "$file_path" 2>&1) || true
        fi
        ;;
    *)
        # No linter for this extension. Done.
        exit 0
        ;;
esac

# ────────────────────────────────────────────────────────────────────
# Surface findings (if any) to stderr — CC shows hook stderr to model
# ────────────────────────────────────────────────────────────────────

if [ -n "$output" ]; then
    printf 'post-edit-lint (%s) for %s:\n%s\n' "$linter" "$file_path" "$output" >&2
fi

exit 0
