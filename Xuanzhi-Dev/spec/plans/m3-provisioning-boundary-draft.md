# M3 Provisioning Boundary Summary

## Stage

- milestone: `m3`
- step: `s1`
- status: reviewed baseline

## Purpose

Define the reviewed execution boundary for `ops` when consuming the generic agent contract from `m2` and when handling daily-user provisioning.

This summary is aligned with current runtime facts and serves as the baseline for later `m3` execution details.

## 1. Boundary Intent

This boundary should answer:

1. what `ops` receives as input for provisioning
2. what `ops` must produce as output
3. what must be written to runtime truth, audit, and review surfaces
4. where `agent-smith`, `ops`, and `critic` hand off to each other

## 2. Current Direction

- `agent-smith` defines the contract and scaffold expectations
- `ops` executes provisioning against that contract
- `critic` reviews the resulting created output and risks

## 3. Generic Agent Provisioning

Reviewed in:

- `m3-agent-provisioning-boundary.md`

Accepted boundary for the generic agent track:

- `ops` consumes the m2 contract package and does not redefine scaffold, naming, or ownership rules.
- required inputs include `agentId`, `workspace`, `agentDir`, tool boundary fields, and the acceptance/rollback rules defined in m2 artifacts.
- required outputs include `workspace-<agentId>/`, `agents/<agentId>/agent/`, `agents/<agentId>/sessions/`, and a consistent `openclaw.json` registration entry.
- the execution must leave audit and lifecycle evidence instead of silent filesystem mutation.
- rollback must remove partial outputs, revert partial registration, preserve diagnostics, and keep retry safety.

## 4. Daily-User Provisioning

Reviewed in:

- `m3-daily-provisioning-boundary.md`

Accepted boundary for the daily-user track:

- `ops` consumes a daily provisioning package keyed by `userId`, derived runtime ids, request metadata, permission boundaries, and the contract/rule set handed off from `agent-smith`.
- required outputs include `workspace-daily-<userId>/`, `agents/daily-<userId>/...`, runtime registration/state entries, and a reviewable lifecycle state such as `pending_review`.
- the execution must emit audit records for request, materialization, registration, review submission, and failure/rollback when applicable.
- `critic` receives a review handoff package but does not own provisioning execution or runtime mutation.
- rollback must remove partial daily outputs, revert registration/state mutation, preserve diagnostics, and keep retry safety.

## 5. Shared Constraints

- `ops` does not redefine the creation contract
- `ops` must leave file-backed outputs, state, or audit evidence
- `critic` does not perform provisioning execution
- runtime truth must not be confused with legacy or generated materials
- current runtime path truth remains root-level `workspace-*`, `agents/`, and `openclaw.json`
- deprecated `workspaces/workspace-*` and `templates/core-agent/*` models must not be reintroduced

## 6. Review Outcome For `m3 / s1`

`s1` is accepted as complete on the basis of:

- separate reviewed boundary documents for generic agent and daily-user provisioning
- explicit ownership handoff between `agent-smith`, `ops`, and `critic`
- explicit rollback and retry-safety expectations
- alignment with current runtime semantics instead of legacy path models

Next step: use this summary as the baseline for `s2`, which defines the actual provisioning execution contract.
