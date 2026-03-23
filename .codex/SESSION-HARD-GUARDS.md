# Session Hard Guards

This file is Codex-only and must not be copied into Xuanzhi runtime paths.

## Always-First Rule
Before any implementation in a new session (including very long-context sessions), run:

```powershell
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-native-tasklist.ps1
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-execution-guardrails.ps1
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-agent-workflow-skill-foundation.ps1
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-codex-session-foundation.ps1
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-client-control-plane.ps1
```

If the command fails, stop implementation and fix violations first.

## Hard Guards
1. Path Guard
- No new repository-root files.
- Test-related files must stay under `Xuanzhi-Dev/testing/`.
- No empty new files.

2. Verification Guard
- You cannot close a task with smoke-only evidence.
- If smoke markers appear in a report, real execution evidence must also appear.

3. Report Guard
- Final report must include exactly these sections in plain language:
- `功能影响`
- `验证证据`
- `未完成项`

4. Foundation Guard
- Production ownership and foundation contracts must stay machine-readable and aligned:
- `policies/routing-policy.json` ownership/closure routes
- `workflows/users/create-daily-user.json` owner + invoke_skill contract
- `skills/agent-smith-daily-user-materialization/*` package contract
- `state/skills/catalog.json` registration

5. Codex Session Guard
- `.codex` session bootstrap files must stay aligned for low-context / lower-quality models:
- resume order must require `SESSION-HARD-GUARDS.md`, `session-state.json`, `handoff.md`, `engineering-standards.md`, `native-tasklist.json`, `agent-workflow-skill-foundation-audit.json`
- `.codex/native-tasklist.json` and `.codex/agent-workflow-skill-foundation-audit.json` task state must mirror for codex-owned work
- the hard-guard doc, native tasklist, and audit enforcement order must all include the same validator set

6. Client Control Guard
- Official Codex and Claude Code project entrypoints must stay aligned with the shared control plane:
- root `AGENTS.md` must point Codex to the shared validator suite and `.codex` status files
- root `CLAUDE.md` and `.claude/settings.json` must point Claude Code to the same validator suite and `.codex` status files
- both clients must use the same progress-sync source files and must not maintain separate task truth

## Scope Boundary
- Codex execution constraints may only live in `.codex` and `Xuanzhi-Dev`.
- Do not add Codex-only policies into runtime roots (`openclaw.json`, `policies/`, `workflows/`, `hooks/`, `schemas/`, `state/`, `skills/`, `workspace-*`, `agents/`).
