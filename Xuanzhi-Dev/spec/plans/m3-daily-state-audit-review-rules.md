# M3 Daily-User State / Audit / Review Rules (Ops)

## Status

- milestone: `m3`
- step: `s3`
- track: `daily-user`
- status: active draft

## Purpose

Define the minimum write rules for daily-user provisioning outcomes:

- live state write points
- audit write points
- critic review trigger points
- minimum field recommendations

This document is constrained to current runtime facts and avoids speculative schema expansion.

## 1. Runtime Facts Used As Baseline

- runtime registry surface exists in `openclaw.json` (`agents.list`, path/tool boundaries)
- ops allowlist explicitly permits `manage_daily_user_instance` within:
  - `workspace-daily-*`
  - `agents/daily-*`
- daily provisioning flow already defines:
  - derived ids from `userId`
  - pre-handoff lifecycle state such as `pending_review`
- legacy references available for minimum shape:
  - users index baseline: `legacy-root/state/users/index.json`
  - audit stream baseline: `generated/audit/user-provision.jsonl`
  - profile baseline: `legacy-root/templates/daily-template/profile.json.tpl`

## 2. Live State Write Points (Minimum)

For one successful daily-user provisioning attempt, `ops` should write live state at three points only.

### 2.1 Users Index Write

Write point:

- users index surface (runtime equivalent of `state/users/index.json`)

When to write:

- after workspace/runtime materialization succeeds
- before handoff to `critic`

Minimum entry fields:

- `userId`
- `dailyAgentId` (derived `daily-<userId>`)
- `workspaceId` (derived `workspace-daily-<userId>`)
- `status` (must be `pending_review` before critic pass)

### 2.2 Runtime Registration Write

Write point:

- runtime registration surface (active registry, currently `openclaw.json`-style surface)

When to write:

- after filesystem materialization
- before users index is marked ready for review

Minimum registration fields:

- `id` (`daily-<userId>`)
- `workspace` (`workspace-daily-<userId>` or runtime absolute mapping form)
- `agentDir` (`agents/daily-<userId>/...` mapping)
- `tools.allow`
- `tools.deny`

### 2.3 Daily Profile Write

Write point:

- daily workspace profile file (runtime equivalent of template-derived profile)

When to write:

- during workspace materialization

Minimum profile fields:

- `userId`
- `dailyAgentId`
- `workspaceId`
- `status` (`pending_review`)

## 3. Audit Write Points (Minimum)

Audit should remain append-only and event-based (jsonl stream style).

Target stream:

- daily provisioning stream (runtime equivalent of `audit/user-provision.jsonl`)

### 3.1 Required Audit Events

For each provisioning attempt, append these events in order:

1. `provision_requested`
2. `workspace_materialized`
3. `runtime_registered`
4. `state_marked_pending_review`
5. `review_handoff_created`

If failure happens, append:

- `provision_failed`
- `rollback_applied`

### 3.2 Minimum Audit Event Fields

Each event should include:

- `stream` (`user-provision`)
- `timestamp` (ISO 8601 with offset)
- `event`
- `userId`
- `dailyAgentId`
- `workspaceId`
- `requestId` (or equivalent attempt id)
- `status` (`ok` or `failed`)

Optional but useful:

- `reason`
- `rollbackScope`
- `operator` (`ops` or caller identity)

## 4. Critic Review Trigger Rules

`ops` should trigger critic review only when all are true:

1. daily workspace exists at expected derived path
2. runtime registration is present and consistent with derived ids
3. users index entry exists and is `pending_review`
4. required audit events up to `review_handoff_created` are present
5. no blocking rollback trigger remains active

Review trigger write:

- create/append a review handoff record with:
  - target `daily-<userId>`
  - current status `pending_review`
  - pointers to produced artifacts (workspace path, registration entry id, audit attempt id)

`critic` owns pass/fail decision; `ops` owns remediation and rollback if review fails.

## 5. Failure And Rollback Write Rules

If provisioning fails before critic pass:

1. remove partial workspace/runtime outputs in daily scope
2. revert partial runtime registration
3. revert users index mutation for the failed attempt
4. append failure + rollback audit events
5. keep retry safety for same `userId`

Post-rollback invariant:

- no live state surface may show the instance as ready or active.

## 6. Minimum Field Set vs Deferred Fields

### 6.1 Keep Now (Minimum Set)

- identity mapping: `userId`, `dailyAgentId`, `workspaceId`
- runtime binding: `workspace`, `agentDir`, `tools.allow`, `tools.deny`
- lifecycle: `status = pending_review`
- audit chain: request -> materialization -> registration -> review handoff (plus failure/rollback events when needed)

### 6.2 Defer (Avoid Overdesign In `m3/s3`)

- rich persona expansion beyond template minimum
- cross-system approval payload design
- complex metrics/observability schemas
- multi-stage review taxonomies beyond pass/fail/rework
- additional registries unless required by actual runtime execution

## 7. Acceptance Criteria For This Rule Set

This rule set is acceptable for `m3/s3` daily track when:

- live state write points are explicit and ordered
- audit write points and mandatory events are explicit
- critic trigger conditions are explicit and testable
- minimum fields are defined without forcing speculative schema growth
- rollback write behavior preserves retry safety and audit continuity
