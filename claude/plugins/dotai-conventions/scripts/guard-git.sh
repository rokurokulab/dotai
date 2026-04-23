#!/bin/bash
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

# guard-git.sh — PreToolUse hook for Bash tool.
#
# Blocks:
#   1. git commit on a protected branch
#   2. git add -A / --all / .
#   3. git add -f / --force
#   4. git push --force / -f on protected branches
#   5. Planning jargon (Phase/Tier/EPIC-N/Batch/Wave/Block) in gh titles
#   6. gh pr/issue create without --label/--assignee (opt-in)
#
# Fail-open on parse/runtime errors; exit 2 on confirmed violations.
#
# Config:
#   GUARD_GIT_PROTECTED_BRANCHES   space-separated list; default "main"
#   GUARD_GIT_REQUIRE_PR_METADATA  "1" to enable Guard 6
#
# Requires: bash, jq.

warn() { echo "[guard-git] WARNING: $1 — guard inactive for this call" >&2; }

input=$(cat 2>/dev/null) || { warn "cannot read stdin"; exit 0; }
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || { warn "jq parse failed (is jq installed?)"; exit 0; }
[[ -z "$command" ]] && exit 0

protected_branches="${GUARD_GIT_PROTECTED_BRANCHES:-main}"

is_protected() {
  local b="$1" p
  for p in $protected_branches; do
    [[ "$b" == "$p" ]] && return 0
  done
  return 1
}

pat_commit='git[[:space:]]+commit'
pat_add_all='git[[:space:]]+add[[:space:]]+(-A|--all)([[:space:]]|$)'
pat_add_dot='git[[:space:]]+add[[:space:]]+\.([[:space:];&|]|$)'
pat_add_force='git[[:space:]]+add[[:space:]]+(.*[[:space:]])?(-f|--force)([[:space:]]|$)'
pat_push_force='git[[:space:]]+push[[:space:]]+(.*[[:space:]])?(-f|--force)([[:space:]]|$)'
pat_gh_create='gh[[:space:]]+(issue|pr)[[:space:]]+create'
jargon_pat='[Bb]lock[[:space:]]+[A-Z]|[Pp]hase[[:space:]]+[0-9]|[Tt]ier[[:space:]]+[0-9]|EPIC-[0-9]|[Bb]atch[[:space:]]+[0-9]|[Ww]ave[[:space:]]+[0-9]'

if [[ "$command" =~ $pat_commit ]]; then
  cd_target=$(printf '%s' "$command" | sed -nE 's/^[[:space:]]*cd[[:space:]]+([^[:space:];&|]+).*/\1/p' 2>/dev/null || true)
  if [[ -n "$cd_target" && -d "$cd_target" ]]; then
    branch=$(git -C "$cd_target" branch --show-current 2>/dev/null) || { warn "cannot detect branch in cd target"; exit 0; }
  else
    branch=$(git branch --show-current 2>/dev/null) || { warn "cannot detect branch"; exit 0; }
  fi
  if is_protected "$branch"; then
    echo "BLOCKED: Cannot commit directly on protected branch '$branch'." >&2
    exit 2
  fi
fi

if [[ "$command" =~ $pat_add_all ]]; then
  echo "BLOCKED: Do not use 'git add -A/--all'. Stage specific files by path." >&2
  exit 2
fi

if [[ "$command" =~ $pat_add_dot ]]; then
  echo "BLOCKED: Do not use 'git add .'. Stage specific files by path." >&2
  exit 2
fi

if [[ "$command" =~ $pat_add_force ]]; then
  echo "BLOCKED: Do not use 'git add -f/--force'." >&2
  exit 2
fi

if [[ "$command" =~ $pat_push_force ]]; then
  branch=$(git branch --show-current 2>/dev/null) || { warn "cannot detect branch"; exit 0; }
  if is_protected "$branch"; then
    echo "BLOCKED: Cannot force push to protected branch '$branch'." >&2
    exit 2
  fi
fi

if [[ "$command" =~ $pat_gh_create ]]; then
  title=$(printf '%s' "$command" | sed -n 's/.*--title[[:space:]]*["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/p' 2>/dev/null || true)
  if [[ -n "$title" ]] && printf '%s' "$title" | grep -qE "$jargon_pat" 2>/dev/null; then
    echo "BLOCKED: gh title contains planning jargon (Block/Phase/Tier/EPIC-N/Batch/Wave)." >&2
    exit 2
  fi
fi

if [[ "${GUARD_GIT_REQUIRE_PR_METADATA:-0}" == "1" ]]; then
  pat_pr_create='gh[[:space:]]+pr[[:space:]]+create'
  pat_issue_create='gh[[:space:]]+issue[[:space:]]+create'
  if [[ "$command" =~ $pat_pr_create ]] || [[ "$command" =~ $pat_issue_create ]]; then
    missing=""
    if ! printf '%s' "$command" | grep -qE '\-\-label|\-\-add-label' 2>/dev/null; then
      missing="${missing}--label "
    fi
    if ! printf '%s' "$command" | grep -qE '\-\-assignee|\-\-add-assignee' 2>/dev/null; then
      missing="${missing}--assignee "
    fi
    if [[ -n "$missing" ]]; then
      echo "BLOCKED: gh pr/issue create missing: ${missing}" >&2
      exit 2
    fi
  fi
fi

exit 0
