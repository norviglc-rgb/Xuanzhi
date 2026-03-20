# M3 Ops Provisioning Contract

## Status

- milestone: `m3`
- step: `s2`
- status: draft

## Purpose

Define the minimum executable provisioning contract owned by `ops` for:

- generic agent provisioning
- daily-user provisioning

This contract builds on the reviewed `m3 / s1` boundary baseline and keeps `ops` focused on execution rather than contract ownership.

## Scope

This document will formalize:

- preflight checks before provisioning
- input package requirements
- minimum execution sequence for each provisioning track
- failure handling during execution
- self-checks before handoff to `critic`

This document does not yet formalize:

- exact live state write points
- exact audit write points
- exact review artifact schema

Those remain in `m3 / s3`.

## 1. Execution Principles

- `ops` executes against existing contract and boundary rules; it does not redefine them.
- execution must follow current root-level runtime truth.
- provisioning must stop on blocking inconsistencies instead of guessing through them.
- failed attempts must remain retry-safe.
- `ops` owns execution sequencing, local self-checks, and rollback within approved boundaries.
- `critic` remains the review gate and is not part of provisioning execution.

## 2. Shared Preflight

Before either provisioning track starts, `ops` must confirm:

1. active runtime truth is available at repository root:
   - `openclaw.json`
   - `agents/`
2. requested path model matches current conventions:
   - generic agent: `workspace-<agentId>/`, `agents/<agentId>/agent/`
   - daily-user: `workspace-daily-<userId>/`, `agents/daily-<userId>/...`
3. provisioning request package is complete and internally consistent.
4. execution remains within allowlisted boundaries and does not redefine contract ownership.
5. no conflicting active registration already exists for the same target id.

If any preflight check fails, `ops` must stop and escalate instead of inferring missing facts.

## 3. Generic Agent Provisioning

This track is defined in detail by `m3-agent-provisioning-execution.md`.

Minimum execution sequence:

1. resolve and validate `agentId`, `workspace`, `agentDir`, `tools.allow`, `tools.deny`, and optional overrides.
2. create `workspace-<agentId>/` and the required generic workspace files/directories.
3. create runtime-owned directories:
   - `agents/<agentId>/agent/`
   - `agents/<agentId>/sessions/`
4. update `openclaw.json` with a consistent agent entry.
5. run local acceptance checks from the m2 contract and rollback rules.
6. only after local checks pass, prepare handoff to `critic`.

Execution constraints:

- do not introduce `workspaces/workspace-<agentId>/`
- do not introduce `templates/core-agent/*` as an execution dependency
- do not continue past inconsistent `id`, `workspace`, or `agentDir`

## 4. Daily-User Provisioning

This track is defined in detail by `m3-daily-provisioning-execution.md`.

Minimum execution sequence:

1. validate the request payload and deterministically derive:
   - `workspace-daily-<userId>/`
   - `agents/daily-<userId>/...`
2. materialize the approved daily workspace skeleton under the derived workspace path.
3. materialize the runtime daily directory surface under the derived daily runtime path.
4. write/update runtime registration for this daily instance.
5. set a reviewable lifecycle state such as `pending_review`.
6. only after local checks pass, prepare handoff to `critic`.

Execution constraints:

- do not use deprecated `workspaces/...` paths
- do not mutate unrelated workspaces or agent directories
- do not redefine daily contract ownership during execution

## 5. Shared Failure Handling

When a blocking failure occurs in either track, `ops` must:

1. stop forward execution immediately
2. remove partial workspace outputs created by the failed attempt
3. remove partial runtime-owned directories created by the failed attempt
4. revert partial runtime registration mutations for the failed target
5. preserve diagnostic evidence needed for retry analysis
6. ensure the same target id remains retry-safe

Post-rollback invariant:

- no failed target may still appear provisioned in active runtime truth

## 6. Pre-Review Self-Check

Before handoff to `critic`, `ops` must confirm:

1. expected workspace paths exist and use current naming conventions
2. expected runtime-owned paths exist and match the target id
3. runtime registration matches the materialized paths and tool boundaries
4. no deprecated path model was introduced
5. no blocking rollback trigger remains active
6. the result is reviewable without hidden assumptions or missing execution steps

## 7. Outcome For `m3 / s2`

This step is complete when `ops` has an execution contract that is:

- explicit enough to run without redefining ownership boundaries
- aligned with current runtime truth
- separated into generic agent and daily-user tracks where needed
- ready for state/audit/review formalization in `m3 / s3`

Review result:

- accepted as the formal `m3 / s2` baseline after integrating the generic-agent and daily-user execution tracks
