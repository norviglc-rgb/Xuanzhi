# GOVERNANCE

## Single source of truth layers
- Architecture truth: `docs/system/ARCHITECTURE.md`
- Governance truth: `docs/system/GOVERNANCE.md`
- Naming truth: `docs/system/FILE-NAMING.md`
- Machine-executable truth: `policies/*.json`, `schemas/*.json`, `workflows/*.json`
- Runtime state truth: `state/*.json`
- Audit/index only: `audit/*.jsonl`

## Red lines
1. Prompt is not a system source of truth.
2. Database is not a configuration source of truth.
3. Durable rules must exist in docs or machine-readable files under the root runtime directories.
4. Runtime state must land in `state/*.json` first and be referenced from workflows in `workflows/`.
5. Critical changes committed to Git before trusting automation.

## Memory rules
- New memory goes to `memory/YYYY-MM-DD.md` first; long-term promotions go to `MEMORY.md`.
- Only durable, validated information enters long-term storage.
- Secrets, tokens, passwords, raw sensitive dumps, and unverified conclusions are forbidden everywhere.
- Reference `policies/memory-policy.json` for promotion guardrails before editing `MEMORY.md`.

## Routing rules
- `chat_or_query` -> `daily-<userId>`
- `simple_development` -> `architect`
- `ops_or_deployment` -> `ops`
- `skill_maintenance` -> `skills-smith`
- `agent_maintenance` -> `agent-smith`
- `review_or_signoff` -> `critic`
- `parallel_research` -> `orchestrator` (fallback while subagents runtime is not enabled)
- `complex_development` -> `claude-code` via ACP and the `workflows/memory/promote.json` pathway when promotion is needed
