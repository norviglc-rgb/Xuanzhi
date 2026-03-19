# GOVERNANCE

## Single source of truth layers
- Architecture truth: `docs/system/ARCHITECTURE.md`
- Governance truth: `docs/system/GOVERNANCE.md`
- Machine-executable truth: `policies/*.json`, `schemas/*.json`, `workflows/*.json`
- Runtime state truth: `state/*.json`
- Audit/index only: database

## Red lines
1. Prompt is not a system source of truth.
2. Database is not a configuration source of truth.
3. Durable rules must exist in docs or machine-readable files.
4. Runtime state must land in `state/*.json` first.
5. Critical changes must be committed to Git.

## Memory rules
- New memory goes to `memory/YYYY-MM-DD.md` first.
- Only durable, validated information enters `MEMORY.md`.
- Secrets, tokens, passwords, raw sensitive dumps, and unverified conclusions are forbidden.

## Routing rules
- chat_or_query -> daily-<userId>
- simple_development -> architect
- ops_or_deployment -> ops
- skill_maintenance -> skills-smith
- agent_maintenance -> agent-smith
- review_or_signoff -> critic
- parallel_research -> subagents
- complex_development -> claude-code via ACP
