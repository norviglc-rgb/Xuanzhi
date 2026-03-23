# AGENTS.md

This repository uses a shared machine-readable control plane for both Codex and Claude Code.

## Always-First

Before implementation or any write action, run:

```powershell
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/invoke-session-hard-guards.ps1
```

If any validator fails, stop and fix the control plane or runtime violations first.

## Official Control Sources

Read these files in order at the start of every session:

1. `.codex/SESSION-HARD-GUARDS.md`
2. `.codex/session-state.json`
3. `.codex/handoff.md`
4. `.codex/engineering-standards.md`
5. `.codex/native-tasklist.json`
6. `.codex/agent-workflow-skill-foundation-audit.json`

## Required Behavior

- Treat `.codex/native-tasklist.json` as the machine-readable execution queue.
- Treat `.codex/agent-workflow-skill-foundation-audit.json` as the machine-readable audit and blocker mirror.
- For any `codex_only` task or blocker status change, update both files in the same work unit.
- Do not claim completion unless the hard guards pass and the status files are synchronized.

## Runtime Boundary

- Codex-only execution rules belong in `.codex/` and `Xuanzhi-Dev/`.
- Runtime truth belongs in repository-root runtime files such as `openclaw.json`, `policies/`, `workflows/`, `schemas/`, `state/`, `hooks/`, `skills/`, and `workspace-*`.
- Do not move Codex-only control rules into runtime roots unless the runtime truly reads them.

## Multi-Client Discipline

- Keep this file aligned with `CLAUDE.md` and `.claude/settings.json`.
- Claude Code hooks and Codex startup instructions must point at the same validators and status sources.
- If they drift, fix the control plane before continuing implementation.
