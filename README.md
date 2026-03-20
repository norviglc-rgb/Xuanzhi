# Xuanzhi

This repository is now shaped around official OpenClaw runtime concepts.

## Runtime roots to keep

- `openclaw.json`
- `agents/`
- `credentials/`
- `cron/`
- `hooks/`
- `logs/`
- `skills/`
- `workspace-orchestrator/`
- `workspace-critic/`
- `workspace-architect/`
- `workspace-ops/`
- `workspace-skills-smith/`
- `workspace-agent-smith/`
- `workspace-claude-code/`

## Strong controls

Hard controls live in:

- `openclaw.json` per-agent tool allow/deny
- `openclaw.json` sandbox settings
- `hooks/workspace-integrity/`
- `hooks/ops-action-guard/`
- `logs/`

Soft controls live in workspace files:

- `AGENTS.md`
- `BOOT.md`
- `HEARTBEAT.md`
- `MEMORY.md`

## Workflow placement

Machine-readable placement rules live in:

- `skills/xuanzhi-control/control-model.json`
- `skills/xuanzhi-control/workflow-placement.json`

Decision baseline:

- OpenClaw: host execution, routing, cron, hooks, credentials, local audit
- NocoBase: approval, forms, durable business state, queues, dashboards
- FastGPT: RAG-heavy and LLM-only subflows

## Development materials

`Xuanzhi-Dev/` is temporary development storage only.
Runtime should continue collapsing toward official OpenClaw roots, not toward custom top-level runtime directories.
