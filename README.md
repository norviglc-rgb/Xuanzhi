# Xuanzhi

Xuanzhi is currently a real OpenClaw runtime repository with a separate development area for specs, migration notes, and generated examples.

## Runtime Surface In Use

These paths exist at the repository root and reflect the current runtime shape:

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

The current workspace convention is `workspace-<agentId>` at the root of `~/.openclaw/`, matching `openclaw.json`. This repository does not currently use `workspaces/workspace-<agentId>/`.

## What Each Module Does

- `openclaw.json`: runtime agent registry, workspace paths, sandbox/tool controls, hooks, cron
- `agents/`: per-agent runtime-owned state and session directories
- `hooks/`: startup and guardrail checks such as workspace integrity and ops action auditing
- `skills/`: machine-readable control and placement rules
- `workspace-orchestrator/`: routing, delegation, and convergence
- `workspace-critic/`: review gate and risk checking
- `workspace-architect/`: requirement understanding, solution shaping, and handoff for complex coding
- `workspace-ops/`: executes allowed operational actions and runs agent/user provisioning workflows
- `workspace-skills-smith/`: skill design and maintenance
- `workspace-agent-smith/`: agent creation logic, agent scaffolding rules, schemas, and workflow maintenance
- `workspace-claude-code/`: long-running complex coding execution domain
- `Xuanzhi-Dev/`: development-only materials, including specs, legacy migration candidates, references, and generated samples

## Source Of Truth Status

Current runtime truth lives at the repository root in the files and folders listed above.

`Xuanzhi-Dev/legacy-root/` is not active runtime truth today. It is a migration source containing candidate docs, schemas, workflows, templates, and state files that still need selective promotion.

`Xuanzhi-Dev/generated/` is generated output and examples, not authoritative runtime state.

## Design Direction

- Keep templates generic. Do not maintain a separate `core-agent` template family.
- `agent-smith` should define how agents are created and what files they need.
- `ops` should execute agent creation and user creation workflows in runtime.
- Prefer fewer moving parts over speculative structure. If a path or module is not running today, document it as planned or legacy, not as current truth.

## Runtime Root Sync

To reduce drift between this repository and the local runtime root (`~/.openclaw`), use:

- Dry-run preview: `powershell -ExecutionPolicy Bypass -File scripts/sync-runtime-root.ps1`
- Apply sync: `powershell -ExecutionPolicy Bypass -File scripts/sync-runtime-root.ps1 -Apply`
- Include `agents/` state too: add `-IncludeAgentsState`
