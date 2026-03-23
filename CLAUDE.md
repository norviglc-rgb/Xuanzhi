# CLAUDE.md

This repository uses Claude Code official project instructions plus project hooks in `.claude/settings.json`.

## Always-First

Claude Code must respect the project hooks and the shared control plane before any write or closeout step.

The shared hard-guard entrypoint is:

```powershell
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/invoke-session-hard-guards.ps1
```

## Shared Status Sources

Read and follow these machine-readable files:

1. `.codex/SESSION-HARD-GUARDS.md`
2. `.codex/session-state.json`
3. `.codex/handoff.md`
4. `.codex/engineering-standards.md`
5. `.codex/native-tasklist.json`
6. `.codex/agent-workflow-skill-foundation-audit.json`

## Required Behavior

- Treat `.codex/native-tasklist.json` as the execution queue shared with Codex.
- Treat `.codex/agent-workflow-skill-foundation-audit.json` as the blocker and audit mirror shared with Codex.
- Update both files together whenever a `codex_only` task or blocker status changes.
- Do not bypass `.claude/settings.json` project hooks.
- Do not claim completion if the validator suite fails or the status files are out of sync.

## Control Boundary

- Use repository-root runtime files as runtime truth.
- Use `.codex/` and `Xuanzhi-Dev/` for client control, audit, and validation logic.
- Keep `CLAUDE.md`, `AGENTS.md`, and `.claude/settings.json` aligned.
