# Product Test Matrix

每个能力点都必须附带清晰的测试用例 ID、输入、步骤、期望输出、失败判定和重做策略，以便 orchestrator、skills-smith、ops、critic 等 agent 能按计划执行并复现结果。

## Orchestrator 调度

### ORCH-01：资源感知调度（高优先级 P0）
- 输入：`release-fix-checklist` 中的 P0 缺口条目、当前集群剩余 CPU 1 核 / 内存 2G、orchestrator 调度策略 (优先级、并发限额)。
- 步骤：
  1. 触发 orchestrator 计划，在 `stp-r4-release-fix-closure.steps.s1` 中标记 P0 任务。
  2. 观察 orchestrator 将 agent 派发到 `workspace-ops`，并记录下调度时间戳、资源标签与启动命令。
  3. 在 agent 状态中确认 `assigned_agent`、`step_id` 与 `attempt` 匹配。
- 期望输出：ops agent 被分配后 30 秒内开始执行，调度记录显示资源配额符合输入限制，调度日志写入 `plan_state`。
- 失败判定：调度延迟超过 5 分钟、被分配 agent 与 step ID 不一致或资源超限都算失败。
- 重做策略：重启 orchestrator 调度服务并重跑该 step，对比调度记录确保重新计算后的计划在资源预算内。

### ORCH-02：失败回滚与重试队列
- 输入：模拟 ops agent 因状态锁定失败，返回 `status: failed` 与 `retryable: true`；orchestrator 的失败阈值设置为 2 次。
- 步骤：
  1. 向 orchestrator 提交失败事件，确保 `last_error` 字段注明状态争用。
  2. 检查 orchestrator 是否将该 step 推入重试队列，而非绕过。
  3. 等待 orchestrator 重新派发 agent，记录 `retry_count` 与 `scheduled_at`。
- 期望输出：orchestrator 在 60 秒内重新调度，`retry_count` 递增且执行上下文保持一致。
- 失败判定：未重试、重试时间超过 2 分钟或步骤上下文变化。
- 重做策略：手动清除 step lock 并重新注入失败事件，然后观察 orchestrator 能否自动完成第 2 次调度。

## Skills-Smith 生成与评估

### SMITH-01：候选链生成与优先级排序
- 输入：需求 HOOK 清单、当前状态 `r4` 所需修复点、已有技能版本与成本估算。
- 步骤：
  1. 触发 skills-smith 生成候选技能链（包括 orchestrator -> ops -> critic）。
  2. 验证生成结果中每个候选包含 `skills`, `estimated_success`, `risk_profile` 字段。
  3. 检查排序逻辑是否将 P0 配置在前，且整体成本低于 15 分钟。
- 期望输出：生成列表按优先级排序，至少一个链路覆盖 `ops guard` 检查，`estimated_success >= 85%`。
- 失败判定：候选链未覆盖 P0、估算缺失或排序与风险字段不一致。
- 重做策略：更新技能库配置（如 `skill.weight`），再次运行生成流程并比对两个 run 的差异。

### SMITH-02：生成链评估恒定语义
- 输入：skills-smith 生成结果与现网 `plan_state` 对应 entry，含 `state_hash`。
- 步骤：
  1. 选取已生成链路并运行 skills-smith 内部的评估模块。
  2. 模拟 `state_hash` 变更，并确保评估对不同版本标记出不同的 `evaluation_outcome`。
  3. 确认 `evaluation_outcome` 里的 `pass`, `warn`, `blocker` 逻辑符合预期。
- 期望输出：评估结果准确识别 `state_hash` 变化，blocker 值为 true 时链路不会被载入执行列表。
- 失败判定：state 变动后仍然以 `pass` 通过，或评估结果字段缺失。
- 重做策略：回退评估模块至上一版本并重新跑一次，检查差异是否被剔除。

## Ops 执行与 Guard

### OPS-01：Guard Checklist 执行
- 输入：`release-fix-checklist` 中 RG-01, RG-02 条目、ops guard 策略文件（包含 `certificate_check` 与 `log_snapshot`）。
- 步骤：
  1. ops agent 执行 RG-01, RG-02，对照 guard checklist 每项逐条确认。
  2. 所有 guard 符合时生成 `guard_report` 并附带 `log_snapshot`。
  3. 通过 orchestrator 通知 critic gate.
- 期望输出：guard 报告显示 `certificate_check`/`log_snapshot` 状态为 success，且 `guard_report` 写入 `plan_state`.
- 失败判定：任一 guard 条目失败、报告未生成或缺少审计数据。
- 重做策略：在 ops agent 上恢复 guard 状态（如重新加载凭证），并重新运行 guard 流程。

### OPS-02：ops 日志链路与回滚点
- 输入：ops agent 执行日志、ops guard 里定义的 `rollback_hooks`。
- 步骤：
  1. 在执行过程中调用预设 `rollback_hooks`，记录 `pre_commit` 与 `post_commit` 的状态快照。
  2. 故意触发 `check_point` 失败（如检测到文件不一致），观察 ops 是否触发回滚。
  3. 验证 `rollback_hooks` 生成的快照是否被写入 `state_store`。
- 期望输出：失败后 ops 记录 `rollback_state`, 把状态还原到最新成功点，并在 `plan_state` 中标记 `rolled_back: true`。
- 失败判定：回滚未触发或状态快照缺失。
- 重做策略：清除 `rollback_state` 和锁后依次重新执行 Guard 和 rollback 流程。

## Critic Review Gate

### CRITIC-01：go/no-go 审核
- 输入：ops guard 报告、orchestrator 的 `plan_state`、critic gate 的 `review_template`。
- 步骤：
  1. 将 guard 报告与 evidence 一起提交给 critic gate。
  2. critic 进行自动审查，并生成 `critic_review` 包含 `confidence`, `issues`。
  3. 如果 `issues` 中存在 blocker，则拒绝发布。
- 期望输出：critic gate 在 2 分钟内产出结论，`confident` >= 90%，并在 `plan_state` 里写入 `critic_review`.
- 失败判定：未在 5 分钟内输出、confidence 缺失或 blocker 未被捕捉。
- 重做策略：补充缺失的 evidence 并重新提交，或回滚至上一个 guard 版本并再次提交。

## Agent 协同链路

### COLLAB-01：跨 agent 上下文一致
- 输入：orchestrator plan bundle（包含 `step_id`, `context_hash`）、skills-smith 的 candidate, ops guard 报告。
- 步骤：
  1. 逐步跟踪 orchestrator -> skills-smith -> ops -> critic 的 `context_hash` 流转。
  2. 确认每个 agent 在 `plan_state` 中写入的 `noop` 标记一致。
  3. 拉取 agent 状态，确认 `parent_step` / `child_step` 关系齐全。
- 期望输出：链路中 context hash 恒定、parent/child 关系完整、没有丢失的 agent 状态。
- 失败判定：context 替换、状态缺失、agent 间未对齐。
- 重做策略：清空 `plan_state` 相关上下文并重放 orchestrator 执行，验证链路重新打通。

## 状态一致性

### STATE-01：Plan 与 Agent 存储一致
- 输入：plan 状态 JSON、agent state store snapshots、锁机制配置。
- 步骤：
  1. 在 orchestrator 提交 `plan_state` 时截获 snapshot，并与 agent state store 做 diff。
  2. 注入一致性校验脚本，确认 `plan_state`、`agent_state` 中的 `status`, `revision`, `timestamp` 匹配。
  3. 人为制造 `revision` 不一致（例如 agent 回写旧 revision），验证监测报告。
- 期望输出：snapshot diff 为 0，若 revision 不一致系统触发警报并阻断 go/no-go。
- 失败判定：snapshot 差异未被捕捉或 inconsistent revision 仍执行。
- 重做策略：更新 agent state store，重试写入并验证一致性，必要时报警到 ops。

## Skill 自动调用条件

### AUTO-01：触发条件与前置 Guard
- 输入：技能配置中的触发条件、前置 guard（如 `guard_status == success`）、当前 `plan_state`。
- 步骤：
  1. 修改 `plan_state` 使 guard_status 为 fail，尝试自动触发目标 skill。
  2. 观察 orchestrator 是否抛弃 trigger，并在日志写入拒绝原因。
  3. 将 guard_status 改回 success，重新触发 skill，记录调用链。
- 期望输出：guard_status fail 时 skill 不会被激活；success 后能自动执行并写入 `call_trace`.
- 失败判定：guard_status fail 仍然执行，或 success 状态下未绑定 call trace。
- 重做策略：清空 trigger cache，重新评估 guard condition，再次执行调用过程。

## 模型切换与低能力韧性

### MODEL-01：模型切换统一审计
- 输入：`Xuanzhi-Dev/testing/scripts/sync-openrouter-free-models.ps1 -Probe`，可用 OpenRouter key。
- 步骤：
  1. 运行 probe，触发 primary/fallback 探测。
  2. 检查 `logs/audit/model-failover.jsonl`。
  3. 验证 success/failure 事件是否都落盘，且字段完整。
- 期望输出：每条事件包含 `requestId/source/target/action/decision/timestamp`，并附带 model/reason/errorCode。
- 失败判定：事件缺失、字段缺失、或出现敏感信息明文泄露。
- 重做策略：修复审计写入逻辑并重跑 probe，对比前后事件链。

### MODEL-02：Docker 带凭据回归（弱模型容错）
- 输入：`RUN_PRODUCT_TESTS_DOCKER_OPENROUTER_E2E=1`，`OPENROUTER_API_KEY`，Docker 可用。
- 步骤：
  1. 执行 `run-product-tests.ps1` 触发 docker e2e。
  2. 观察容器内调用是否可用，失败时是否走 fallback 探测链路。
  3. 检查统一审计日志是否记录本次 e2e 结果。
- 期望输出：e2e 可复现执行；即使主模型受限，也能在 fallback 下完成可观测调用或明确失败原因。
- 失败判定：容器流程不稳定、无审计留痕、失败原因不可定位。
- 重做策略：固定容器复制/权限步骤、重跑并对照审计事件补齐缺失字段。
