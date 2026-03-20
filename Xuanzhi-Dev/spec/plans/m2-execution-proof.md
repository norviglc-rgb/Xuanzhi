# M2 S4 Minimal Execution Proof (Dry-Run)

## Status

- milestone: `m2`
- step: `s4`
- type: structured dry-run proof
- runtime mutation: none

## Purpose

在不改动 runtime 的前提下，基于以下文档证明创建一个新 agent 的执行闭环可成立：

- `agent-creation-contract.md`（s2）
- `agent-contract-validation-and-rollback.md`（s3）
- 当前 runtime 约定（`openclaw.json` 中 `agents.list` 的字段结构与命名模式）

## Runtime Conventions Used

从当前 `openclaw.json` 可观察到的约定（作为本证明前提）：

1. agent 注册位于 `agents.list[]`。
2. 每个 agent 具有最小字段：`id`、`workspace`、`agentDir`、`tools.allow`、`tools.deny`。
3. 现有命名模式与契约一致：`workspace-<agentId>`、`agents/<agentId>/agent`。
4. 默认 sandbox 位于 `agents.defaults.sandbox`，单 agent 可选 override。

## Sample Agent Input (Contract-Level)

以 `agentId = sample-helper` 为例，输入如下：

| field | value | source/rule |
|---|---|---|
| `id` | `sample-helper` | required, unique |
| `workspace` | `workspace-sample-helper` | `workspace-<agentId>` |
| `agentDir` | `agents/sample-helper/agent` | `agents/<agentId>/agent` |
| `tools.allow` | `["read","sessions_list","sessions_history"]` | required explicit allow |
| `tools.deny` | `["exec","write","edit","apply_patch","browser","canvas"]` | required explicit deny |
| `sandbox` | omitted | optional, default applies |

## Derived Outputs (Must Exist If Execution Succeeds)

按 s2 契约，输入可推出以下最小输出：

1. workspace 根目录：`workspace-sample-helper/`
2. root files：
   `AGENTS.md`、`SOUL.md`、`IDENTITY.md`、`TOOLS.md`、`BOOT.md`、`BOOTSTRAP.md`、`HEARTBEAT.md`、`MEMORY.md`
3. workspace 子目录：`memory/`、`skills/`、`hooks/`、`docs/`
4. runtime 目录：`agents/sample-helper/agent/`、`agents/sample-helper/sessions/`
5. registry 增量：`openclaw.json -> agents.list[]` 新增 `sample-helper` 条目，且字段一致

## Dry-Run Validation Proof

### A. Structure Checks

- `workspace-sample-helper/` exists -> pass
- required root files all exist -> pass
- required directories all exist -> pass
- `agents/sample-helper/agent/` exists -> pass
- `agents/sample-helper/sessions/` exists -> pass

### B. Registry Checks

- `openclaw.json` contains `id=sample-helper` -> pass
- `workspace` matches `workspace-sample-helper` pattern -> pass
- `agentDir` matches `agents/sample-helper/agent` pattern -> pass
- `tools.allow` exists -> pass
- `tools.deny` exists -> pass

### C. Boundary Checks

- no `workspaces/workspace-sample-helper` deprecated path introduced -> pass
- no `templates/core-agent/*` generic dependency introduced -> pass
- no role-specific extras promoted to generic minimum -> pass

结论：在上述前提下，`sample-helper` 的最小创建流程可通过 s3 定义的 acceptance surface。

## Failure Branch And Rollback Proof

若任一 blocking check 失败（示例：`TOOLS.md` 缺失或 `agentDir` 不匹配），触发 s3 rollback：

1. 删除失败尝试产物：`workspace-sample-helper/`（不完整部分）
2. 删除失败 runtime 产物：`agents/sample-helper/agent/`、`agents/sample-helper/sessions/`（不完整部分）
3. 回滚 registry：移除 `openclaw.json` 中 `sample-helper` 部分条目
4. 保留诊断信息（可选）：失败记录/审查注记，明确标注 failed attempt

回滚后应满足：

- runtime 不再显示 `sample-helper` 为已 provisioned
- registry 无残留 partial entry
- 可安全重试同一 `agentId`

## Minimal Proof Record (Template)

| item | result | note |
|---|---|---|
| input contract complete | pass | required fields present |
| outputs derivable | pass | all mandatory paths/files listed |
| acceptance checks | pass (dry-run) | structure + registry + boundary |
| rollback path | pass | trigger/scope/post-state defined |
| retry safety | pass | same `agentId` reusable after rollback |

---

本文件是结构化 dry-run proof，不构成 runtime 实际变更或 provision 动作。
