# M3 Generic Agent Provisioning Execution (Ops)

## Status

- milestone: `m3`
- step: `s2`
- status: active draft

## Purpose

Define an executable `ops` runbook for provisioning a generic (non-daily) agent in the current root-level runtime shape.

This document executes constraints from:

- `agent-creation-contract.md`
- `agent-contract-validation-and-rollback.md`
- `m3-agent-provisioning-boundary.md`

This document intentionally does not define state/audit/review storage details; those belong to `m3/s3`.

## 1. Preconditions (Must Pass Before Execution)

1. Runtime root exists and is writable:
   - `openclaw.json`
   - `agents/`
2. Target ids/paths are not deprecated:
   - workspace must be `workspace-<agentId>/`
   - runtime path must be `agents/<agentId>/agent/`
3. Provisioning request package is complete:
   - `agentId`
   - `workspace`
   - `agentDir`
   - `tools.allow`
   - `tools.deny`
4. `ops` is operating within allowlisted action boundaries and does not redefine contract ownership.
5. No conflicting active registration already exists for the same `agentId`.

If any precondition fails, stop and escalate instead of guessing.

## 2. Input Package (Consumed By Ops)

`ops` consumes a handoff package from `agent-smith` and runtime request context.

Required input fields:

- `agentId` (stable kebab-case)
- `workspace` (`workspace-<agentId>`)
- `agentDir` (`agents/<agentId>/agent`)
- `tools.allow`
- `tools.deny`

Optional input fields:

- `sandbox` override (only when explicitly required)
- role description and role constraints used to generate human-facing workspace docs

Contract attachments (normative):

- required root files list:
  - `AGENTS.md`
  - `SOUL.md`
  - `IDENTITY.md`
  - `TOOLS.md`
  - `BOOT.md`
  - `BOOTSTRAP.md`
  - `HEARTBEAT.md`
  - `MEMORY.md`
- required directories list:
  - `memory/`
  - `skills/`
  - `hooks/`
  - `docs/`
- rollback triggers, rollback scope, and acceptance checks from m2 documents

## 3. Execution Steps (Owned By Ops)

### Step 0: Resolve And Validate Inputs

`ops` must:

1. parse the request package
2. compute expected paths from `agentId`
3. confirm request paths match computed paths
4. confirm required tool boundaries are present

Stop if mismatched `id/workspace/agentDir` is detected.

### Step 1: Create Workspace Skeleton

`ops` must:

1. create `workspace-<agentId>/`
2. create required root files
3. create required directories (`memory/`, `skills/`, `hooks/`, `docs/`)

Do not introduce deprecated or extra mandatory paths such as:

- `workspaces/workspace-<agentId>/`
- `templates/core-agent/*`

### Step 2: Create Runtime-Owned Directories

`ops` must:

1. create `agents/<agentId>/agent/`
2. create `agents/<agentId>/sessions/`

If partial creation occurs, treat as failure and enter rollback handling.

### Step 3: Apply Runtime Registration

`ops` must update `openclaw.json` with a consistent agent entry:

- `id == <agentId>`
- `workspace == workspace-<agentId>`
- `agentDir == agents/<agentId>/agent`
- `tools.allow` present
- `tools.deny` present

If registration write fails or becomes inconsistent, enter rollback handling.

### Step 4: Run Local Acceptance Checks

Before handoff, `ops` must execute m2 minimum checks:

1. structure checks for required files and directories
2. runtime directory checks under `agents/<agentId>/...`
3. registry checks in `openclaw.json`
4. boundary checks (no deprecated path model, no forbidden dependency model)

If any check fails, do not continue to critic handoff.

## 4. Failure Handling (Ops-Owned)

When a blocking failure or rollback trigger occurs, `ops` must:

1. stop forward provisioning immediately
2. remove partial `workspace-<agentId>/` outputs from the failed attempt
3. remove partial `agents/<agentId>/agent/` and `agents/<agentId>/sessions/`
4. revert partial `openclaw.json` mutation for this `agentId`
5. preserve diagnostic evidence for retry analysis
6. leave the system retry-safe for the same `agentId`

Post-rollback invariant: failed agent must not appear as provisioned in runtime truth.

## 5. Pre-Critic Self-Check (Ops Gate)

Before sending outputs to `critic`, `ops` must confirm all are true:

1. workspace and runtime directories exist and are complete
2. all required root files and directories exist
3. `openclaw.json` entry is present and consistent
4. no deprecated path model was introduced
5. no rollback trigger remains active

If any item is false, return to failure handling instead of requesting review.

## 6. Responsibility Boundary Summary

Steps owned by `ops` in this runbook:

1. precondition checks
2. input validation
3. filesystem materialization
4. runtime directory materialization
5. registry update
6. local acceptance checks
7. rollback execution when needed
8. pre-critic self-check gate

Not owned by `ops` in this step:

- redefining contract/scaffold ownership
- final review decision (`critic`)
- m3/s3 storage details for state/audit/review artifacts

