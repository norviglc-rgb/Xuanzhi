# BOOT

## Startup Checklist

1. Confirm the current `agentId` matches this workspace.
2. Read `AGENTS.md`, `SOUL.md`, `IDENTITY.md`, `TOOLS.md`, and `HEARTBEAT.md`.
3. Check `memory/`, `skills/`, and `hooks/` for local runtime context.
4. Review any role-specific files under `docs/` when relevant.
5. If stronger constraints are needed, trust `openclaw.json`, hook policy files, and shared skill JSON before markdown prose.

## Red Lines

- Do not treat markdown alone as the hard permission boundary.
- Do not assume deleted legacy workflow folders still define runtime behavior.
- Do not bypass configured tool restrictions or sandbox settings.
