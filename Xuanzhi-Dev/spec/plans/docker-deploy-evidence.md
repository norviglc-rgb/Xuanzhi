# Docker Clone-Only Deployment Evidence

Date: 2026-03-20  
Container: `xuanzhi-fullval`  
Image: `ghcr.io/openclaw/openclaw:latest`

## Deployment Facts

1. Started clean container:
   - `docker run -d --name xuanzhi-fullval --entrypoint sh ghcr.io/openclaw/openclaw:latest -c "tail -f /dev/null"`
2. Verified runtime tools:
   - `openclaw --version` -> `OpenClaw 2026.3.13`
   - `git` exists in container (`/usr/bin/git`)
3. Clone-only deployment to runtime root:
   - `git clone https://github.com/norviglc-rgb/Xuanzhi.git /home/node/.openclaw`
   - Deployed commit: `8c812b2`
4. OpenRouter credential injection:
   - runtime command used `-e OPENROUTER_API_KEY=...`
   - no key persisted into repo files.

## Connectivity and Agent Smoke

- Command:
  - `openclaw agent --agent orchestrator --message 'docker clone-only deploy smoke test' --timeout 120 --json`
- Result:
  - provider reached, but payload returned policy/endpoint error:
  - `404 No endpoints available matching your guardrail restrictions and data policy`
  - `meta.stopReason = error`

## Full Unit Test Execution (inside container)

- Command:
  - `python3 -m unittest discover -s tests -p '*.py' -v`
- Result summary:
  - Total: 34
  - Passed: 31
  - Skipped: 1 (`test_docker_openrouter_e2e` gated)
  - Failed: 2

Failed details:
- `test_model_failover_audit`:
  - reason: `FileNotFoundError: pwsh`
- `test_workflow_runtime_replay`:
  - reason: `FileNotFoundError: powershell`

## Agent Coverage Snapshot

Executed agents: `orchestrator`, `critic`, `architect`, `ops`, `skills-smith`, `agent-smith`, `claude-code`.

Observed common issues:
- frequent `gateway closed`, fallback to embedded;
- OpenRouter `rate_limit` / `USD spend limit exceeded` / policy 404;
- tools allowlist warning: unknown entries `apply_patch`, `image`.

These findings are tracked in `release-fix-checklist.md` as RG-12 ~ RG-15.
