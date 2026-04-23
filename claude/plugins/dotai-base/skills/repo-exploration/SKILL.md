---
name: repo-exploration
description: Recover the smallest grounded understanding needed for a codebase task before planning or editing.
---

# Repo Exploration

Use this skill when the task is primarily about understanding:

- where behavior lives
- which package / crate / module owns a concern
- what files or contracts are relevant
- how to resume work without rereading the whole repo

## First reads

When relevant, read in this order:

1. `AGENTS.md` (or `CLAUDE.md` / `CONTRIBUTING.md` if `AGENTS.md` is absent)
2. Any repo-specific session / handoff notes (e.g. an in-flight planning doc the user points at)
3. The repo's top-level `README.md` only if the above don't exist

For package-level orientation, look for a repo-internal map if one exists (`docs/architecture.md`, `docs/repo-reading.md`, etc.). If none exists, reconstruct one on the fly from the top-level directory names + `Cargo.toml` / `package.json` / `go.mod` workspaces.

## Search rules

- Prefer fast local search (Grep, Glob) and targeted file reads.
- Search for meaning, not just symbol names.
- Avoid broad repo scans unless the task is truly repo-wide.

## Output contract

Before proposing edits, produce a compact exploration result:

1. Relevant files and symbols
2. Confirmed ownership and control-flow boundaries
3. Stable references or session notes worth loading next
4. Open questions that still block planning

## Anti-patterns

Do not:

- jump straight into edits
- treat old session notes as source of truth without checking current code
- summarize unrelated packages
- mistake "hot files" (many recent commits) for "authoritative files" (the real owner)
