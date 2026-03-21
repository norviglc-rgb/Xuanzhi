# Xuanzhi Repo Map

## Current Repository Layout

```text
D:\Xuanzhi\
|- .claude/
|- .codex/
|- hooks/
|- policies/
|- schemas/
|- skills/
|- state/
|- workflows/
|- workspace-agent-smith/
|- workspace-architect/
|- workspace-claude-code/
|- workspace-critic/
|- workspace-ops/
|- workspace-orchestrator/
|- workspace-skills-smith/
|- Xuanzhi-Dev/
|- openclaw.json
|- README.md
```

## Runtime Vs Development

Repository root:

- Active OpenClaw runtime surface
- Agent workspaces
- Runtime hooks and skills
- Runtime policy, schema, workflow, and state files

`.codex/`:

- Codex working state
- Codex development and audit standards
- Session handoff and worklog
- Codex-only reference notes such as `docs-system/`

`Xuanzhi-Dev/`:

- `spec/`: requirements, bring-up notes, migration notes, plans
- `reference/`: reference material only
- `REPO-MAP.md`: development-side repository map

## Current Path Facts

- Current agent workspaces live at `workspace-<agentId>/`
- `openclaw.json` is the active registry for agent ids, workspace paths, and hard controls
- Active runtime policy lives under `policies/`
- Active runtime schema lives under `schemas/`
- Active runtime state lives under `state/`
- Active runtime workflows live under `workflows/`
- System explanation material previously placed under `docs/system/` has been moved into `.codex/docs-system/` as Codex-side reference, not runtime truth

This means old documents that still describe:

- `agents/<agentId>/agent`
- `credentials/`
- `cron/`
- `logs/`
- `generated/`
- `legacy-root/`
- root-level `docs/system/`

are describing an earlier repository shape or a historical draft, not the current repository state.

## Module Responsibilities

- `orchestrator`: route tasks and converge outcomes
- `critic`: review gate, risk checks, and signoff
- `architect`: shape implementation approach and prepare complex-task handoff
- `ops`: execute operational actions and lifecycle operations
- `skills-smith`: create and maintain skills
- `agent-smith`: define and evolve agent creation rules, scaffolds, schemas, and workflows
- `claude-code`: complex coding execution domain

## Working Rules

- Runtime truth belongs at repository root in `openclaw.json`, `policies/`, `schemas/`, `state/`, `workflows/`, `hooks/`, `skills/`, and `workspace-*`
- Codex working standards and session continuity belong in `.codex/`
- Development documentation and reference material belong in `Xuanzhi-Dev/`
- Do not treat `.codex/` or `Xuanzhi-Dev/` as runtime truth unless a root runtime file explicitly points there
