# M2 Agent Contract Draft

## Stage

- milestone: `m2`
- step: `s1`
- status: draft

## Purpose

Define the current input/output boundary for generic agent creation based on active runtime facts.

This draft is intentionally aligned with the repository as it exists today.

## 1. Creation Intent

`agent-smith` owns the creation contract.

That means:

- defining what a new agent is
- defining what minimum runtime artifacts it must have
- defining what `ops` needs in order to execute provisioning later

`ops` does not define the contract.

`ops` executes the contract in runtime.

## 2. Minimum Required Inputs

These are the strongest currently-supported required inputs for creating a new agent entry:

| field | required | reason |
|---|---|---|
| `id` | yes | core agent identifier; names workspace and runtime directory |
| `workspace` | yes | explicit runtime workspace path recorded in `openclaw.json` |
| `agentDir` | yes | explicit runtime agent directory recorded in `openclaw.json` |
| `tools.allow` | yes | current hard permission boundary is defined per agent in `openclaw.json` |
| `tools.deny` | yes | current hard permission boundary is defined per agent in `openclaw.json` |

## 3. Optional Or Conditional Inputs

These are not currently mandatory for every new agent:

| field | status | note |
|---|---|---|
| `sandbox` | optional override | defaults exist in `openclaw.json`; only special agents may override |
| role description text | recommended | needed for generated workspace content, but not yet machine-constrained |
| behavior text | recommended | useful for `AGENTS.md`, `SOUL.md`, `TOOLS.md`, but not yet formalized as schema |
| extra local directories | optional | role-specific, not part of the generic minimum set |

## 4. Minimum Required Outputs

A newly created generic agent should produce the following minimum workspace output:

### Workspace root

- `workspace-<agentId>/`

### Required root files

- `AGENTS.md`
- `SOUL.md`
- `IDENTITY.md`
- `TOOLS.md`
- `BOOT.md`
- `BOOTSTRAP.md`
- `HEARTBEAT.md`
- `MEMORY.md`

### Required directories

- `memory/`
- `skills/`
- `hooks/`
- `docs/`

### Runtime-owned companion path

- `agents/<agentId>/agent/`
- `agents/<agentId>/sessions/`

## 5. What Is Not In The Generic Minimum Set

These should not be treated as part of the generic minimum contract:

- `templates/core-agent/*`
- `workspaces/workspace-<agentId>/`
- root-level `docs/`, `policies/`, `schemas/`, `workflows/`, `state/`, `templates/` as already-active runtime truth
- role-specific extra docs under `docs/`
- a `templates/` directory inside every created agent workspace

## 6. Ownership Boundary

### `agent-smith`

Owns:

- creation contract definition
- scaffolding rules
- file and directory minimum set
- naming rules
- schema and workflow definitions for creation
- acceptance surface for what a valid created agent looks like

Does not own:

- runtime provisioning execution
- lifecycle actions after creation
- deployment or operational rollout

### `ops`

Owns:

- executing the provisioning workflow
- creating workspace and runtime directories
- writing runtime-facing registration and audit outputs
- performing allowed lifecycle actions after creation

Does not own:

- changing the creation contract itself
- redefining schema/workflow ownership
- redefining the agent structure model

## 7. Suggested Hand-off Package

`agent-smith -> ops` should hand off a creation package containing:

1. contract definition
2. scaffold output specification
3. required registration targets
4. required audit targets
5. acceptance checklist
6. rollback expectations

## 8. Current Gaps

These still need to be formalized in later `m2` steps:

- how to express role text in a reusable way
- whether to keep workspace-local templates under `workspace-agent-smith/templates/`
- how the contract is represented: markdown only, JSON contract, or both
- what exact registration/audit targets are required before `m3`

## 9. Immediate Use

This draft is sufficient to move into:

- `s2`: formal contract definition
- `s3`: rollback and acceptance rules
- `s4`: minimal execution proof
