# M3 Agent Provisioning Boundary (Ops)

## Status

- milestone: `m3`
- step: `s1`
- status: active draft

## Purpose

Define the execution boundary for `ops` when provisioning a generic agent in runtime, based on m2 contract artifacts.

This document focuses on how `ops` consumes (not redefines) the outputs of:

- `agent-creation-contract.md` (`m2/s2`)
- `agent-contract-validation-and-rollback.md` (`m2/s3`)

## Scope

Applies to generic agent provisioning in current runtime shape at repository root (`openclaw.json`, `agents/`, `workspace-<agentId>/`).

Does not cover:

- daily-user provisioning flow
- template ownership changes
- contract/schema/workflow ownership transfer away from `agent-smith`
- final acceptance authority override (`critic` / main agent responsibilities)

## 1. Upstream Contract Inputs Consumed By Ops

`ops` treats m2 artifacts as source constraints and consumes the following input package.

### 1.1 Provisioning Request Inputs

- `agentId`: stable kebab-case id
- `workspace`: must resolve to `workspace-<agentId>`
- `agentDir`: must resolve to `agents/<agentId>/agent`
- `tools.allow`: explicit allow list
- `tools.deny`: explicit deny list
- optional `sandbox` override (only when explicitly required)
- role description / role constraints (for human-readable workspace files)

### 1.2 Contract Inputs (Normative)

- minimum required root files:
  - `AGENTS.md`
  - `SOUL.md`
  - `IDENTITY.md`
  - `TOOLS.md`
  - `BOOT.md`
  - `BOOTSTRAP.md`
  - `HEARTBEAT.md`
  - `MEMORY.md`
- minimum required directories:
  - `memory/`
  - `skills/`
  - `hooks/`
  - `docs/`
- runtime-owned directories:
  - `agents/<agentId>/agent/`
  - `agents/<agentId>/sessions/`

### 1.3 Validation And Rollback Inputs

- m2 acceptance checks (structure, registry, boundary)
- rollback trigger conditions
- rollback scope and post-rollback invariants

`ops` must execute against these checks instead of inventing ad-hoc success criteria.

## 2. Ops Execution Outputs

When provisioning succeeds, `ops` produces these outputs.

### 2.1 Runtime Filesystem Outputs

- created `workspace-<agentId>/` with all required root files and directories
- created runtime directories:
  - `agents/<agentId>/agent/`
  - `agents/<agentId>/sessions/`

### 2.2 Runtime Registry Output

- `openclaw.json` contains a consistent agent entry where:
  - `id == <agentId>`
  - `workspace == workspace-<agentId>`
  - `agentDir == agents/<agentId>/agent`
  - `tools.allow` exists
  - `tools.deny` exists

### 2.3 Audit/Lifecycle Outputs

Per `workspace-ops` role definition, `ops` must leave a traceable execution chain:

- action execution record (what was provisioned, with which contract inputs)
- acceptance check result record
- failure/rollback record when applicable

Exact storage format can evolve, but absence of auditable trail is out of boundary.

## 3. Hard Dependencies For Ops Provisioning

`ops` execution depends on:

- current runtime truth at repo root (`README.md`):
  - `openclaw.json`
  - root-level `workspace-<agentId>` convention
  - root-level `agents/` runtime state
- role constraints in `workspace-ops/AGENTS.md`:
  - executes provisioning workflows
  - keeps audit chain intact
  - does not claim template/architecture ownership
- tool constraints in `workspace-ops/TOOLS.md`:
  - use allowlisted ops actions
  - prioritize state/policy/schema/workflow before mutation
  - update state/audit artifacts after actions

If these dependencies are missing or contradictory, `ops` must escalate or stop instead of guessing.

## 4. Handoff Boundary (Agent-Smith -> Ops)

### 4.1 What Must Be Handed To Ops

- contract definition and required output surface (m2/s2)
- validation and rollback rules (m2/s3)
- concrete agent provisioning input payload (`agentId`, registry fields, constraints)
- acceptance checklist reference used for go/no-go

### 4.2 What Ops Owns After Handoff

- execute provisioning actions in runtime
- apply contract constraints exactly
- run acceptance checks from m2 rules
- perform rollback on failure conditions
- emit audit/lifecycle records

### 4.3 What Ops Must Not Own

- changing minimum scaffold definition
- redefining naming rules or ownership boundaries
- broadening generic contract with role-specific assumptions
- introducing deprecated paths such as `workspaces/workspace-<agentId>/`
- reintroducing `templates/core-agent/*` as a generic dependency

## 5. Failure And Rollback Boundary

When any m2 rollback trigger is hit, `ops` must:

1. stop forward provisioning actions
2. remove partial outputs in rollback scope
3. revert partial registry mutation for failed agent
4. preserve diagnostic/audit evidence of the failed attempt
5. ensure retry safety for same `agentId`

No failed attempt may leave the agent appearing active in runtime truth.

## 6. Completion Contract For M3/S1

For this step, provisioning boundary definition is complete when:

- ops input/output/dependency/handoff boundaries are explicit and testable
- m2 contract consumption rules are explicit
- ownership separation (`agent-smith` vs `ops` vs review roles) is preserved
- runtime path conventions match current root runtime shape from `README.md`
