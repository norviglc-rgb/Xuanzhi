# Runtime Agents

This directory contains per-agent runtime directories.

## What Lives Here

- `~/.openclaw/agents/<agentId>/agent/` (agent state/config root)
- `~/.openclaw/agents/<agentId>/sessions/` (session files)

## Workspace Location

Managed workspaces are stored separately at:

- `~/.openclaw/workspace-<agentId>/`

## Sessions

The `sessions/` folders are runtime-owned and will change frequently.

## Source of Truth

The authoritative agent list and permissions are defined in:

- `~/.openclaw/openclaw.json`
