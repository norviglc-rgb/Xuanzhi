# Agent Creation Contract

## Status

- milestone: `m2`
- step: `s2`
- status: active draft

## Purpose

Define the minimum generic contract for creating a new non-daily agent in the current Xuanzhi runtime.

This contract is owned by `agent-smith` and is intended to be executed later by `ops`.

## 1. Contract Intent

The contract exists to answer four questions clearly:

1. what inputs define a new agent
2. what minimum outputs must be created
3. what boundary exists between `agent-smith` and `ops`
4. what later validation and rollback rules must attach to creation

## 2. Scope

This contract applies to generic agent creation for the current runtime shape.

It does not yet define:

- daily-user creation
- full runtime state registration format
- final review record structure
- role-specific optional files beyond the generic minimum

## 3. Required Inputs

### Registry Inputs

The following inputs are required to register a new agent in the current runtime model:

| field | required | rule |
|---|---|---|
| `id` | yes | unique agent id |
| `workspace` | yes | must follow `workspace-<agentId>` |
| `agentDir` | yes | must follow `agents/<agentId>/agent` |
| `tools.allow` | yes | explicit allow list in `openclaw.json` |
| `tools.deny` | yes | explicit deny list in `openclaw.json` |

### Optional Inputs

| field | status | rule |
|---|---|---|
| `sandbox` | optional override | omit unless agent needs non-default sandbox behavior |
| role description | recommended | used to generate human-readable workspace files |
| role constraints | recommended | used in `AGENTS.md` and `TOOLS.md` |
| extra local directories | optional | only when justified by role behavior |

## 4. Naming Rules

- agent id should be stable and kebab-case
- workspace path must be `workspace-<agentId>/`
- runtime directory must be `agents/<agentId>/agent/`
- session directory must be `agents/<agentId>/sessions/`

## 5. Minimum Required Outputs

### Workspace Root

- `workspace-<agentId>/`

### Required Root Files

- `AGENTS.md`
- `SOUL.md`
- `IDENTITY.md`
- `TOOLS.md`
- `BOOT.md`
- `BOOTSTRAP.md`
- `HEARTBEAT.md`
- `MEMORY.md`

### Required Directories

- `memory/`
- `skills/`
- `hooks/`
- `docs/`

### Runtime-Owned Directories

- `agents/<agentId>/agent/`
- `agents/<agentId>/sessions/`

## 6. Explicit Non-Requirements

The generic contract does not require:

- `templates/core-agent/*`
- `workspaces/workspace-<agentId>/`
- a `templates/` directory in every new agent workspace
- role-specific extra docs by default
- root-level `docs/`, `policies/`, `schemas/`, `workflows/`, `state/`, `templates/` to already exist as active runtime truth

## 7. Ownership Boundary

### `agent-smith` Owns

- contract definition
- naming rules
- scaffold structure
- minimum files and directories
- schema/workflow definitions for creation
- acceptance surface definition

### `agent-smith` Does Not Own

- provisioning execution
- runtime lifecycle execution
- deployment
- post-create operational actions

### `ops` Owns

- contract execution
- directory creation
- runtime registration actions
- audit and lifecycle actions

### `ops` Does Not Own

- changing the contract itself
- redefining the scaffold model
- redefining ownership boundaries

## 8. Hand-off Package

The `agent-smith -> ops` hand-off should minimally contain:

1. this contract
2. scaffold output specification
3. registration targets to be written by `ops`
4. audit targets to be written by `ops`
5. acceptance checklist
6. rollback expectations

## 9. Open Items For Next Step

These remain to be formalized in `s3`:

- exact rollback behavior
- exact acceptance checks
- exact registration targets
- exact audit targets
- whether a JSON representation is needed in addition to markdown

## 10. Use Rule

Use this contract as the baseline for:

- rollback and acceptance design in `s3`
- minimal execution proof in `s4`
- later provisioning design in `m3`
