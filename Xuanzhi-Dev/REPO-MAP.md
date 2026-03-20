# Xuanzhi Repo Map

## Current Layout

```text
D:\Xuanzhi\
├── agents/           # ~/.openclaw/agents/
├── architect/        # ~/.openclaw/architect/
├── audit/            # ~/.openclaw/audit/
├── docs/             # ~/.openclaw/docs/
├── ops/              # ~/.openclaw/ops/
├── policies/         # ~/.openclaw/policies/
├── review/           # ~/.openclaw/review/
├── schemas/          # ~/.openclaw/schemas/
├── skills/           # ~/.openclaw/skills/
├── state/            # ~/.openclaw/state/
├── templates/        # ~/.openclaw/templates/
├── workflows/        # ~/.openclaw/workflows/
├── workspaces/       # ~/.openclaw/workspaces/
└── Xuanzhi-Dev/      # development docs, references, and historical outputs
```

## Runtime Package

The repository root is the runtime package. Users can replace their `~/.openclaw/` with this directory directly.

Key runtime paths:

- `docs/system/` - system source of truth
- `policies/` - policy JSON files
- `schemas/` - JSON schemas
- `workflows/` - machine-readable workflows
- `templates/` - workspace templates
- `state/` - live runtime state
- `audit/` - runtime audit logs
- `workspaces/` - pre-materialized core workspaces
- `agents/` - per-agent runtime directories

## Development Materials

Development-only materials are isolated under `Xuanzhi-Dev/`:

- `Xuanzhi-Dev/spec/`
- `Xuanzhi-Dev/reference/`
- `Xuanzhi-Dev/generated/`

## Quick Navigation

- Architecture: `docs/system/ARCHITECTURE.md`
- Governance: `docs/system/GOVERNANCE.md`
- Core workflow: `workflows/system/materialize-core-agents.json`
- Daily user workflow: `workflows/users/create-daily-user.json`
- Requirements: `Xuanzhi-Dev/spec/requirements/open_claw多agent系统v1需求规格.md`
- Bring-up order: `Xuanzhi-Dev/spec/bringup/BRING-UP-ORDER.md`
