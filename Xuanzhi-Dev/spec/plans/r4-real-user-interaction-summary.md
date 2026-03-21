# R4 Real User Interaction Summary

Date: 2026-03-21  
Scope: Docker manual user-like turns (phase-1)

## Run Result

- Status: `blocked`
- Completed scenarios: `16/24`
- Pass rate: `75.0%` (12 pass / 4 fail, 含历史失败复测通过项)

## What Was Executed

1. Docker container started from `ghcr.io/openclaw/openclaw:latest`.
2. Deployed via real user path: `git clone /repo ~/.openclaw`.
3. Early stage used direct key path for OpenRouter runtime tests.
4. Then switched to MiniMax-first runtime config and validated real calls:
   - primary: `minimax/MiniMax-M2.5`
   - fallback: `minimax/MiniMax-M2.7`
5. Sent real prompts to OpenClaw:
   - agent: `orchestrator`
   - command: `openclaw agent --local --agent <id> --message "...真实需求消息..." --timeout 120 --json`
6. Executed controlled negative/robustness scenarios:
   - invalid agent rejection
   - short-timeout controlled failure
7. Executed additional P0 scenarios and rechecks:
   - pass: RU-02, RU-03, RU-05, RU-07-R2, RU-08-R2, RU-09-R2, RU-10
   - historical fails retained for审计: RU-07, RU-08, RU-09 (已通过复测闭环)

## Blocking Findings

1. MiniMax 主路径已打通，实测 provider/model 为 `minimax / MiniMax-M2.5`，且不再依赖 highspeed。
2. Docker P0 场景现已形成闭环（含 RU-07/RU-08/RU-09 复测通过）。
3. 仍需处理工程一致性问题：`git clone /repo` 只拿已提交版本；未提交配置改动不会进入容器，需要显式覆盖或先提交。

## Evidence

- Raw run evidence captured in:
  - `Xuanzhi-Dev/testing/artifacts/logs/tests/real-user-interaction-docker-report.json`

## Required Next Step

- 进入远程镜像环境复测（lc@10.0.1.70），并继续完成 P1/P2 场景与最终发布判定。
