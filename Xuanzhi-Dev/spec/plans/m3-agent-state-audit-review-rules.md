# M3 Generic Agent State/Audit/Review Rules (Ops)

## Status

- milestone: `m3`
- step: `s3`
- track: `generic-agent`
- status: draft

## Purpose

Define the minimum rules for generic agent provisioning outputs in `m3/s3`:

- live state write points
- audit write points
- `critic` review trigger points
- minimum field set

This document stays minimal and execution-oriented to avoid over-design.

## Scope And Source Facts

This rule set is aligned with:

- `openclaw.json` as active runtime registration surface
- `m3-agent-provisioning-boundary.md`
- `m3-agent-provisioning-execution.md`
- `hooks/ops-action-guard/allowlist.json`
- legacy/reference examples:
  - `legacy-root/state/agents/catalog.json`
  - `generated/audit/core-agent-materialization.jsonl`

It does not redefine m2 contract ownership or introduce new template systems.

## 1. Live State Write Points (Minimum)

For generic agent provisioning, keep only these live state writes as required:

1. runtime filesystem materialization:
   - `workspace-<agentId>/`
   - `agents/<agentId>/agent/`
   - `agents/<agentId>/sessions/`
2. runtime registry write:
   - upsert agent entry in `openclaw.json` -> `agents.list[]`

No additional state store is required for `m3/s3` completion.

### 1.1 Required Registry Consistency

The written `openclaw.json` entry must keep these fields consistent:

- `id`
- `workspace`
- `agentDir`
- `tools.allow`
- `tools.deny`

`sandbox` may be omitted unless an explicit override is needed.

## 2. Audit Write Points (Minimum)

### 2.1 Audit Stream Target

Use one stream name for this track:

- `core-agent-materialization`

Write target depends on execution mode:

- runtime mode: `~/.openclaw/audit/core-agent-materialization.jsonl`
- repo drill mode: `Xuanzhi-Dev/generated/audit/core-agent-materialization.jsonl`

Do not dual-write by default. Pick one target per run.

### 2.2 Minimum Event Sequence

For each provisioning attempt, append JSONL records at:

1. request accepted (`requested`)
2. preflight passed/failed (`preflight_checked`)
3. filesystem materialization finished (`workspace_materialized`, `runtime_dirs_materialized`)
4. registry write finished (`registry_upserted`)
5. local self-check finished (`self_check_passed` or `self_check_failed`)
6. review handoff created (`review_requested`)
7. rollback executed when needed (`rollback_completed`)
8. final attempt status (`completed` or `failed`)

## 3. Critic Review Trigger Points

`critic` trigger is allowed only after:

1. provisioning execution steps completed
2. `openclaw.json` registration consistency verified
3. pre-critic self-check passed

Trigger action:

- append `review_requested` audit event
- include pointer to created workspace/runtime paths and self-check result

No final activation/signoff is performed by `ops`; that remains `critic` ownership.

## 4. Minimum Field Set

### 4.1 Live State (Registry Entry)

Minimum fields in `openclaw.json` agent entry:

- `id`
- `workspace`
- `agentDir`
- `tools.allow`
- `tools.deny`

Optional:

- `sandbox` override
- `default` flag

### 4.2 Audit Event Record

Minimum fields per JSONL event:

- `stream` (fixed: `core-agent-materialization`)
- `timestamp` (ISO 8601 with timezone)
- `event` (from minimum event sequence)
- `attemptId` (unique per provisioning attempt)
- `agentId`
- `workspace`
- `agentDir`
- `status` (`ok` or `error`)
- `actor` (normally `ops`)

Recommended but optional:

- `reason` (for error/rollback cases)
- `reviewTarget` (normally `critic`)
- `source` (workflow or command id)

## 5. Minimal Set To Keep Now (Anti Over-Design)

Keep in scope for `m3/s3`:

- one live registry surface (`openclaw.json`)
- one audit stream (`core-agent-materialization`)
- one review handoff trigger (`review_requested`)
- one minimum field set for registry and audit

Do not add in this step:

- a second mandatory live catalog file
- multi-table review schemas
- new workflow engine requirements
- role-specific extended metadata as mandatory fields

## 6. Current Constraints And Gap Note

`allowlist.json` currently contains explicit daily-user lifecycle action but no explicit generic-agent provisioning action id.

Rule for now:

- keep generic-agent provisioning inside existing approved ops execution boundary and audit every mutation
- before production hardening in later milestones, add an explicit generic provisioning allowlist action entry

This is a hardening gap, not a blocker for `m3/s3` rule definition.

## 7. Exit Criteria For This Track

This generic-agent `s3` rule set is complete when:

- live state write points are explicit and minimal
- audit write points and minimum event sequence are explicit
- `critic` trigger timing is explicit
- required vs optional fields are explicit
- no extra mandatory stores or schemas are introduced
