# 需求 -> 实现证据追踪骨架

说明：这是 `stp-r1/s1` 的骨架版追踪矩阵，先覆盖主干需求与可定位的实现证据路径，后续可按同一编号继续拆细。

| 需求编号/摘要 | 当前实现路径 | 状态 | 备注 |
| --- | --- | --- | --- |
| R-01 拓扑：`orchestrator` / `architect` / `ops` / `daily-<userId>` / `skills-smith` / `agent-smith` / `critic` / `claude-code` / `subagents` 分层 | `D:\Xuanzhi\openclaw.json`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\state\agents\catalog.json`；`D:\Xuanzhi\workspace-orchestrator\AGENTS.md` | covered | 核心角色已注册且有独立 workspace；`subagents` 仍偏规范层，后续可补执行证据。 |
| R-02 角色职责：各 Agent 只做本职责内的事，边界清晰 | `D:\Xuanzhi\workspace-orchestrator\AGENTS.md`；`D:\Xuanzhi\workspace-critic\IDENTITY.md`；`D:\Xuanzhi\workspace-ops\AGENTS.md`；`D:\Xuanzhi\workspace-agent-smith\AGENTS.md`；`D:\Xuanzhi\workspace-skills-smith\AGENTS.md`；`D:\Xuanzhi\workspace-claude-code\AGENTS.md` | covered | 职责、禁止事项和协作意识已文件化，适合继续往约束/验证细拆。 |
| R-03 单一真相源：文档、policy/schema/workflow、state、审计分层 | `D:\Xuanzhi\openclaw.json`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\templates\daily-template\policies\memory-policy.json`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\state\agents\catalog.json` | partial | 已看到文件化分层和 memory policy，但 active runtime 里的 `docs/system` / `state` / `workflows` 主落点还不完整。 |
| R-04 工作流：路由、handoff、daily provisioning、memory promote 等可执行链路 | `D:\Xuanzhi\workspace-architect\docs\handoff-checklist.md`；`D:\Xuanzhi\workspace-critic\docs\review-checklist.md`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\templates\daily-template\policies\memory-policy.json` | partial | 已有 handoff/review/promotion 的骨架，后续可继续补具体 workflow JSON 与状态流转。 |
| R-05 审计：决策、复核、状态更新和结果可追溯 | `D:\Xuanzhi\workspace-critic\docs\review-decision-template.json`；`D:\Xuanzhi\workspace-critic\docs\review-checklist.md`；`D:\Xuanzhi\openclaw.json` | partial | 审查输出模板和权限控制已具备，但审计落库/索引层还需要继续补齐。 |
| R-06 review gate：`critic` 作为独立质量与风险门禁 | `D:\Xuanzhi\workspace-critic\IDENTITY.md`；`D:\Xuanzhi\workspace-critic\docs\review-checklist.md`；`D:\Xuanzhi\workspace-critic\docs\review-decision-template.json`；`D:\Xuanzhi\openclaw.json` | covered | `critic` 的角色、只读边界、检查清单和决策模板都已明确。 |
| R-07 daily 用户隔离：按用户独立实例化，不共享长期记忆 | `D:\Xuanzhi\Xuanzhi-Dev\legacy-root\templates\daily-template\IDENTITY.md.tpl`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\templates\daily-template\policies\memory-policy.json`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\state\users\index.json` | partial | 模板和 memory policy 已明确“单用户 + 轻能力 + 记忆隔离”，但当前用户索引仍是空种子。 |
| R-08 复杂任务升级链路：`orchestrator -> architect -> claude-code -> critic` | `D:\Xuanzhi\workspace-orchestrator\AGENTS.md`；`D:\Xuanzhi\workspace-architect\docs\handoff-checklist.md`；`D:\Xuanzhi\workspace-claude-code\AGENTS.md`；`D:\Xuanzhi\workspace-critic\docs\review-checklist.md`；`D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m6-handoff-artifacts-spec.md` | partial | 链路节点和 handoff 要求已可追踪，后续可继续补实际执行样例与回流闭环。 |
| R-09 skills / agent 管理：Skills 与 Agent 的创建、维护、模板治理 | `D:\Xuanzhi\workspace-skills-smith\AGENTS.md`；`D:\Xuanzhi\workspace-agent-smith\AGENTS.md`；`D:\Xuanzhi\openclaw.json` | partial | 职责边界已明确，尚需补 skill/agent 目录级工件与变更审计。 |
| R-10 运维与部署：巡检、日志、CI/CD、安装、部署、生命周期管理 | `D:\Xuanzhi\workspace-ops\AGENTS.md`；`D:\Xuanzhi\openclaw.json`；`D:\Xuanzhi\workspace-critic\docs\review-checklist.md` | partial | `ops` 的执行权限和职责已明确，但部署/安装工作流证据仍偏薄。 |
| R-11 用户实例创建：`daily-<userId>` 生成、绑定更新、审查后上线 | `D:\Xuanzhi\Xuanzhi-Dev\legacy-root\templates\daily-template\IDENTITY.md.tpl`；`D:\Xuanzhi\Xuanzhi-Dev\legacy-root\state\users\index.json`；`D:\Xuanzhi\workspace-ops\AGENTS.md` | partial | 创建输入、实例化目标和生命周期责任已出现，后续可按步骤拆成输入/输出/验收子条目。 |

可继续扩展的入口：后续按 `R-01 ~ R-11` 逐条补充“实现证据 / 缺口 / 验证动作”，即可从骨架扩成完整矩阵。
