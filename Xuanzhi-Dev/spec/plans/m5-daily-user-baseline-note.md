# M5 Daily-User Baseline Note

Date: 2026-03-20
Milestone: `m5`
Step: `s1` (`整理 m5 输入基线与 daily-user 验收口径`)

## 1. Daily-Test-User Naming And Isolation Baseline

- fixed test user id: `test-user-001`
- derived daily agent id: `daily-test-user-001`
- derived workspace id: `workspace-daily-test-user-001`
- isolation boundary:
  - workspace scope must stay under `workspace-daily-*`
  - runtime agent scope must stay under `agents/daily-*`
  - no write to unrelated system workspaces

## 2. Minimum Input Contract (for provisioning execution)

- `userId`: `test-user-001`
- derived ids must match deterministic rule above
- explicit tool boundaries:
  - `tools.allow`
  - `tools.deny`
- request metadata:
  - `requestId`
  - `requestedBy`
  - `timestamp`

## 3. Minimum Deliverables For m5 Acceptance

- filesystem:
  - `workspace-daily-test-user-001/` exists
  - `agents/daily-test-user-001/` runtime surface exists
- profile/state:
  - daily profile written with `userId`, `dailyAgentId`, `workspaceId`, `status=pending_review`
  - users index contains pending review entry for this daily user
- audit:
  - event chain includes at least:
    - `provision_requested`
    - `workspace_materialized`
    - `runtime_registered`
    - `state_marked_pending_review`
    - `review_handoff_created`
- review:
  - critic review is triggered with pointer to artifacts

## 4. Critic Trigger And Pass Criteria

Trigger only when all conditions are true:

- derived workspace and agent runtime paths exist
- registration and users index are consistent
- required audit events are appended in order
- lifecycle is `pending_review`

Pass criteria for review stage:

- no path/model drift
- no cross-scope side effects
- no missing audit or state evidence

## 5. m3->m5 Contract Link

`m5` executes on top of reviewed `m3` outputs:

- daily boundary: `m3-daily-provisioning-boundary.md`
- execution flow: `m3-daily-provisioning-execution.md`
- state/audit/review rules: `m3-daily-state-audit-review-rules.md`

No new provisioning model is introduced in `m5`; this stage validates real execution closure for one isolated daily user.
