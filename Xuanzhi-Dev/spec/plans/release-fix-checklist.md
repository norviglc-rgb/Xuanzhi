# Release Fix Checklist (R4)

Date: 2026-03-20
Owner: main agent (planning/review), execution by sub-agents
Current Release Verdict: `NO-GO`

## Must Fix Before Release (P0)

| id | issue | required fix | owner | status |
| --- | --- | --- | --- | --- |
| RG-01 | runtime single-source-of-truth landing incomplete | promote `docs/system` + `policies` + `schemas` + `workflows` + `state` to active runtime and update all references | architect + ops | done_candidate |
| RG-02 | key workflows lack executable evidence | materialize runnable entries for `materialize-core-agents`, `create-daily-user`, `memory-promote` with replayable state/audit/review chain | ops + agent-smith + critic | done_candidate |

## Should Fix Before Release (P1)

| id | issue | required fix | owner | status |
| --- | --- | --- | --- | --- |
| RG-03 | audit envelope/path not unified | normalize audit schema and write-path policy across hooks/workflows/state | ops + critic | in_progress |
| RG-04 | multi-user daily isolation proof missing | create at least two daily users and isolation/denial test case | ops + critic | todo |
| RG-05 | skills/agent lifecycle evidence incomplete | add one replayable create/update/review/audit lifecycle proof | skills-smith + agent-smith | todo |
| RG-06 | deploy/runbook evidence weak | add minimal reproducible ops runbook with audit and review linkage | ops | todo |
| RG-08 | internal hooks lack repo-side version baseline | add version pin + behavior baseline artifacts for `command-logger` and `boot-md` | ops | todo |
| RG-09 | allowlist includes daily scopes without real targets | materialize `workspace-daily-*` + `agents/daily-*` or shrink scopes with explicit rationale | ops + agent-smith | todo |
| RG-11 | clone-only 部署与全量深测证据不足 | 在 Docker 与远程生产态按 clone 到 `~/.openclaw` 的真实路径完成全量测试并留证 | ops + orchestrator + critic | in_progress |
| RG-12 | Linux 容器测试依赖 powershell/pwsh，导致回放测试不可运行 | 让测试在无 PowerShell 时可跳过或提供跨平台执行路径 | ops | in_progress |
| RG-13 | OpenRouter 鉴权/策略限制下 agent 返回 `stopReason=error`，但回归可能误判通过 | Docker E2E 必须解析 JSON `stopReason` 与 payload，不允许仅看 exit code | ops + critic | in_progress |
| RG-14 | tools allowlist 含当前运行时不可用工具（`apply_patch`, `image`）引发噪音与潜在误导 | 统一工具基线并按 provider/runtime 校验 allowlist | architect + ops | todo |
| RG-15 | 容器内 gateway 长期 closed，链路常态回落 embedded | 明确 gateway 运行策略并补健康探针/失败分级 | ops | todo |

## Nice To Have Before Release (P2)

| id | issue | required fix | owner | status |
| --- | --- | --- | --- | --- |
| RG-07 | one-command Docker copy-and-run reproducibility missing | provide single-entry Docker reproduction script/runbook | ops | todo |
| RG-10 | docker copy ownership friction | enforce ownership normalization during copy/import | ops | todo |

## R4 Execution Chain

1. Fix P0 items and produce rerun evidence.
2. Re-run Docker E2E with authenticated agent boot.
3. Close or explicitly waive P1/P2 with written risk acceptance.
4. Generate final release decision report (`go` or `no-go`).
