# ARCHITECTURE

## System positioning
Active runtime knowledge now lives at the repository root under `docs/system`, `policies`, `schemas`, `workflows`, and `state`. RG-01 makes this layout the official landing spot for architecture, policy, schema, workflow, and runtime state truth so that every bootstrap, audit, and orchestration component reads from the same set of files.

## Topology
- orchestrator: control plane
- critic: review gate
- architect: architecture and development
- ops: operations, deployment, lifecycle, maintenance
- daily-<userId>: per-user daily agent instance
- skills-smith: skill templates and maintenance
- agent-smith: agent templates and maintenance
- claude-code: ACP execution domain for complex development
- subagents: parallel background workers

## Principles
1. One agent, one workspace, one agentDir, one session scope.
2. Orchestrator routes without owning lifecycle operations.
3. Daily agents are instantiated per user and move through the workflows stored under `workflows/`.
4. Complex development runs through Claude Code and the `claude-code` ACP runtime.
5. Subagents assist; they never replace ACP or core agent authority.
6. Critic reviews; it does not produce the main output but drives approval for state transitions.
7. Execution is decoupled from skills, tools, and external software by anchoring truth in JSON/Markdown under the root directories.
8. File- and JSON-based sources under `docs/system`, `policies`, `schemas`, `workflows`, and `state` are the canonical truth for the runtime.
