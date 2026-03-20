# Runtime Agents

This directory contains documentation about the agent system.

## Actual Agent Locations

The actual agent workspaces are located at:
- **OpenClaw default**: `~/.openclaw/agents/<agentId>/`
- **Custom location**: As configured in `openclaw.json`

## Repository Role

This repository maintains:
- **Templates**: `templates/` - Agent templates for creating new agents
- **State**: `state/` - Live runtime state
- **Workflows**: `workflows/` - Agent materialization workflows

## Sessions

Agent `sessions/` directories are runtime-only and NOT stored in this repository.
They are generated and maintained by OpenClaw at runtime.

## Agent Catalog

See `state/agents/catalog.json` for the agent registry.
