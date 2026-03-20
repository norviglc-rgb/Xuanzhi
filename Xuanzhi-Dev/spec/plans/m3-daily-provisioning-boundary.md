# M3 Daily-User Provisioning Boundary (Ops)

## Status

- milestone: `m3`
- step: `s1`
- status: active draft

## Purpose

Define the execution boundary for `ops` when provisioning a daily user instance in runtime.

This document follows:

- current runtime facts (`README.md`, `RUNTIME-SEMANTICS-SUMMARY.md`)
- `workspace-ops` role/tool constraints
- m2 contract style (`agent-creation-contract.md`, `agent-contract-validation-and-rollback.md`) as the baseline execution pattern

## Scope

Applies to daily-user provisioning in current runtime shape at repository root.

Does not cover:

- redefining daily-user template/schema ownership
- replacing `agent-smith` contract ownership
- critic final authority changes
- legacy/generated path models as runtime truth

## 1. Inputs Consumed By Ops For Daily Provisioning

`ops` consumes a daily-user provisioning package and executes it under allowlisted boundaries.

### 1.1 Provisioning Request Inputs

- `userId`: stable user identifier used to derive runtime names
- derived workspace id: `workspace-daily-<userId>` (aligned with runtime semantics summary)
- derived daily agent id: `daily-<userId>` (aligned with existing requirement examples and allowlist scope)
- request metadata for audit traceability (for example: `requestedBy`, request timestamp, request id)
- runtime permission boundary fields required by registration surface (`tools.allow`, `tools.deny`; optional sandbox override only when explicitly required)

### 1.2 Upstream Contract/Rule Inputs

- daily-user scaffold/creation contract owned by `agent-smith` (ops consumes, does not redefine)
- acceptance and rollback checklist for daily provisioning (m2 pattern reused: explicit trigger, scope, post-rollback invariants)
- policy and allowlist constraints, including `hooks/ops-action-guard/allowlist.json` action `manage_daily_user_instance` with scope `workspace-daily-*` and `agents/daily-*`

### 1.3 Runtime Truth Constraints

- active runtime paths are root-level (`openclaw.json`, `agents/`, `workspace-*`)
- do not use deprecated `workspaces/workspace-daily-<userId>/` path
- do not treat `Xuanzhi-Dev/legacy-root/` or `Xuanzhi-Dev/generated/` as active runtime truth

## 2. Outputs Ops Must Produce

When daily provisioning succeeds, `ops` must produce reviewable, file-backed outputs.

### 2.1 Runtime Filesystem Outputs

- created daily workspace: `workspace-daily-<userId>/`
- created daily runtime state directory under `agents/daily-<userId>/...` (exact child layout follows daily contract; if agentized, it should include runnable state and session surfaces)
- no partial outputs outside allowed daily scope

### 2.2 Runtime Registration/State Outputs

- daily instance registration is written to the active runtime registration surface (for example, agent-backed registration in `openclaw.json` or equivalent runtime state file defined by the daily contract)
- registration fields are internally consistent (`userId`, derived `daily-<userId>`, `workspace-daily-<userId>`, runtime directory mapping, tool boundaries)
- lifecycle status reaches a reviewable state (`pending_review` is acceptable before critic signoff)

### 2.3 Audit And Review Outputs

- auditable execution records are appended for request, materialization, registration, and review submission steps
- a handoff record to `critic` is created with status `pending_review`
- failures include explicit failed-attempt records and rollback evidence

Exact filenames may evolve in later m3 steps, but no-audit and no-review-evidence outcomes are out of boundary.

## 3. Hard Dependencies

Daily provisioning by `ops` depends on:

- `workspace-ops/AGENTS.md`:
  - ops executes daily-user provisioning workflows
  - ops keeps audit chain intact
- `workspace-ops/TOOLS.md`:
  - actions stay allowlisted
  - state/policy/schema/workflow are checked before mutation
- `README.md` and `RUNTIME-SEMANTICS-SUMMARY.md`:
  - root-level runtime truth
  - `workspace-daily-<userId>` naming direction
- m2 contract artifacts:
  - explicit input/output boundary pattern
  - explicit acceptance + rollback pattern
  - retry-safe post-rollback requirement

If any dependency is missing or contradictory, ops must escalate or stop.

## 4. Handoff Boundary (Ops -> Critic)

### 4.1 What Ops Must Hand Off

- provisioning request identity (`userId`, derived ids, request metadata)
- produced runtime output summary (workspace path, runtime dirs, registration target and key fields)
- acceptance check results against daily contract rules
- audit record pointers proving execution order and current status
- known risks or deviations needing explicit reviewer attention

### 4.2 What Critic Owns

- review gate decision: pass / fail / rework requested
- structural and risk validation of daily provisioning outputs
- signoff decision for moving from `pending_review` toward active use

### 4.3 What Critic Does Not Own

- provisioning execution
- runtime mutation for provisioning steps
- contract ownership transfer from `agent-smith`

## 5. Failure And Rollback Boundary

When blocking checks fail before review pass, `ops` must:

1. stop forward provisioning actions
2. remove partial `workspace-daily-<userId>/` outputs
3. remove partial `agents/daily-<userId>/...` outputs
4. revert partial registration/state mutations for this daily user
5. keep diagnostic/audit evidence and make retry of same `userId` safe

No failed attempt may leave the daily user appearing fully provisioned.

## 6. Completion Contract For M3/S1 (Daily Track)

For this step, daily boundary definition is complete when:

- daily provisioning inputs, outputs, dependencies, and critic handoff are explicit
- constraints are aligned with current runtime truth and allowlist scope
- ownership separation remains clear (`agent-smith` defines contract, `ops` executes, `critic` reviews)
- rollback and retry-safety expectations are explicit
