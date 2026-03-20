# R3 Docker E2E Report

Date: 2026-03-20
Milestone: `r3`
Container: `xuanzhi-r3-test`

## Scope

- Start gateway from copied runtime in container.
- Validate hooks/guard/review related artifacts.
- Validate `skills-smith`, `ops`, `workspace-critic` key files are present and readable.
- Record pass/fail and release impact.

## E2E Checks

| check | result | evidence |
| --- | --- | --- |
| Gateway starts from copied `~/.openclaw` | pass | startup logs show gateway/canvas/heartbeat/health-monitor start and hooks loader registration |
| `ops-action-guard` startup log emitted | pass | `/home/node/.openclaw/logs/ops-guard.jsonl` contains `gateway_startup_guard_check` with `decision=allow` |
| `workspace-integrity` startup check emitted | pass | `/home/node/.openclaw/logs/startup-integrity.jsonl` appended all seven system workspaces with `ok=true` |
| `workspace-critic/docs` review templates available | pass | container path contains `review-checklist.md` and `review-decision-template.json` |
| `ops-action-guard` allowlist validator works | pass | `install_package approved-package-list -> allow`; unknown action -> `deny` |
| Full agent boot run without credentials | fail | gateway boot logs show `No API key found for provider "anthropic"` for all registered agents |

## Key Runtime Evidence

```text
[hooks:loader] Registered hook: boot-md -> gateway:startup
[hooks:loader] Registered hook: command-logger -> command
[hooks:loader] Registered hook: ops-action-guard -> gateway:startup
[hooks:loader] Registered hook: workspace-integrity -> gateway:startup
```

```json
{"requestId":null,"source":"gateway","target":"hooks/ops-action-guard/allowlist.json","action":"gateway_startup_guard_check","decision":"allow","hook":"ops-action-guard"}
```

```json
{"timestamp":"2026-03-20T12:41:29.516Z","workspace":"workspace-ops","ok":true,"missingFiles":[],"missingDirs":[]}
```

## Failures and Risks

1. API key/credentials not provisioned inside container runtime copy, causing agent boot failures.
2. Copy workflow needs explicit ownership normalization (`docker exec -u 0 ... chown`) for stable automation.
3. This run proves runtime structure and guard/integrity behavior, but does not yet prove authenticated multi-agent task execution.

## Release Impact

- `r3`目标（Docker内安装、复制、核心链路可观测）已达到。
- 发布仍受 P0/P1 缺口约束（见 `release-gap-list.md` 与 `release-fix-checklist.md`），当前结论为 `no-go before fixes`.
