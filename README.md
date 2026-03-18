# OpenClaw Multi-Agent System v1 Skeleton

This repository is a minimum viable skeleton for an OpenClaw-based multi-agent system.

## Topology
- orchestrator
- critic
- architect
- ops
- skills-smith
- agent-smith
- claude-code (ACP)
- daily-<userId> instances created from template

## Source of truth layers
- docs/system/ARCHITECTURE.md
- docs/system/GOVERNANCE.md
- policies/*.json
- schemas/*.json
- state/*.json
- database for index/audit only

## Next steps
1. Bind these files to your OpenClaw workspaces.
2. Wire `ops` to `workflows/users/create-daily-user.json`.
3. Register `claude-code` as ACP runtime.
4. Add your real bindings and sandbox/tool policies.
