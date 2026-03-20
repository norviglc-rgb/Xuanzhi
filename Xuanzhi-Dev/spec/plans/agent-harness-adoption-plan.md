# Agent Harness Adoption Plan (Deferred Until Post-Fix)

Date: 2026-03-20
Status: planned_not_started
Gate: start only after `r4` and `r5` are completed

## Objective

在 Xuanzhi 现有多 agent 体系中引入可执行的 Agent Harness，实现任务编排、状态追踪、回滚与审查闭环的统一承载。

## Why Deferred

- 当前优先级仍是发布前测试与修复闭环（`r4`）。
- 且需先完成 `lc@10.0.1.70` 在线生产态验证（`r5`）。
- 若提前进入 Harness 实现，会分散修复资源并扩大变更面。
- 因此当前阶段只做分解与准备，不进入实现。

## Scope

1. Orchestration Harness
- 标准任务生命周期状态机（queued/running/retry/blocked/done）。
- 调度策略（优先级、重试、并发限额、资源标签）。

2. Evidence Harness
- 统一执行证据格式（requestId/stepId/agentId/result/timestamp）。
- 与审计日志、review gate 对齐。

3. Recovery Harness
- 失败恢复点、回滚快照与重放入口。
- 明确何时自动重试，何时人工介入。

4. Quality Harness
- 把 product-test-matrix 的能力用例映射到可执行 harness 检查项。
- 发布前生成一键验收报告。

## Phase Breakdown

### H0 (planning only, allowed in r4)
- 盘点当前 `EXECUTION-HARNESS.md` 与运行事实差距。
- 输出 Harness 目标能力清单与非目标清单。
- 定义最小可落地版本（MVP）。

### H1 (implementation, blocked until r4 complete)
- 新增 Harness 状态模型与任务执行驱动。
- 接入 orchestrator/ops/critic 的关键链路。
- 打通统一审计与回滚记录。

### H2 (verification and rollout)
- 跑完整 product tests + Docker E2E + real-env 验证。
- 形成迁移/回滚 runbook 与上线判定。

## Entry/Exit Criteria

- Entry:
  - `r4` status = completed
  - `r5` status = completed
  - P0 缺口关闭
  - 发布判定可切换到 go 或明确豁免
- Exit:
  - Harness 能稳定承载 orchestrator -> skills-smith -> ops -> critic 主链路
  - 回滚和重放可用
  - 测试链路可复现
