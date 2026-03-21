# Xuanzhi Repo Map

## Current Repository Layout

```text
D:\Xuanzhi\
|- agents/
|- credentials/
|- cron/
|- hooks/
|- logs/
|- skills/
|- workspace-agent-smith/
|- workspace-architect/
|- workspace-claude-code/
|- workspace-critic/
|- workspace-ops/
|- workspace-orchestrator/
|- workspace-skills-smith/
|- Xuanzhi-Dev/
|- openclaw.json
|- openclaw.json.example
|- README.md
|- README-runtime.md
```

## Runtime Vs Development

Repository root:

- Active OpenClaw runtime surface
- Agent workspaces
- Runtime hooks and skills
- Agent runtime directories

`Xuanzhi-Dev/`:

- `spec/`: requirements, bring-up notes, migration notes
- `legacy-root/`: candidate system docs, schemas, workflows, templates, and state not yet promoted into runtime root
- `generated/`: generated examples and audit samples
- `reference/`: reference material only

## Current Path Facts

- Current agent workspaces live at `workspace-<agentId>/`
- Current agent runtime directories live at `agents/<agentId>/agent` and `agents/<agentId>/sessions`
- `openclaw.json` is the active registry for agent ids, workspace paths, and hard controls
- Root-level `docs/`, `policies/`, `schemas/`, `state/`, `templates/`, and `workflows/` do not exist yet in the active runtime tree

This means older documents that describe `workspaces/workspace-<agentId>/` or a fully promoted root-level `docs/policies/workflows/state/templates` tree are describing a target or a legacy draft, not the current repository state.

## Module Responsibilities

- `orchestrator`: route tasks and converge outcomes
- `critic`: review gate, risk checks, and signoff
- `architect`: shape implementation approach and prepare complex-task handoff
- `ops`: execute operational actions and run provisioning workflows for agents and users
- `skills-smith`: create and maintain skills
- `agent-smith`: define and evolve agent creation rules, agent scaffolds, schemas, and workflows
- `claude-code`: complex coding execution domain

## Template Direction

Current repository truth is workspace-first, not template-first.

If templates are promoted into the active runtime later, keep them generic:

- one agent template family for creating agents
- one daily-user template family for creating isolated user agents

Do not reintroduce a separate `templates/core-agent/` hierarchy unless runtime usage proves it is necessary.

## Migration Notes

The main migration gap is not workspace files. It is the system-level truth that still sits under `Xuanzhi-Dev/legacy-root/`.

Priority migration candidates:

- system docs
- schemas
- workflows
- state seeds
- provisioning contracts

Before promoting any of them, re-check path assumptions against the current runtime shape in `openclaw.json`.

