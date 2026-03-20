# Runtime Semantics Summary

## Status

Frozen summary for milestone `m1 / s4`.

Use this as the working baseline for subsequent implementation planning until it is explicitly revised.

## 1. Active Runtime Shape

The active runtime is the repository root.

Current active runtime paths include:

- `openclaw.json`
- `agents/`
- `credentials/`
- `cron/`
- `hooks/`
- `logs/`
- `skills/`
- `workspace-orchestrator/`
- `workspace-critic/`
- `workspace-architect/`
- `workspace-ops/`
- `workspace-skills-smith/`
- `workspace-agent-smith/`
- `workspace-claude-code/`

## 2. Active Workspace Convention

Current workspace naming is:

- `workspace-<agentId>/`

For future daily users, the aligned convention is:

- `workspace-daily-<userId>/`

Current repository facts do not support:

- `workspaces/workspace-<agentId>/`
- `workspaces/workspace-daily-<userId>/`

## 3. Runtime Truth Boundary

Current runtime truth is limited to the active runtime files at repository root.

The following areas are not active runtime truth:

- `Xuanzhi-Dev/legacy-root/`
- `Xuanzhi-Dev/generated/`
- historical requirement appendices that describe target-state directory trees as already active

Interpretation rules:

- `legacy-root/` is a migration source
- `generated/` is sample/generated output
- `spec/requirements/` is a requirements draft, not a live runtime contract

## 4. Template Direction

Do not reintroduce a dedicated `templates/core-agent/` family as the default direction.

The preferred direction is:

- generic agent creation rules for `agent-smith`
- isolated daily-user creation rules where needed

This keeps the system simpler and avoids carrying forward template-first overdesign.

## 5. Role Baseline

- `agent-smith`: owns generic agent creation rules, scaffolding shape, schemas, and workflow definitions related to agent creation
- `ops`: owns execution of agent provisioning, daily-user provisioning, and runtime lifecycle operations
- `critic`: owns review, signoff, and stage-quality checks
- `orchestrator`: owns routing and convergence, not provisioning ownership
- `architect`: owns solution shaping and complex-task handoff

## 6. Bring-Up Baseline

The current practical question is not “how to materialize core agents from scratch”.

The current practical question is:

- how to normalize and verify the already-present `workspace-*` roots
- how to let `agent-smith` define creation contracts
- how to let `ops` execute those contracts safely

Therefore:

- treat `materialize-core-agents` as historical unless a narrower normalization workflow is justified later

## 7. What Must Not Be Assumed

Do not assume these are already active runtime paths:

- root-level `docs/`
- root-level `policies/`
- root-level `schemas/`
- root-level `workflows/`
- root-level `state/`
- root-level `templates/`

Do not assume these are already active runtime mechanisms:

- a working root-level system truth tree promoted from `legacy-root`
- a valid `core-agent` template family
- generated samples as executable runtime truth

## 8. Immediate Consequence For Next Milestones

Milestone `m2` should design agent creation around current runtime facts.

Milestone `m3` should design provisioning execution around:

- root-level `workspace-*`
- root-level `agents/<agentId>/...`
- explicit runtime state and audit handling
- reviewable outputs

## 9. Revision Rule

This summary should only be revised when:

- runtime structure actually changes
- a previously non-active truth source is formally promoted
- the team explicitly approves a new path model
