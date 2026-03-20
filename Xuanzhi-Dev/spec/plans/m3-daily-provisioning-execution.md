# M3 Daily-User Provisioning Execution (Ops)

## Status

- milestone: `m3`
- step: `s2`
- track: `daily-user`
- status: active draft

## Purpose

Define an executable daily-user provisioning procedure for `ops`, aligned with current runtime facts and the reviewed `m3/s1` boundary.

This document focuses on execution flow only. Detailed state/audit/review field design is deferred to `m3/s3`.

## Scope

Applies to provisioning one daily user instance in the active runtime shape at repository root.

Does not cover:

- redefining daily contract ownership (`agent-smith`)
- critic gate policy design details
- full state/audit schema details (handled in `s3`)
- legacy path models (`workspaces/...`) as runtime truth

## 1. Preconditions (Ops Must Check Before Execution)

`ops` executes only when all checks pass:

1. runtime truth is available at root:
   - `openclaw.json`
   - `agents/`
   - `workspace-ops/`
2. active path model is root-level `workspace-*` and `agents/*`
3. allowlist path guard for daily-user action is available and not contradictory
4. daily provisioning contract package from `agent-smith` is present
5. request payload is complete and internally consistent

If any precondition fails, stop and escalate instead of guessing.

## 2. Input Package (Execution-Time Inputs)

Minimum input package consumed by `ops`:

- `userId`
- derived workspace id: `workspace-daily-<userId>`
- derived runtime id: `daily-<userId>`
- runtime mapping target for `agents/daily-<userId>/...`
- tool boundaries:
  - `tools.allow`
  - `tools.deny`
- optional sandbox override (only when required)
- request metadata for traceability (request id, requester, timestamp)
- daily scaffold/contract + rollback triggers from upstream contract owner

Input validation rules:

- derived ids must be deterministic from `userId`
- no deprecated path usage
- required fields cannot be empty
- tool boundaries must be explicit

## 3. Execution Steps (Owned By Ops)

### Step 1: Validate Request And Derive Names

`ops` validates the input package and computes:

- workspace path: `workspace-daily-<userId>/`
- runtime path root: `agents/daily-<userId>/`

Stop on any mismatch between provided and derived naming.

### Step 2: Materialize Daily Workspace Skeleton

`ops` creates `workspace-daily-<userId>/` from the approved daily contract surface.

Requirements:

- create only within approved daily scope
- do not mutate unrelated workspaces
- do not invent role contract changes during execution

### Step 3: Materialize Runtime Daily Directory

`ops` creates runtime-owned daily directory surface under `agents/daily-<userId>/...` as required by the current contract.

Requirements:

- keep runtime path consistent with derived id
- avoid partial writes outside this daily instance scope

### Step 4: Register Daily Instance In Runtime Surface

`ops` writes/updates runtime registration for this daily instance in the active registration surface.

Registration must be consistent across:

- `userId`
- derived daily id
- workspace path
- runtime directory mapping
- tool boundaries

### Step 5: Set Reviewable Lifecycle State

`ops` marks the created instance as reviewable (for example `pending_review`) before handoff to `critic`.

This step only sets execution outcome state; review policy details are defined later.

## 4. Failure Handling (Execution-Time)

If a blocking failure occurs before review pass, `ops` must:

1. stop forward execution immediately
2. remove partial `workspace-daily-<userId>/` outputs in rollback scope
3. remove partial `agents/daily-<userId>/...` outputs in rollback scope
4. revert partial runtime registration mutations for this instance
5. leave the system retry-safe for the same `userId`

No failed attempt may look fully provisioned after rollback.

## 5. Pre-Handoff Self-Check (Ops Internal Checklist)

Before handing off to `critic`, `ops` verifies:

1. required daily workspace path exists and is in correct naming convention
2. required runtime daily path exists and maps to derived id
3. runtime registration matches created paths and tool boundaries
4. no deprecated path model was used
5. no cross-scope side effects were introduced
6. execution result can be reviewed without additional hidden assumptions

If any self-check fails, treat as execution failure and follow rollback.

## 6. Explicit Ownership Boundary In This Procedure

Owned by `ops` in this procedure:

- precondition checks
- input validation
- workspace/runtime materialization
- runtime registration mutation
- rollback execution
- pre-handoff self-check

Not owned by `ops` in this procedure:

- redefining daily contract/scaffold ownership
- final review gate decision (owned by `critic`)
- detailed state/audit/review schema definitions (handled in `m3/s3`)

## 7. Exit Criteria For `m3/s2` Daily Track

This execution document is acceptable for `s2` when:

- execution steps are concrete and orderable
- preconditions and failure handling are explicit
- pre-handoff self-check is explicit
- `ops` ownership vs non-ownership is explicit
- content stays within execution scope and does not preempt `s3` detail design
