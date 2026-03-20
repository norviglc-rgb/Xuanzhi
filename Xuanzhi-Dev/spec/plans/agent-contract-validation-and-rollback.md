# Agent Contract Validation And Rollback

## Status

- milestone: `m2`
- step: `s3`
- status: active draft

## Purpose

Define the minimum rollback and acceptance rules for generic agent creation under the current runtime model.

This document extends `agent-creation-contract.md`.

## 1. Trigger Points

Rollback should be considered when any of the following happens during agent creation:

1. required workspace root files are missing
2. required workspace directories are missing
3. runtime directory creation is incomplete
4. `openclaw.json` registration is missing, malformed, or inconsistent with created paths
5. tool boundary fields are missing or contradictory
6. acceptance review finds the created agent unusable or structurally invalid

## 2. Rollback Scope

### Must Roll Back

If creation fails before acceptance, the following should be removed or reverted:

- incomplete `workspace-<agentId>/` output created by the failed attempt
- incomplete `agents/<agentId>/agent/` directory
- incomplete `agents/<agentId>/sessions/` directory
- partial `openclaw.json` agent entry for the failed agent
- partial registration artifacts created only for that failed agent

### May Be Preserved

These may be kept for diagnosis if clearly marked as failed attempt artifacts:

- debug notes
- failure reports
- review notes
- explicit failed-attempt audit records

## 3. Post-Rollback State

After rollback:

- no active runtime path should still present the failed agent as provisioned
- no partial agent entry should remain in the runtime registry
- the failure should still be traceable through notes or audit where appropriate
- the system should be safe to retry the same `agentId`

## 4. Minimum Acceptance Checks

### Structure Checks

- `workspace-<agentId>/` exists
- required root files exist:
  - `AGENTS.md`
  - `SOUL.md`
  - `IDENTITY.md`
  - `TOOLS.md`
  - `BOOT.md`
  - `BOOTSTRAP.md`
  - `HEARTBEAT.md`
  - `MEMORY.md`
- required directories exist:
  - `memory/`
  - `skills/`
  - `hooks/`
  - `docs/`
- `agents/<agentId>/agent/` exists
- `agents/<agentId>/sessions/` exists

### Registry Checks

- `openclaw.json` contains the new agent entry
- `id` matches the created workspace and runtime directory names
- `workspace` matches `workspace-<agentId>`
- `agentDir` matches `agents/<agentId>/agent`
- `tools.allow` exists
- `tools.deny` exists

### Boundary Checks

- no deprecated `workspaces/workspace-<agentId>` path is introduced
- no `templates/core-agent/*` dependency is introduced into the generic contract
- no unexpected role-specific structure is treated as generic minimum output

## 5. Review Sequence

Suggested sequence:

1. `agent-smith` defines the contract
2. `ops` executes or simulates creation against the contract
3. `critic` checks acceptance and structural validity
4. if review fails, the issue returns to rework before milestone close

## 6. Recommended Reviewer Ownership

| check_type | primary_owner | reason |
|---|---|---|
| contract correctness | agent-smith | owns contract definition |
| runtime execution correctness | ops | owns execution responsibility |
| acceptance/signoff | critic | owns quality and risk review |
| final milestone judgment | main agent | owns integration and stage closure |

## 7. Blocking vs Non-Blocking Issues

### Blocking

- missing required files or directories
- invalid runtime paths
- inconsistent `id`, `workspace`, and `agentDir`
- missing permission boundaries
- creation result cannot be retried safely

### Non-Blocking

- optional role-specific docs not yet added
- future registration/audit details not yet formalized for `m3`
- diagnostics that are present but not yet standardized

## 8. Next Use

Use this document as the basis for:

- `s4` minimal execution proof
- `s5` m2 verification and review
- later `ops` provisioning work in `m3`
