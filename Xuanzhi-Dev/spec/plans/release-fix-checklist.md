# Release Fix Checklist (R4)

Date: 2026-03-20
Owner: main agent (planning/review), execution by sub-agents
Current Release Verdict: `NO-GO`

## Must Fix Before Release (P0)

| id | issue | required fix | owner | status |
| --- | --- | --- | --- | --- |
| RG-01 | runtime single-source-of-truth landing incomplete | promote `docs/system` + `policies` + `schemas` + `workflows` + `state` to active runtime and update all references | architect + ops | todo |
| RG-02 | key workflows lack executable evidence | materialize runnable entries for `materialize-core-agents`, `create-daily-user`, `memory-promote` with replayable state/audit/review chain | ops + agent-smith + critic | todo |

## Should Fix Before Release (P1)

| id | issue | required fix | owner | status |
| --- | --- | --- | --- | --- |
| RG-03 | audit envelope/path not unified | normalize audit schema and write-path policy across hooks/workflows/state | ops + critic | todo |
| RG-04 | multi-user daily isolation proof missing | create at least two daily users and isolation/denial test case | ops + critic | todo |
| RG-05 | skills/agent lifecycle evidence incomplete | add one replayable create/update/review/audit lifecycle proof | skills-smith + agent-smith | todo |
| RG-06 | deploy/runbook evidence weak | add minimal reproducible ops runbook with audit and review linkage | ops | todo |
| RG-08 | internal hooks lack repo-side version baseline | add version pin + behavior baseline artifacts for `command-logger` and `boot-md` | ops | todo |
| RG-09 | allowlist includes daily scopes without real targets | materialize `workspace-daily-*` + `agents/daily-*` or shrink scopes with explicit rationale | ops + agent-smith | todo |

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
