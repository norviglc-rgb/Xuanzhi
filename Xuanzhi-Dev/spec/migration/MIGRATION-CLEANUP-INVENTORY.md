# Migration Cleanup Inventory

## Purpose

This inventory records old paths, old terms, and outdated design assumptions that still exist in development materials.

It is an execution input for cleanup work, not runtime truth.

## Current Review Basis

Current runtime facts used for classification:

- active runtime is at repository root
- active workspaces use `workspace-<agentId>/` at root
- current repository does not use `workspaces/workspace-<agentId>/`
- `Xuanzhi-Dev/legacy-root/` is a migration source, not active runtime truth
- `Xuanzhi-Dev/generated/` is sample/generated material, not active runtime truth
- do not reintroduce `templates/core-agent/` as an active template family

## Classification Rules

- `migrate`: keep the intent, but rewrite path/term/structure before reuse
- `archive`: historical design or outdated structure; do not carry forward as active design
- `ignore`: sample or non-blocking material that can stay as reference for now

## Priority Summary

### P0

- remove active reliance on `workspaces/workspace-*`
- remove active reliance on `templates/core-agent/*`
- stop describing root-level `docs/`, `policies/`, `schemas/`, `workflows/`, `state/` as already-promoted runtime truth
- stop using `materialize-core-agents` as the assumed bring-up entrypoint

### P1

- rewrite template-first or workspace-template-first language toward generic agent creation rules
- normalize generated examples so they are clearly treated as samples only

### P2

- archive historical topology and main-workspace retirement narratives that no longer match repository reality

## Inventory

| source_area | file | pattern_or_topic | problem | classification |
|---|---|---|---|---|
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `workspaces/workspace-daily-<userId>` | old path model; current runtime uses root-level `workspace-*` | migrate |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `docs/templates/daily-template` | assumes a root-level template tree that is not active runtime truth today | migrate |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `docs/system/*`, `policies/*`, `schemas/*`, `workflows/*`, `state/*` described as current required files | describes target-state directories as if they already exist in active runtime | migrate |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `templates/core-agent` | outdated special-case template family | archive |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `materialize-core-agents` / “先物化 core agents” | outdated bring-up narrative; system workspaces already exist | archive |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `~/.openclaw/workspace-<item>`, `~/.openclaw/agents/<item>` | old path assumptions conflict with current repo-root runtime view | migrate |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `docs/system/PATH-MAP.md` | points to a non-existent active runtime file | migrate |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `main workspace` retirement narrative | historical/overdesigned narrative not grounded in current repository state | archive |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `workspace 模板` / `维护 workspace 模板` | template-first language conflicts with current generic agent-creation direction | migrate |
| requirements | `spec/requirements/open_claw多agent系统v1需求规格.md` | `workspace-*` names without `workspaces/` parent | these names match current convention and are not themselves a problem | ignore |
| legacy-root | `legacy-root/workflows/system/materialize-core-agents.json` | workflow name `materialize-core-agents` | old lifecycle framing and outdated bootstrap flow | archive |
| legacy-root | `legacy-root/workflows/system/materialize-core-agents.json` | `{{basePath}}/workspaces/workspace-<item>` | old path model | migrate |
| legacy-root | `legacy-root/workflows/system/materialize-core-agents.json` | `templates/core-agent/*.tpl` | special-case template family that should not be carried forward | migrate |
| legacy-root | `legacy-root/workflows/system/materialize-core-agents.json` | root-level `docs/system`, `policies`, `state` preconditions | assumes already-promoted runtime truth tree | migrate |
| legacy-root | `legacy-root/workflows/users/create-daily-user.json` | `{{basePath}}/workspaces/workspace-daily-<userId>` | old path model | migrate |
| legacy-root | `legacy-root/workflows/users/create-daily-user.json` | `templates/daily-template` as runtime source | assumes root-level template tree is already active | migrate |
| legacy-root | `legacy-root/workflows/users/create-daily-user.json` | `state/users/index.json`, `state/agents/catalog.json` copied into runtime | mixes seed/source-state semantics with runtime-state assumptions | migrate |
| legacy-root | `legacy-root/docs/system/GOVERNANCE.md` | truth-layer declarations for `docs/policies/schemas/workflows/state` | should not be treated as active runtime truth while still under `legacy-root` | migrate |
| legacy-root | `legacy-root/docs/system/ARCHITECTURE.md` | control-plane/review-gate/ACP declaration block | valuable as design reference, but too historical/system-declarative to treat as current truth | archive |
| legacy-root | `legacy-root/docs/system/FILE-NAMING.md` | `state/...`, `state/audit/*.jsonl`, `workspace-daily-*` | old path and state assumptions; also inconsistent with other old docs | migrate |
| legacy-root | `legacy-root/templates/core-agent/*` | whole directory | outdated special-case template family | archive |
| legacy-root | `legacy-root/schemas/user-profile.schema.json` | `workspaceId` pattern for `workspace-daily-*` | schema-level lock-in of the old workspace model | migrate |
| legacy-root | `legacy-root/state/agents/catalog.json` | old role taxonomy plus historical workspace ids | should be treated as seed/history, not active runtime truth | archive |
| legacy-root | `legacy-root/workflows/memory/promote.json` | root-level `policies/...` references | candidate workflow logic, but path model still needs migration | ignore |
| generated | `generated/audit/*.jsonl` | `log_initialized` sample events | generated samples only, not runtime audit truth | ignore |
| generated | `generated/workspaces/workspace-agent-smith/AGENTS.md` | `templates/core-agent/`, `templates/daily-template/` | generated sample still encodes old template assumptions | archive |
| generated | `generated/workspaces/workspace-agent-smith/BOOT.md` | `templates/`, `schemas/`, `workflows/` as present roots | generated sample assumes target-state root tree | archive |
| generated | `generated/workspaces/workspace-agent-smith/HEARTBEAT.md` | `templates/core-agent/` | repeats obsolete template family | archive |
| generated | `generated/workspaces/workspace-agent-smith/docs/GOVERNANCE.md` | root-level `docs/policies/schemas/workflows/state` truth model | sample doc still reflects unpromoted target state | migrate |
| generated | `generated/workspaces/workspace-agent-smith/docs/FILE-NAMING.md` | root-level `state/...` paths | sample doc still reflects unpromoted target state | migrate |
| generated | `generated/workspaces/workspace-agent-smith/docs/ARCHITECTURE.md` | `agent templates and maintenance` wording | still template-first and not aligned with current agent-smith direction | migrate |
| generated | `generated/workspaces/workspace-agent-smith/state/local-state.json` | `core_agent_templates`, `daily_templates`, `workflow_templates` | generated sample state with outdated terminology | archive |
| generated | `generated/workspaces/workspace-agent-smith/schemas/*.json` | `$id: "schemas/...json"` | reusable candidates, but path semantics still need migration | migrate |
| generated | `generated/workspaces/workspace-agent-smith/workflows/users/create-daily-user.json` | `templates/daily-template`, `workspaces/workspace-daily-*`, `state/...` | classic old-path sample; do not treat as active runtime workflow | migrate |
| generated | `generated/workspaces/workspace-agent-smith/workflows/memory/promote.json` | `policies/memory-policy.json` | sample workflow with old root path assumptions | migrate |

## Recommended Actions

1. Treat `spec/requirements/...` as a historical requirements draft and stop using it as a live architecture reference until path and terminology cleanup is complete.
2. Treat `legacy-root/` as migration source only. Promote only selected logic, never whole structures wholesale.
3. Treat `generated/` as samples only. Add clearer labeling if needed, but do not use it as design truth.
4. Replace `materialize-core-agents` with the current practical question: what still needs normalization in existing `workspace-*` roots.
5. Replace `templates/core-agent/*` and template-first wording with generic agent creation contracts owned by `agent-smith`.

## Exit Condition For This Inventory

This inventory can be marked resolved when:

- active documents no longer point to these outdated path models
- legacy material is either promoted, rewritten, or explicitly archived
- generated samples are no longer confused with runtime truth
