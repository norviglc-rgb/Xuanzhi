# Agent-Smith Daily User Materialization

Purpose:
- Materialize a daily-user agent runtime and workspace owned by `agent-smith`.
- Keep provisioning artifacts aligned with `workflows/users/create-daily-user.json`.

Inputs:
- `requestId`
- `userId`
- `displayName`
- `persona`
- `bindings`

Outputs:
- `materializationReport` with:
- `workspaceId`
- `agentId`
- `status` (`ready` when successful)
- `artifacts`

Required artifacts:
- `workspace-daily-<userId>/AGENTS.md`
- `workspace-daily-<userId>/SOUL.md`
- `workspace-daily-<userId>/USER.md`
- `workspace-daily-<userId>/IDENTITY.md`
- `workspace-daily-<userId>/TOOLS.md`
- `workspace-daily-<userId>/HEARTBEAT.md`
- `workspace-daily-<userId>/BOOT.md`
- `workspace-daily-<userId>/BOOTSTRAP.md`
- `workspace-daily-<userId>/MEMORY.md`

Rules:
- Follow naming rules in `docs/system/FILE-NAMING.md`.
- Keep output profile valid against `schemas/user-profile.schema.json`.
- Do not bypass review-gate flow.
