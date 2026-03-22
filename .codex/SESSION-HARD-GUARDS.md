# Session Hard Guards

This file is Codex-only and must not be copied into Xuanzhi runtime paths.

## Always-First Rule
Before any implementation in a new session (including very long-context sessions), run:

```powershell
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-native-tasklist.ps1
powershell -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/validate-execution-guardrails.ps1
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

## Scope Boundary
- Codex execution constraints may only live in `.codex` and `Xuanzhi-Dev`.
- Do not add Codex-only policies into runtime roots (`openclaw.json`, `policies/`, `workflows/`, `hooks/`, `schemas/`, `state/`, `skills/`, `workspace-*`, `agents/`).
