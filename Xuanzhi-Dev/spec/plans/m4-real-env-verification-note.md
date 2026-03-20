# M4 Real Environment Verification Note

Date: 2026-03-20
Milestone: `m4`
Step: `s4` (`完成真实测试环境等价验证`)
Target: `lc@10.0.1.70`

## Goal

Clean the potentially contaminated real equivalent environment based on observed runtime facts, then verify it remains runnable.

## Access Fact

- SSH login path:
  - `ssh -i C:\Users\LC---\.ssh\id_rsa lc@10.0.1.70`
- Connected host:
  - `UbuntuServer-V`

## Fact-Based Contamination Findings

Observed under `~/.openclaw`:

- historical repository-derived directories:
  - `architect`, `canvas`, `docs`, `ops`, `policies`, `review`, `schemas`, `scripts`, `system`, `templates`, `workflows`
- accumulated runtime traces:
  - `agents/main/sessions/*`
  - `agents/agent-smith/sessions/*`
  - `logs/*`
- stale config backup files:
  - `openclaw.json.bak*`
  - `openclaw.json.pre-multiagent`

## Cleanup Actions

1. Created remote backup before cleanup:
   - `/home/lc/cleanup-backups/openclaw-preclean-20260320-181522.tgz`
2. Removed the historical repository-derived directories listed above.
3. Cleared session/log volatile files while keeping directory structure.
4. Removed stale `openclaw.json` backup artifacts.
5. Preserved active runtime essentials:
   - `openclaw.json`
   - `agents`, `credentials`, `cron`, `extensions`, `feishu`, `identity`, `memory`, `skills`, `state`, `workspace`, `workspaces`

## Verification

- Remaining top-level runtime dirs are clean and minimal:
  - `agents`, `credentials`, `cron`, `devices`, `extensions`, `feishu`, `identity`, `logs`, `memory`, `skills`, `state`, `workspace`, `workspaces`
- Removed historical dirs validation:
  - `removed_ok = True`
- Gateway liveness:
  - `curl -fsS http://127.0.0.1:18789/healthz` -> `{"ok":true,"status":"live"}`
- OpenClaw CLI availability:
  - `~/.npm-global/bin/openclaw --version` -> `OpenClaw 2026.3.13 (61d171a)`

## Status

`m4/s4` is passed.
