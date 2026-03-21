# R4 Real User Interaction Test Plan

Date: 2026-03-21  
Owner: main agent (plan/review), execution by ops/orchestrator with manual user-like turns

## Goal

在 Docker 与远程生产态中，以真实用户交互方式验证 OpenClaw，而不是仅依赖脚本/单元测试。  
所有关键能力都必须经过“用户发消息 -> agent响应 -> 结果核验 -> 证据留存 -> 缺陷回流”闭环。

## Hard Rules

1. 每个场景必须至少包含 2-5 轮自然语言对话。
2. 每个场景必须有明确“用户真实目标”，不能只发技术探针消息。
3. 测试入口必须是 `openclaw agent --local`（或远程同等真实入口）。
4. 每个场景必须记录：请求文本、agent、session-id、stopReason、结论、证据路径。
5. 失败必须先记入 `release-fix-checklist.md`，修复后重测同一场景。
6. 任何 `stopReason=error` 都不能按通过处理，除非被明确归类为外部 provider 限制且有 failover 审计证据。

## Acceptance Gate (R4 must pass)

- 总场景数 >= 24（Docker >= 16，远程 >= 8）。
- P0 场景通过率 100%。
- 全场景通过率 >= 90%，且剩余失败项必须有书面豁免与风险说明。
- orchestrator / skills-smith / ops / critic / daily-user 全部至少各通过 2 个真实交互场景。
- 至少 1 组跨 agent 协同链路（orchestrator -> skills-smith -> ops -> critic）完整闭环通过。

## Scenario Matrix

| id | priority | agent/path | real user intent | turn count | pass criteria |
| --- | --- | --- | --- | --- | --- |
| RU-01 | P0 | orchestrator | 让系统先总结当前目标并给下一步建议 | 2 | 目标摘要准确、建议可执行、无错误停止 |
| RU-02 | P0 | orchestrator | 要求制定当日发布推进计划并排序风险 | 3 | 输出有优先级、含风险与依赖 |
| RU-03 | P0 | orchestrator | 多轮追问同一计划细节（时限/负责人） | 4 | 上下文连续、回答一致 |
| RU-04 | P0 | skills-smith | 让其生成新技能草案（含输入输出和风险） | 3 | 技能结构完整、可执行 |
| RU-05 | P0 | skills-smith | 让其比较两种技能方案并给取舍建议 | 3 | 明确 trade-off 和推荐理由 |
| RU-06 | P0 | ops | 让其做只读健康检查并给结论 | 2 | 不越权写操作、结论可追溯 |
| RU-07 | P0 | ops | 请求修复一个已知缺口并给回滚点 | 3 | 提供修复步骤+回滚策略 |
| RU-08 | P0 | critic | 提交一组证据让其做 go/no-go 评审 | 2 | 能识别 blocker 并说明原因 |
| RU-09 | P0 | daily-user | 创建/验证 daily 用户任务执行 | 3 | 用户隔离、权限边界正确 |
| RU-10 | P0 | cross-agent | 让 orchestrator 发起跨 agent 协同任务 | 4 | 任务链条完整、状态一致 |
| RU-11 | P1 | orchestrator | 给出模糊需求，观察澄清问题质量 | 3 | 澄清问题准确、不过度发散 |
| RU-12 | P1 | skills-smith | 让其输出失败场景下的降级方案 | 3 | 降级策略明确、可回放 |
| RU-13 | P1 | ops | 模拟 provider 受限，检查错误归因 | 2 | 能区分外部限制与内部故障 |
| RU-14 | P1 | critic | 提供不完整证据，验证 gate 阻断 | 2 | 明确拒绝并指出缺失项 |
| RU-15 | P1 | daily-user | 同时创建两个 daily 用户并验证隔离 | 4 | 数据/权限不串线 |
| RU-16 | P1 | cross-agent | 触发失败后重试，验证恢复流程 | 4 | 重试链可观测，状态一致 |
| RU-17 | P1 | orchestrator | 极短 timeout 压测，验证受控失败 | 2 | 失败可解释、不会假通过 |
| RU-18 | P1 | ops | 非法 agent 名称输入，验证拒绝行为 | 2 | 明确拒绝，无异常副作用 |
| RU-19 | P2 | skills-smith | 请求生成复杂技能并压缩为最小可行版 | 3 | 结果简化合理，边界清晰 |
| RU-20 | P2 | critic | 让其比较两次评审结果一致性 | 3 | 结论前后一致 |
| RU-21 | P2 | daily-user | 长会话记忆（同 session 多轮） | 5 | session 粘性正确 |
| RU-22 | P2 | cross-agent | 并发任务冲突下的调度稳定性 | 4 | 无混乱分配，冲突有处理 |
| RU-23 | P2 | remote mirror | 远程环境同场景复测差异分析 | 2 | 差异记录完整 |
| RU-24 | P2 | remote mirror | 远程全链路回归后的最终复核 | 2 | 与 Docker 结论一致或有解释 |

## Evidence Requirements

每个场景必须产出以下最小证据：

- 原始输入消息与时间戳
- 原始输出 JSON（含 `meta.stopReason`、`sessionId`、provider/model）
- 结果判定（pass/fail）与判定依据
- 审计日志引用（如 model failover / hooks / startup integrity）
- 问题回流条目（若失败，对应 RG 编号）

建议统一报告文件：

- Docker: `logs/tests/real-user-interaction-docker-report.json`
- Remote: `logs/tests/real-user-interaction-remote-report.json`
- 汇总: `Xuanzhi-Dev/spec/plans/r4-real-user-interaction-summary.md`

## Execution Order

1. 先执行 Docker P0 场景（RU-01..RU-10）。
2. P0 全通过后执行 Docker P1/P2。
3. 关闭 Docker 缺陷后，在 `lc@10.0.1.70` 按同矩阵复测 RU-01..RU-24（至少抽样 + 高风险全量）。
4. 形成汇总报告并进入 release verdict。
