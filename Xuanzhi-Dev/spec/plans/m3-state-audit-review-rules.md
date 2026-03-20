# M3 State Audit Review Rules

## Status

- milestone: `m3`
- step: `s3`
- status: draft

## Purpose

Define the minimum file-backed write rules for `ops` provisioning in the current runtime model:

- where live state should be written
- where audit should be written
- when `critic` review should be triggered

This document is intentionally minimal and should avoid reintroducing overdesigned state layers before they are needed by runtime use.

## Scope

This document will integrate:

- generic agent provisioning write rules
- daily-user provisioning write rules
- shared review trigger rules

## 1. Shared Direction

For `m3 / s3`, keep the rule set minimal and file-backed:

- write only to runtime surfaces that already have a clear role in the current model
- keep audit append-only and per-attempt
- trigger `critic` only after local execution checks pass
- defer richer schemas, extra catalogs, and metrics unless runtime use proves they are needed

Execution modes:

- runtime mode writes to `~/.openclaw/...`
- repo drill mode writes to `Xuanzhi-Dev/generated/...`

Per run, choose one audit target mode instead of dual-writing by default.

## 2. Generic Agent Rules

Track source: `m3-agent-state-audit-review-rules.md`

Minimum live state writes:

1. materialized filesystem surfaces:
   - `workspace-<agentId>/`
   - `agents/<agentId>/agent/`
   - `agents/<agentId>/sessions/`
2. runtime registry upsert:
   - `openclaw.json` -> `agents.list[]`

Minimum registry fields:

- `id`
- `workspace`
- `agentDir`
- `tools.allow`
- `tools.deny`

Minimum audit stream:

- stream name: `core-agent-materialization`
- target:
  - runtime mode: `~/.openclaw/audit/core-agent-materialization.jsonl`
  - repo drill mode: `Xuanzhi-Dev/generated/audit/core-agent-materialization.jsonl`

Minimum audit events:

1. `requested`
2. `preflight_checked`
3. `workspace_materialized`
4. `runtime_dirs_materialized`
5. `registry_upserted`
6. `self_check_passed` or `self_check_failed`
7. `review_requested`
8. `rollback_completed` when needed
9. `completed` or `failed`

Generic-agent `critic` trigger:

- execution completed
- registry consistency verified
- self-check passed
- `review_requested` event appended

Hardening note:

- current allowlist explicitly covers daily-user lifecycle but not generic-agent provisioning as a named action
- this is a later hardening item, not a blocker for `m3 / s3`

## 3. Daily-User Rules

Track source: `m3-daily-state-audit-review-rules.md`

Minimum live state writes:

1. daily profile file in the provisioned workspace
2. runtime registration entry for `daily-<userId>`
3. users index entry with `pending_review`

Minimum daily identity fields across those surfaces:

- `userId`
- `dailyAgentId`
- `workspaceId`
- `status`

Minimum runtime registration fields:

- `id`
- `workspace`
- `agentDir`
- `tools.allow`
- `tools.deny`

Minimum audit stream:

- stream name: `user-provision`
- target:
  - runtime mode: `~/.openclaw/audit/user-provision.jsonl`
  - repo drill mode: `Xuanzhi-Dev/generated/audit/user-provision.jsonl`

Minimum audit events:

1. `provision_requested`
2. `workspace_materialized`
3. `runtime_registered`
4. `state_marked_pending_review`
5. `review_handoff_created`
6. `provision_failed` when needed
7. `rollback_applied` when needed

Daily-user `critic` trigger:

- daily workspace exists at the derived path
- runtime registration is present and consistent
- users index entry exists and is `pending_review`
- required audit chain through `review_handoff_created` exists
- no blocking rollback trigger remains active

## 4. Shared Review Trigger

`ops` should trigger `critic` review only after:

1. expected filesystem outputs exist
2. required runtime registration is consistent
3. local self-check passes
4. the required audit chain for the track is present
5. no blocking rollback trigger remains active

Review handoff should minimally include:

- target id (`agentId` or `dailyAgentId`)
- current lifecycle state (`pending_review` for daily-user; review-ready for generic agent)
- pointers to created paths
- pointer to the provisioning attempt id or audit event chain

## 5. Minimality Guard

Keep now:

- one active runtime registry surface
- one audit stream per provisioning track
- one explicit review trigger point per attempt
- minimum identity and path fields required to validate provisioning

Defer:

- second mandatory catalog files for generic agents
- rich persona or approval payload expansion
- multi-table review schemas
- metrics-heavy observability schemas
- extra state stores not required by current runtime execution

## 6. Outcome For `m3 / s3`

This step is complete when:

- live state write points are explicit
- audit write points are explicit
- critic review trigger points are explicit
- minimal fields are stated without pulling in unnecessary extra structure

Review result:

- accepted as the formal `m3 / s3` baseline after integrating the generic-agent and daily-user rule tracks
