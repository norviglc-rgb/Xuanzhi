# PATH-MAP

This document records the current effective path model of the repository and the migration rules we should follow from here.

It is a migration note, not the runtime source of truth.

## 1. Current Effective Runtime Paths

Today the repository matches these OpenClaw runtime paths:

- `~/.openclaw/openclaw.json`
- `~/.openclaw/agents/<agentId>/agent/`
- `~/.openclaw/agents/<agentId>/sessions/`
- `~/.openclaw/credentials/`
- `~/.openclaw/cron/`
- `~/.openclaw/hooks/`
- `~/.openclaw/logs/`
- `~/.openclaw/skills/`
- `~/.openclaw/workspace-orchestrator/`
- `~/.openclaw/workspace-critic/`
- `~/.openclaw/workspace-architect/`
- `~/.openclaw/workspace-ops/`
- `~/.openclaw/workspace-skills-smith/`
- `~/.openclaw/workspace-agent-smith/`
- `~/.openclaw/workspace-claude-code/`

The active workspace naming rule is:

- `workspace-<agentId>`

Not:

- `workspaces/workspace-<agentId>`

## 2. Planned But Not Yet Promoted Paths

The following paths are described in older specs or migration drafts, but they are not active runtime paths at the repository root today:

- `docs/`
- `policies/`
- `schemas/`
- `state/`
- `templates/`
- `workflows/`
- `audit/`
- `workspaces/`

These materials currently exist mainly under `Xuanzhi-Dev/legacy-root/` and must be promoted selectively instead of being assumed to already exist in runtime.

## 3. Development-Only Areas

- `Xuanzhi-Dev/spec/`: requirements and planning
- `Xuanzhi-Dev/legacy-root/`: migration source for future system artifacts
- `Xuanzhi-Dev/generated/`: generated samples and audit examples
- `Xuanzhi-Dev/reference/`: reference-only material

None of these are active runtime truth by default.

## 4. Workspace Rules

Current agent workspaces are dedicated role workspaces at repository root:

- `workspace-orchestrator/`
- `workspace-critic/`
- `workspace-architect/`
- `workspace-ops/`
- `workspace-skills-smith/`
- `workspace-agent-smith/`
- `workspace-claude-code/`

Future daily-user instances should follow the same naming style:

- `workspace-daily-<userId>/`

This keeps naming aligned with the runtime that already exists.

## 5. Ownership Rules

- `agent-smith` defines how new agents are created, what files they need, and what schemas/workflows support that process
- `ops` executes agent creation and user creation workflows in runtime
- `critic` reviews provisioning and risky changes
- `architect` prepares implementation plans and complex-task handoff
- `orchestrator` routes work but should not absorb provisioning or lifecycle duties

## 6. Template Rules

Do not maintain a dedicated `templates/core-agent/` line just because several system agents exist.

Preferred direction:

- generic agent template logic for agent creation
- daily-user template logic for isolated user instances

This keeps `agent-smith` focused on reusable creation rules instead of multiplying special-case template families.

## 7. Path Patterns To Stop Treating As Current Truth

These patterns still appear in historical docs and generated examples, but should be treated as legacy until real runtime migration happens:

- `workflows/system/materialize-core-agents.json`
- `templates/core-agent/*`
- `workspaces/workspace-<agentId>/`
- `workspaces/workspace-daily-<userId>/`
- root-level `docs/system/*` described as already active
- root-level `policies/*.json`, `schemas/*.json`, `state/*.json`, `workflows/*.json` described as already active

## 8. Migration Principle

Promote only what the runtime is ready to use.

When moving a file out of `Xuanzhi-Dev/legacy-root/`:

1. confirm the target path exists in current runtime design
2. confirm the path matches `openclaw.json`
3. confirm ownership is clear between `agent-smith`, `ops`, and `critic`
4. avoid introducing a second parallel structure

## 9. Retirement Condition

This document can be retired once:

- active runtime paths and promoted system docs are fully aligned
- old path forms are removed from active documents
- `legacy-root/` no longer carries runtime-critical truth
