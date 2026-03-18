# ARCHITECTURE

## System positioning
A minimum viable, self-iterating, auditable, rollback-friendly multi-agent system built on OpenClaw.

## Topology
- orchestrator: control plane
- critic: review-gate
- architect: architecture and simple development
- ops: operations, deployment, lifecycle, maintenance
- daily-<userId>: per-user daily agent instance
- skills-smith: skill templates and maintenance
- agent-smith: agent templates and maintenance
- claude-code: ACP execution domain for complex development
- subagents: parallel background workers

## Principles
1. One agent, one workspace, one agentDir, one session scope.
2. Orchestrator routes; it does not own lifecycle operations.
3. Daily agents are instantiated per user.
4. Complex development goes to Claude Code ACP.
5. Subagents assist; they do not replace ACP.
6. Critic reviews; it does not produce the main output.
7. Execution is decoupled from skills, tools, and external software.
8. File- and JSON-based source of truth first.
