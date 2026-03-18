# OpenClaw 多 Agent 系统 v1 需求规格

## 1. 目标与范围

### 1.1 项目目标
构建一套基于 OpenClaw 的最小可运行多 Agent 系统，满足以下目标：

1. 支持项目开发自动化，区分简单项目与复杂项目。
2. 支持运维巡检、日志检查、CI/CD、部署、安装与 OpenClaw 自维护。
3. 支持按用户隔离的日常问答与聊天。
4. 支持统一任务拆解、分发、收敛与复盘。
5. 支持按需创建与维护 Skills。
6. 支持按需创建与维护 Agents。
7. 支持复杂开发任务自动升级为 Claude Code ACP 长跑执行。
8. 支持系统自迭代，优先依赖文件化工件、结构化状态与可审计变更。

### 1.2 v1 原则
v1 以 **最小可运行、可自迭代、可审计、可回滚** 为优先目标，不追求一开始就角色极致细分或全自动闭环。

### 1.3 v1 范围内
- 多 Agent 基础拓扑
- 单一真相源分层
- 用户级 daily Agent 实例化
- memory 双层治理
- 复杂任务一级路由到 Claude Code ACP
- 权限最小化
- review-gate
- JSON-first + Git + DB 索引/审计分层

### 1.4 v1 范围外
以下内容不纳入 v1 强制交付：

- 独立 user-admin Agent
- 复杂审批流
- 多租户计费系统
- 大规模权限编排后台
- 全量数据库配置中心
- 高度复杂的图形化运维控制台

---

## 2. 系统拓扑

### 2.1 最终拓扑
系统采用以下拓扑：

- 1 个主控：`orchestrator`
- 3 个常驻执行域：`architect`、`ops`、`daily-<userId>`
- 2 个按需专家域：`skills-smith`、`agent-smith`
- 1 个 review-gate：`critic`
- 1 个 ACP 外部编码域：`claude-code`
- 1 组后台并行执行能力：`subagents`

### 2.2 拓扑原则
1. 主控只做调度与收敛，不承担资源生命周期管理。
2. 执行域负责业务动作，不负责系统模板治理。
3. 专家域负责元编程，不直接承接主线业务任务。
4. complex coding 一律优先走 ACP，而不是 native subagents。
5. daily 按用户隔离，不共享长期记忆。
6. critic 不承担主生产职责，只做质量与风险闸门。

---

## 3. 角色职责

### 3.1 orchestrator
职责：
- 接收任务入口
- 分类任务
- 评估复杂度
- 分解任务
- 分配执行域
- 收敛结果
- 组织复盘

边界：
- 不直接负责用户实例创建
- 不直接承担高风险运维动作
- 不直接承担模板与策略演化

### 3.2 critic
职责：
- 对交付结果进行审查
- 对高风险动作进行风险审查
- 对 memory 升格进行抽检
- 对 Agent / Skill 修改进行合规审查
- 对用户实例创建结果进行轻量验收

边界：
- 默认不参与主线产出
- 默认不承担写生产文件职责
- 默认不承担部署职责

### 3.3 architect
职责：
- 理解需求
- 产出架构设计
- 定义实现边界与验收标准
- 处理简单项目
- 将复杂项目升级路由给 Claude Code ACP
- 生成 handoff 工件

边界：
- 不承担大规模长期编码主执行
- 不承担系统级运维生命周期管理

### 3.4 ops
职责：
- 日志巡检
- 故障诊断
- allowlist 范围内自动执行修复
- CI/CD
- 部署与安装
- OpenClaw 自身 workspace / memory / 运行状态维护
- 基于模板创建新用户 daily 实例
- daily 实例生命周期管理

边界：
- 不负责模板规范定义
- 不负责 Agent 元设计

### 3.5 daily-<userId>
职责：
- 服务单个用户的日常聊天与查询
- 管理该用户的长期偏好与历史上下文
- 进行轻量问答与轻量工作协助

边界：
- 不共享其他用户的记忆
- 默认不具备 exec、部署、广泛文件写权限

### 3.6 skills-smith
职责：
- 创建 Skills
- 维护 Skills
- 提炼可复用流程
- 抽象操作 SOP
- 演化 Skill 模板与版本

边界：
- 不承担运维职责
- 不直接负责用户实例化

### 3.7 agent-smith
职责：
- 创建与维护 Agent 模板
- 维护 Agent 结构规范
- 维护 workspace 模板
- 维护 schema、policy、workflow 模板
- 维护 daily-template

边界：
- 不直接执行用户实例创建
- 不负责日常运维生命周期动作

### 3.8 claude-code
职责：
- 作为复杂开发任务的 ACP 外部编码执行域
- 承担大规模、多轮、长跑编码任务
- 接收 architect 的 handoff 工件持续推进

边界：
- 不负责最终系统调度
- 不负责系统模板设计

### 3.9 subagents
职责：
- 承担并行研究
- 承担慢任务后台处理
- 承担辅助性分析任务

边界：
- 不承接复杂主线开发
- 不作为 ACP 替代品

---

## 4. 单一真相源分层

### 4.1 目标
为避免规则分散、状态失真、后期难以维护，系统采用 **分层单一真相源** 原则。

### 4.2 分层定义

#### 4.2.1 业务与角色真相源
路径：`docs/system/ARCHITECTURE.md`

内容：
- 系统拓扑
- Agent 职责边界
- 协作关系
- 拓扑调整原则

#### 4.2.2 治理规则真相源
路径：`docs/system/GOVERNANCE.md`

内容：
- memory 治理规则
- 路由规则
- review 规则
- Git/JSON/数据库分层规则
- 用户实例化规则
- 审计规则

#### 4.2.3 机器可执行真相源
路径：
- `policies/*.json`
- `schemas/*.json`
- `workflows/*.json`

内容：
- 自动执行规则
- 输入输出约束
- 工作流状态定义
- 校验逻辑

#### 4.2.4 运行状态真相源
路径：`state/*.json`

内容：
- 用户实例索引
- 任务状态
- Agent/Skill catalog
- 路由结果
- 生命周期状态

#### 4.2.5 审计与检索层
存储：数据库

内容：
- 索引
- 审计
- 检索加速
- 统计

边界：
- 数据库不得成为配置真相源
- 数据库不得成为业务规则真相源

### 4.3 强制规则
1. 长期有效职责，必须落到 `ARCHITECTURE.md` 或 `GOVERNANCE.md`。
2. 需要程序执行的规则，必须落到 JSON policy/schema/workflow。
3. 运行时状态，必须落到 `state/*.json`。
4. Prompt 不得承担系统真相源职责。
5. 数据库只做索引与审计，不做主配置源。

---

## 5. Workspace 标准结构

### 5.1 每个 Agent Workspace 的根文件
每个 workspace 至少包含：

- `AGENTS.md`
- `SOUL.md`
- `USER.md`
- `IDENTITY.md`
- `TOOLS.md`
- `HEARTBEAT.md`
- `BOOT.md`
- `BOOTSTRAP.md`
- `MEMORY.md`

### 5.2 标准目录
每个 workspace 建议包含以下目录：

- `memory/`
- `docs/`
- `state/`
- `workflows/`
- `policies/`
- `logs/`
- `reports/`
- `skills/`（仅适用需要自定义 skill 覆盖的 workspace）

### 5.3 docs 目录子结构建议
- `docs/projects/`
- `docs/runbooks/`
- `docs/agents/`
- `docs/skills/`
- `docs/users/`
- `docs/decisions/`
- `docs/incidents/`
- `docs/templates/`
- `docs/system/`

### 5.4 state 目录子结构建议
- `state/users/`
- `state/agents/`
- `state/skills/`
- `state/router/`
- `state/tasks/`
- `state/ops/`
- `state/audit/`

---

## 6. Memory 治理规则

### 6.1 目标
将 memory 视为文件化、可审计、可治理的系统能力，而不是聊天摘要缓存。

### 6.2 双层模型

#### 6.2.1 `memory/YYYY-MM-DD.md`
定位：
- 日志式短期记忆
- 当日上下文
- 调试过程
- 排障轨迹
- 临时观察
- handoff 摘要

规则：
- append-only
- 先写这里，再考虑是否升格

#### 6.2.2 `MEMORY.md`
定位：
- 长期偏好
- 持久决策
- 架构原则
- 用户长期画像
- 稳定环境约束
- 经验证可复用的经验

规则：
- 只收纳 durable 内容
- 不接收大段临时流水

### 6.3 禁止写入 memory 的内容
- token / password / secret
- 原始敏感聊天 dump
- 未验证结论
- 大段临时噪音
- 与长期运行无关的冗余信息

### 6.4 升格规则
1. 新记忆默认先写入 `memory/YYYY-MM-DD.md`。
2. 满足长期价值条件后，才能升格到 `MEMORY.md`。
3. 升格可由 `critic` 抽检，也可由治理工作流执行。

### 6.5 memory 规则的机器化落地
必须提供：
- `policies/memory-policy.json`
- `schemas/memory-entry.schema.json`
- `workflows/memory/promote.json`

---

## 7. 用户实例创建流程

### 7.1 总原则
用户 daily 实例采用 **按用户独立实例化** 方式。

### 7.2 职责分工
- `agent-smith`：维护 daily-template、schema、policy、workflow 模板
- `ops`：执行用户实例创建与生命周期管理
- `critic`：对创建结果做轻量验收
- `orchestrator`：只消费创建结果进行路由，不参与创建动作

### 7.3 创建输入
新用户创建流程至少需要以下输入：
- `userId`
- 显示名
- 初始 persona 设定
- 默认功能边界
- 绑定信息
- 初始 profile 数据

### 7.4 创建流程
1. 触发新用户接入事件。
2. `ops` 读取 `daily-template`。
3. `ops` 调用创建工作流。
4. 生成独立 `daily-<userId>` agent 与 workspace。
5. 初始化以下文件：
   - `AGENTS.md`
   - `SOUL.md`
   - `USER.md`
   - `IDENTITY.md`
   - `TOOLS.md`
   - `MEMORY.md`
   - `profile.json`
   - `memory/`
   - `policies/`
   - `state/`
6. 更新 `state/users/index.json`。
7. 更新 bindings 所需配置。
8. 提交 Git。
9. 写入审计记录。
10. 交给 `critic` 进行轻量验收。
11. 上线该用户实例。

### 7.5 生命周期管理
由 `ops` 负责：
- 停用
- 迁移
- 归档
- 回收
- 恢复
- 例行健康检查

---

## 8. 路由与复杂任务分派规则

### 8.1 入站路由原则
1. 用户消息首先由 bindings 映射到目标 Agent。
2. 用户级 daily 一律绑定到各自独立实例。
3. 多 Agent 选择优先走显式规则，不依赖模糊 prompt 猜测。

### 8.2 主控任务分发规则
`orchestrator` 根据任务类型分发：

- 日常查询/聊天 → `daily-<userId>`
- 简单开发 → `architect`
- 运维/部署/巡检 → `ops`
- Skill 创建维护 → `skills-smith`
- Agent 创建维护 → `agent-smith`
- 审查/验收 → `critic`
- 并行研究 → `subagents`

### 8.3 复杂开发一级路由规则
满足任一条件时，任务升级为复杂开发，优先路由到 `claude-code` ACP：

- 涉及多目录或多模块
- 预计多轮持续编码
- 需要测试/构建/回归
- 涉及大规模重构
- 需要 thread-bound 持续上下文
- architect 判断不应由本地简单执行完成

### 8.4 architect 交接工件要求
在复杂任务转交前，`architect` 至少产出：
- `TASK.json`
- `PLAN.md`
- `DECISIONS.md`
- `ACCEPTANCE.md`
- `NEXT_STEPS.md`

### 8.5 ACP 规则
- 复杂编码任务优先走 ACP runtime
- native subagents 不替代 ACP
- Claude Code 承担长跑实现
- architect 保留架构职责与验收边界定义

---

## 9. 权限最小化矩阵

### 9.1 总原则
- 权限按职责最小化
- 人格与提示不作为安全边界
- 真正能力边界通过 sandbox、tool policy、workflow allowlist 落地

### 9.2 orchestrator
允许：
- 会话控制
- memory 读取
- 消息转发
- 轻量只读能力

默认禁止：
- exec
- 部署
- 广泛文件写入

### 9.3 critic
允许：
- 只读
- memory 检索
- 审查类能力

默认禁止：
- exec
- 生产写操作
- 部署

### 9.4 architect
允许：
- read/write/edit
- 轻量 patch
- 有限执行能力
- 生成 handoff 工件

默认禁止：
- 高风险运维动作
- 广泛部署权限

### 9.5 ops
允许：
- read
- exec
- process control
- allowlist 范围内写/修复/部署
- 用户实例生命周期管理

默认限制：
- 高风险动作必须受 allowlist 和 workflow 约束

### 9.6 daily-<userId>
允许：
- 轻量查询
- memory
- 消息
- 必要只读

默认禁止：
- exec
- 广泛文件写
- 部署
- 运维级动作

### 9.7 skills-smith
允许：
- Skills 相关目录读写
- 模板维护
- 文档维护

默认禁止：
- 部署与运维权限

### 9.8 agent-smith
允许：
- Agent 模板与规范维护
- workspace 模板维护
- schema/policy/workflow 模板维护

默认禁止：
- 用户实例直接创建
- 运维生命周期动作

---

## 10. JSON / Git / 数据库分层规则

### 10.1 JSON-first
系统优先采用 JSON 表达：
- policy
- schema
- workflow
- state
- 索引
- 结构化任务工件

### 10.2 Git 的角色
Git 负责：
- 版本管理
- 审核
- 回滚
- 变更对比
- 历史追踪

### 10.3 数据库的角色
数据库仅负责：
- 索引
- 审计
- 检索加速
- 查询统计

### 10.4 禁止事项
- 不允许数据库成为配置主源
- 不允许数据库成为唯一状态真相源
- 不允许把关键治理规则仅留在 prompt 中

---

## 11. v1 最小文件清单

### 11.1 系统级必须文件
- `docs/system/ARCHITECTURE.md`
- `docs/system/GOVERNANCE.md`
- `policies/routing-policy.json`
- `policies/memory-policy.json`
- `policies/tool-policy-matrix.json`
- `schemas/user-profile.schema.json`
- `schemas/task.schema.json`
- `schemas/review.schema.json`
- `state/users/index.json`
- `state/agents/catalog.json`
- `state/skills/catalog.json`
- `state/router/tasks.json`
- `state/audit/user-provision.jsonl`

### 11.2 architect 关键工件
- `TASK.json`
- `PLAN.md`
- `DECISIONS.md`
- `ACCEPTANCE.md`
- `NEXT_STEPS.md`

### 11.3 ops 关键工件
- `ALLOWLIST.json`
- `RUNBOOK.md`
- `INCIDENT-*.md`
- `DEPLOY-*.md`

### 11.4 review-gate 关键工件
- `REVIEW.md`
- `RISK.md`
- `SIGNOFF.json`

### 11.5 daily 实例关键工件
- `USER.md`
- `MEMORY.md`
- `profile.json`

---

## 12. v1 非目标与后续演进点

### 12.1 v1 非目标
- 独立 user-admin Agent
- 全自动复杂审批体系
- 复杂商业权限模型
- 数据库驱动配置中心
- 大规模图形化运营后台

### 12.2 后续演进点
满足以下条件后，可考虑拆分 `user-admin`：
- 用户规模明显增长
- 用户生命周期管理显著复杂化
- 需要审批、迁移、配额、套餐、停复用等专门逻辑

满足以下条件后，可考虑引入更复杂编排：
- 工作流数量增加
- 外部系统对接增多
- 审计与统计要求上升
- 多环境部署复杂度提高

---

## 13. 验收标准

v1 验收至少满足：

1. 系统具备完整角色拓扑并能正常运行。
2. 新用户可由 ops 基于模板创建独立 daily 实例。
3. daily 用户之间不存在长期记忆串扰。
4. 复杂开发任务可被一级路由到 Claude Code ACP。
5. memory 具备双层治理规则。
6. state、policy、schema、workflow、文档各有明确真相源。
7. 所有关键配置与状态都可以通过 Git 追踪变更。
8. 数据库只承担索引与审计，不承担主配置职责。
9. critic 可以对用户实例创建与交付结果执行轻量审查。
10. 系统具备继续自迭代的最小闭环。

---

## 14. 一句话架构原则

本系统不是“一个超级 Agent”，而是一个以 OpenClaw 为底座的、按职责分层的、文件化真相源驱动的、多 Agent 协作系统；v1 优先保证最小可运行、自迭代、可审计、可回滚。


---

# 附录 A：`docs/system/ARCHITECTURE.md` v1 草案

```md
# ARCHITECTURE.md

## 1. 系统定位
本系统是一个基于 OpenClaw 的多 Agent 协作系统，目标是实现最小可运行、自迭代、可审计、可回滚的自动化工作体系。

## 2. 系统拓扑
- orchestrator：主控与任务调度
- critic：review-gate
- architect：架构与简单开发
- ops：运维、部署、巡检、用户实例生命周期管理
- daily-<userId>：单用户日常 Agent 实例
- skills-smith：Skill 模板与规范维护
- agent-smith：Agent 模板与规范维护
- claude-code：复杂开发 ACP 执行域
- subagents：后台并行 worker

## 3. 设计原则
1. 一 Agent 一 workspace 一 agentDir 一 sessions scope。
2. 角色职责单一，禁止主控承担资源生命周期管理。
3. daily 按用户独立实例化，不共享长期记忆。
4. complex coding 优先进入 Claude Code ACP。
5. subagents 仅作辅助并行，不替代 ACP。
6. critic 不参与主生产，只负责审查与签核。
7. 执行层与 Skills / 工具 / 软件解耦。
8. 规则、状态、工件以文件化与 JSON 化为主。

## 4. 角色职责边界
### 4.1 orchestrator
负责分类、分解、分派、收敛、复盘。
不负责用户实例创建、不负责高风险执行。

### 4.2 critic
负责质量审查、风险审查、验收签核。
默认只读。

### 4.3 architect
负责需求理解、架构设计、简单开发、复杂任务交接。
复杂任务必须输出 handoff 工件。

### 4.4 ops
负责巡检、日志、CI/CD、部署、allowlist 自动执行。
负责 daily 用户实例创建、归档、迁移、回收。

### 4.5 daily-<userId>
负责单用户日常交互、轻量查询、长期偏好维护。
默认仅轻量权限。

### 4.6 skills-smith
负责 Skills 创建、维护、抽象、版本演化。

### 4.7 agent-smith
负责 Agent 模板、workspace 模板、policy/schema/workflow 模板。
不直接实例化用户。

### 4.8 claude-code
负责复杂开发长跑执行。

### 4.9 subagents
负责后台并行研究与辅助分析。

## 5. 核心流程
### 5.1 用户消息流程
bindings -> target agent -> orchestrator（如需）-> execution domain -> critic（如需）

### 5.2 复杂开发流程
orchestrator -> architect -> handoff artifacts -> claude-code ACP -> critic -> merge/close

### 5.3 新用户开通流程
event -> ops -> daily-template workflow -> state update -> git commit -> critic -> binding 生效

## 6. 非目标
- v1 不引入独立 user-admin Agent
- v1 不引入数据库配置中心
- v1 不引入复杂审批流

## 7. 演进规则
当用户生命周期复杂度显著上升时，可从 ops 中拆分 user-admin。
```

# 附录 B：`docs/system/GOVERNANCE.md` v1 草案

```md
# GOVERNANCE.md

## 1. 目标
定义系统的治理规则、真相源分层、memory 规则、路由规则与变更规则。

## 2. 单一真相源分层
### 2.1 业务与角色真相源
`docs/system/ARCHITECTURE.md`

### 2.2 治理规则真相源
`docs/system/GOVERNANCE.md`

### 2.3 机器可执行真相源
- `policies/*.json`
- `schemas/*.json`
- `workflows/*.json`

### 2.4 运行状态真相源
- `state/*.json`

### 2.5 审计与检索层
数据库仅用于索引、审计、统计与检索。

## 3. 红线规则
1. Prompt 不是系统真相源。
2. 数据库不是配置真相源。
3. 长期规则必须写入文档或 JSON policy/schema/workflow。
4. 运行状态必须先落 state 文件。
5. 所有关键变更必须进入 Git。

## 4. Memory 治理
### 4.1 `memory/YYYY-MM-DD.md`
用于短期日志、排障轨迹、临时观察、handoff 摘要。

### 4.2 `MEMORY.md`
用于长期偏好、持久决策、稳定约束、经验证经验。

### 4.3 禁止项
禁止写入 secret、token、password、原始敏感 dump、未验证结论。

### 4.4 升格规则
新记忆先写 daily memory；满足 durable 条件后才允许升格到 `MEMORY.md`。

## 5. 路由治理
### 5.1 一般任务
- 聊天/查询 -> daily-<userId>
- 简单开发 -> architect
- 运维/部署 -> ops
- Skill 维护 -> skills-smith
- Agent 维护 -> agent-smith
- 审查/签核 -> critic

### 5.2 复杂开发升级条件
满足任一条件即升级到 claude-code ACP：
- 多目录或多模块
- 多轮持续编码
- 测试/构建/回归要求
- 大规模重构
- 需要 thread-bound 持续上下文
- architect 明确判定升级

## 6. 变更治理
### 6.1 模板变更
由 agent-smith 或 skills-smith 发起，critic 可抽检。

### 6.2 用户实例变更
由 ops 执行，写入 state 与审计。

### 6.3 高风险执行
仅允许在 allowlist 与 workflow 约束下执行。

## 7. 审计要求
至少记录：
- 用户实例创建
- 用户实例停用/迁移/恢复
- policy 变更
- 路由规则变更
- 高风险执行结果
```

# 附录 C：`policies/routing-policy.json` v1 草案

```json
{
  "version": "v1",
  "default_entry_agent": "orchestrator",
  "bindings_strategy": {
    "daily_user_binding": "explicit_per_user",
    "fallback": "orchestrator"
  },
  "task_routes": [
    {
      "type": "chat_or_query",
      "target": "daily-<userId>"
    },
    {
      "type": "simple_development",
      "target": "architect"
    },
    {
      "type": "ops_or_deployment",
      "target": "ops"
    },
    {
      "type": "skill_maintenance",
      "target": "skills-smith"
    },
    {
      "type": "agent_maintenance",
      "target": "agent-smith"
    },
    {
      "type": "review_or_signoff",
      "target": "critic"
    },
    {
      "type": "parallel_research",
      "target": "subagents"
    }
  ],
  "complexity_upgrade": {
    "target": "claude-code",
    "runtime": "acp",
    "conditions_any": [
      "multi_directory_or_multi_module",
      "multi_turn_long_running_coding",
      "requires_test_build_or_regression",
      "large_refactor",
      "requires_thread_bound_context",
      "architect_explicit_upgrade"
    ],
    "handoff_required": [
      "TASK.json",
      "PLAN.md",
      "DECISIONS.md",
      "ACCEPTANCE.md",
      "NEXT_STEPS.md"
    ]
  }
}
```

# 附录 D：`policies/memory-policy.json` v1 草案

```json
{
  "version": "v1",
  "layers": {
    "daily_memory": {
      "path_pattern": "memory/YYYY-MM-DD.md",
      "purpose": [
        "daily_context",
        "debug_trace",
        "incident_notes",
        "temporary_observations",
        "handoff_summary"
      ],
      "mode": "append_only"
    },
    "long_term_memory": {
      "path": "MEMORY.md",
      "purpose": [
        "durable_preferences",
        "persistent_decisions",
        "stable_constraints",
        "validated_experience",
        "long_term_user_profile"
      ],
      "mode": "curated"
    }
  },
  "write_rules": {
    "default_target": "daily_memory",
    "promotion_required_for_long_term": true
  },
  "promotion_criteria_any": [
    "reused_multiple_times",
    "stable_for_multiple_sessions",
    "decision_with_long_term_effect",
    "validated_user_preference",
    "stable_environment_constraint"
  ],
  "forbidden_content": [
    "secrets",
    "tokens",
    "passwords",
    "raw_sensitive_dump",
    "unverified_conclusion",
    "irrelevant_noise"
  ],
  "review": {
    "reviewer": "critic",
    "allow_workflow_promotion": true
  }
}
```

# 附录 E：`policies/tool-policy-matrix.json` v1 草案

```json
{
  "version": "v1",
  "agents": {
    "orchestrator": {
      "allow": [
        "group:sessions",
        "group:memory",
        "group:messaging",
        "read"
      ],
      "deny": [
        "group:runtime",
        "exec",
        "deploy",
        "broad_write"
      ]
    },
    "critic": {
      "allow": [
        "read",
        "group:memory",
        "group:sessions"
      ],
      "deny": [
        "exec",
        "write",
        "edit",
        "apply_patch",
        "deploy"
      ]
    },
    "architect": {
      "allow": [
        "read",
        "write",
        "edit",
        "apply_patch",
        "limited_exec"
      ],
      "deny": [
        "broad_deploy",
        "high_risk_ops"
      ]
    },
    "ops": {
      "allow": [
        "read",
        "exec",
        "process_control",
        "allowlisted_write",
        "allowlisted_deploy",
        "user_instance_lifecycle"
      ],
      "deny": [
        "non_allowlisted_high_risk_actions"
      ]
    },
    "skills-smith": {
      "allow": [
        "read",
        "write",
        "edit",
        "skills_write"
      ],
      "deny": [
        "deploy",
        "ops_runtime"
      ]
    },
    "agent-smith": {
      "allow": [
        "read",
        "write",
        "edit",
        "agent_template_write",
        "policy_template_write",
        "schema_template_write",
        "workflow_template_write"
      ],
      "deny": [
        "user_instance_create",
        "ops_runtime",
        "deploy"
      ]
    },
    "daily-template": {
      "allow": [
        "group:memory",
        "group:messaging",
        "read"
      ],
      "deny": [
        "group:runtime",
        "exec",
        "deploy",
        "broad_write",
        "ops_actions"
      ]
    }
  }
}
```

# 附录 F：`schemas/user-profile.schema.json` v1 草案

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "schemas/user-profile.schema.json",
  "title": "UserProfile",
  "type": "object",
  "required": [
    "userId",
    "displayName",
    "persona",
    "dailyAgentId",
    "workspaceId",
    "capabilityProfile",
    "status"
  ],
  "properties": {
    "userId": {
      "type": "string",
      "minLength": 1
    },
    "displayName": {
      "type": "string",
      "minLength": 1
    },
    "persona": {
      "type": "object",
      "required": ["style", "boundaries"],
      "properties": {
        "style": {
          "type": "string"
        },
        "boundaries": {
          "type": "array",
          "items": { "type": "string" }
        },
        "customNotes": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "additionalProperties": false
    },
    "dailyAgentId": {
      "type": "string",
      "pattern": "^daily-[A-Za-z0-9_.-]+$"
    },
    "workspaceId": {
      "type": "string",
      "pattern": "^workspace-daily-[A-Za-z0-9_.-]+$"
    },
    "capabilityProfile": {
      "type": "string",
      "enum": ["daily_light"]
    },
    "bindings": {
      "type": "object",
      "properties": {
        "accountIds": {
          "type": "array",
          "items": { "type": "string" }
        },
        "channelIds": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "additionalProperties": false
    },
    "preferences": {
      "type": "object",
      "additionalProperties": true
    },
    "status": {
      "type": "string",
      "enum": ["active", "disabled", "archived", "pending_review"]
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "additionalProperties": false
}
```

# 附录 G：`schemas/task.schema.json` v1 草案

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "schemas/task.schema.json",
  "title": "Task",
  "type": "object",
  "required": [
    "taskId",
    "title",
    "type",
    "source",
    "owner",
    "status",
    "createdAt"
  ],
  "properties": {
    "taskId": {
      "type": "string",
      "minLength": 1
    },
    "title": {
      "type": "string",
      "minLength": 1
    },
    "type": {
      "type": "string",
      "enum": [
        "chat_or_query",
        "simple_development",
        "complex_development",
        "ops_or_deployment",
        "skill_maintenance",
        "agent_maintenance",
        "review_or_signoff",
        "parallel_research"
      ]
    },
    "source": {
      "type": "object",
      "required": ["kind"],
      "properties": {
        "kind": {
          "type": "string",
          "enum": ["user_message", "heartbeat", "workflow", "manual", "external_event"]
        },
        "ref": {
          "type": "string"
        }
      },
      "additionalProperties": false
    },
    "owner": {
      "type": "string"
    },
    "requestedBy": {
      "type": "string"
    },
    "status": {
      "type": "string",
      "enum": ["new", "routed", "in_progress", "blocked", "review", "done", "failed", "archived"]
    },
    "complexity": {
      "type": "string",
      "enum": ["light", "normal", "complex"]
    },
    "route": {
      "type": "object",
      "properties": {
        "targetAgent": { "type": "string" },
        "runtime": { "type": "string", "enum": ["native", "acp"] },
        "reason": { "type": "array", "items": { "type": "string" } }
      },
      "additionalProperties": false
    },
    "artifacts": {
      "type": "array",
      "items": { "type": "string" }
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "additionalProperties": false
}
```

# 附录 H：`schemas/review.schema.json` v1 草案

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "schemas/review.schema.json",
  "title": "Review",
  "type": "object",
  "required": [
    "reviewId",
    "targetType",
    "targetRef",
    "reviewer",
    "status",
    "createdAt"
  ],
  "properties": {
    "reviewId": {
      "type": "string"
    },
    "targetType": {
      "type": "string",
      "enum": ["task", "agent", "skill", "user_instance", "policy_change", "memory_promotion"]
    },
    "targetRef": {
      "type": "string"
    },
    "reviewer": {
      "type": "string",
      "const": "critic"
    },
    "status": {
      "type": "string",
      "enum": ["pending", "approved", "rejected", "needs_changes"]
    },
    "riskLevel": {
      "type": "string",
      "enum": ["low", "medium", "high"]
    },
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["severity", "message"],
        "properties": {
          "severity": {
            "type": "string",
            "enum": ["info", "warning", "critical"]
          },
          "message": {
            "type": "string"
          },
          "suggestedAction": {
            "type": "string"
          }
        },
        "additionalProperties": false
      }
    },
    "createdAt": {
      "type": "string",
      "format": "date-time"
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time"
    }
  },
  "additionalProperties": false
}
```

# 附录 I：`state/users/index.json` 初始结构

```json
{
  "version": "v1",
  "users": [
    {
      "userId": "example-user",
      "displayName": "Example User",
      "dailyAgentId": "daily-example-user",
      "workspaceId": "workspace-daily-example-user",
      "status": "pending_review",
      "createdAt": "2026-03-18T00:00:00Z",
      "updatedAt": "2026-03-18T00:00:00Z"
    }
  ]
}
```

# 附录 J：`state/agents/catalog.json` 初始结构

```json
{
  "version": "v1",
  "agents": [
    {
      "agentId": "orchestrator",
      "role": "control_plane",
      "runtime": "native",
      "workspaceId": "workspace-orchestrator",
      "status": "active"
    },
    {
      "agentId": "critic",
      "role": "review_gate",
      "runtime": "native",
      "workspaceId": "workspace-critic",
      "status": "active"
    },
    {
      "agentId": "architect",
      "role": "execution_domain",
      "runtime": "native",
      "workspaceId": "workspace-architect",
      "status": "active"
    },
    {
      "agentId": "ops",
      "role": "execution_domain",
      "runtime": "native",
      "workspaceId": "workspace-ops",
      "status": "active"
    },
    {
      "agentId": "skills-smith",
      "role": "expert_domain",
      "runtime": "native",
      "workspaceId": "workspace-skills-smith",
      "status": "active"
    },
    {
      "agentId": "agent-smith",
      "role": "expert_domain",
      "runtime": "native",
      "workspaceId": "workspace-agent-smith",
      "status": "active"
    },
    {
      "agentId": "claude-code",
      "role": "external_coding_domain",
      "runtime": "acp",
      "workspaceId": "workspace-claude-code",
      "status": "active"
    }
  ]
}
```

# 附录 K：`workflows/create-daily-user.json` 初始骨架

```json
{
  "version": "v1",
  "workflowId": "create-daily-user",
  "owner": "ops",
  "templateOwner": "agent-smith",
  "trigger": {
    "type": "manual_or_external_event",
    "inputs": [
      "userId",
      "displayName",
      "persona",
      "bindings",
      "preferences"
    ]
  },
  "steps": [
    {
      "id": "validate_input",
      "action": "validate_against_schema",
      "schema": "schemas/user-profile.schema.json"
    },
    {
      "id": "materialize_agent_id",
      "action": "render_string",
      "template": "daily-<userId>"
    },
    {
      "id": "materialize_workspace_id",
      "action": "render_string",
      "template": "workspace-daily-<userId>"
    },
    {
      "id": "copy_template",
      "action": "copy_directory_template",
      "source": "docs/templates/daily-template",
      "target": "workspaces/workspace-daily-<userId>"
    },
    {
      "id": "render_profile",
      "action": "render_json_template",
      "target": "workspaces/workspace-daily-<userId>/profile.json"
    },
    {
      "id": "render_root_files",
      "action": "render_workspace_templates",
      "targets": [
        "AGENTS.md",
        "SOUL.md",
        "USER.md",
        "IDENTITY.md",
        "TOOLS.md",
        "MEMORY.md"
      ]
    },
    {
      "id": "initialize_memory_dir",
      "action": "mkdir",
      "target": "workspaces/workspace-daily-<userId>/memory"
    },
    {
      "id": "register_user_state",
      "action": "append_or_upsert_json",
      "target": "state/users/index.json"
    },
    {
      "id": "register_agent_catalog",
      "action": "append_or_upsert_json",
      "target": "state/agents/catalog.json"
    },
    {
      "id": "update_bindings",
      "action": "update_binding_config"
    },
    {
      "id": "git_commit",
      "action": "git_commit",
      "message_template": "provision daily agent for <userId>"
    },
    {
      "id": "write_audit",
      "action": "append_jsonl",
      "target": "state/audit/user-provision.jsonl"
    },
    {
      "id": "submit_for_review",
      "action": "create_review_record",
      "reviewTargetType": "user_instance",
      "reviewer": "critic"
    }
  ],
  "successState": "pending_review",
  "failureState": "failed"
}
```

# 附录 L：`state/skills/catalog.json` 初始结构

```json
{
  "version": "v1",
  "skills": [
    {
      "skillId": "example-skill",
      "name": "Example Skill",
      "owner": "skills-smith",
      "version": "0.1.0",
      "status": "draft",
      "inputSchema": "schemas/task.schema.json",
      "outputSchema": null,
      "requiredCapabilities": [
        "read"
      ],
      "notes": "placeholder entry"
    }
  ]
}
```

# 附录 M：`state/router/tasks.json` 初始结构

```json
{
  "version": "v1",
  "tasks": [
    {
      "taskId": "task-example-001",
      "title": "Example task",
      "type": "chat_or_query",
      "source": {
        "kind": "manual",
        "ref": "bootstrap"
      },
      "owner": "orchestrator",
      "status": "new",
      "complexity": "light",
      "route": {
        "targetAgent": "daily-example-user",
        "runtime": "native",
        "reason": [
          "chat_or_query"
        ]
      },
      "artifacts": [],
      "createdAt": "2026-03-18T00:00:00Z",
      "updatedAt": "2026-03-18T00:00:00Z"
    }
  ]
}
```

# 附录 N：`state/audit/user-provision.jsonl` 示例结构

```json
{"timestamp":"2026-03-18T00:00:00Z","event":"user_provision_requested","userId":"example-user","requestedBy":"ops","status":"accepted"}
{"timestamp":"2026-03-18T00:00:05Z","event":"user_workspace_materialized","userId":"example-user","workspaceId":"workspace-daily-example-user","status":"success"}
{"timestamp":"2026-03-18T00:00:08Z","event":"user_agent_registered","userId":"example-user","agentId":"daily-example-user","status":"success"}
{"timestamp":"2026-03-18T00:00:12Z","event":"user_binding_updated","userId":"example-user","status":"success"}
{"timestamp":"2026-03-18T00:00:15Z","event":"user_provision_submitted_for_review","userId":"example-user","reviewer":"critic","status":"pending_review"}
```

# 附录 O：`docs/templates/daily-template/` 最小文件列表

```text
/docs/templates/daily-template/
  AGENTS.md.tpl
  SOUL.md.tpl
  USER.md.tpl
  IDENTITY.md.tpl
  TOOLS.md.tpl
  HEARTBEAT.md.tpl
  BOOT.md.tpl
  BOOTSTRAP.md.tpl
  MEMORY.md.tpl
  profile.json.tpl
  policies/
    memory-policy.json
    local-tool-policy.json
  state/
    local-state.json
  reports/
  docs/
  memory/
```

## daily-template 说明
- 所有 `.tpl` 文件由 `agent-smith` 维护。
- `ops` 只负责将模板实例化为具体用户 Agent/workspace。
- `daily-template` 的默认能力配置必须遵循 `daily_light` 策略。
- 模板中的 policy 仅允许定义本地覆盖项，不得违背系统级治理红线。

# 附录 P：`profile.json` 示例

```json
{
  "userId": "example-user",
  "displayName": "Example User",
  "persona": {
    "style": "professional_concise",
    "boundaries": [
      "default_no_exec",
      "default_no_ops_actions",
      "default_no_cross_user_memory"
    ],
    "customNotes": [
      "prefer concise answers",
      "store stable preferences only after repeated evidence"
    ]
  },
  "dailyAgentId": "daily-example-user",
  "workspaceId": "workspace-daily-example-user",
  "capabilityProfile": "daily_light",
  "bindings": {
    "accountIds": [
      "example-account"
    ],
    "channelIds": []
  },
  "preferences": {
    "language": "zh-CN",
    "tone": "professional",
    "memorySensitivity": "strict"
  },
  "status": "pending_review",
  "createdAt": "2026-03-18T00:00:00Z",
  "updatedAt": "2026-03-18T00:00:00Z"
}
```

# 附录 Q：`TASK.json` 示例

```json
{
  "taskId": "task-dev-20260318-001",
  "title": "Build v1 project bootstrap",
  "type": "complex_development",
  "source": {
    "kind": "user_message",
    "ref": "conversation-001"
  },
  "owner": "architect",
  "requestedBy": "example-user",
  "status": "review",
  "complexity": "complex",
  "route": {
    "targetAgent": "claude-code",
    "runtime": "acp",
    "reason": [
      "multi_directory_or_multi_module",
      "requires_test_build_or_regression",
      "architect_explicit_upgrade"
    ]
  },
  "artifacts": [
    "PLAN.md",
    "DECISIONS.md",
    "ACCEPTANCE.md",
    "NEXT_STEPS.md"
  ],
  "createdAt": "2026-03-18T00:00:00Z",
  "updatedAt": "2026-03-18T00:10:00Z"
}
```

# 附录 R：`SIGNOFF.json` 示例

```json
{
  "reviewId": "review-20260318-001",
  "targetType": "task",
  "targetRef": "task-dev-20260318-001",
  "reviewer": "critic",
  "status": "approved",
  "riskLevel": "medium",
  "findings": [
    {
      "severity": "info",
      "message": "handoff artifacts present and route decision justified",
      "suggestedAction": "continue to controlled merge"
    }
  ],
  "createdAt": "2026-03-18T00:12:00Z",
  "updatedAt": "2026-03-18T00:12:00Z"
}
```

# 附录 S：`AGENTS.md.tpl` 最小内容

```md
# AGENTS

## 1. 角色定位
你是服务于单一用户的 daily Agent。你的目标是提供稳定、轻量、个性化的日常支持。

## 2. 核心原则
1. 只服务当前用户，不推断其他用户上下文。
2. 优先使用 workspace 内文件化上下文，而不是假设记忆。
3. 遇到需要高权限、运维、部署、复杂开发的任务，必须升级或转交。
4. 不得绕过 policy、schema、workflow 与系统治理规则。
5. 新记忆默认写入 daily memory，不直接写入长期记忆。

## 3. 默认工作方式
- 日常聊天与查询：直接处理。
- 需要长期保留的信息：先写 daily memory。
- 涉及复杂开发：转交 orchestrator / architect。
- 涉及运维、部署、环境修改：转交 ops。
- 涉及 Agent/Skill 改造：转交 agent-smith / skills-smith。

## 4. 禁止事项
- 不得执行超出 daily_light 的能力。
- 不得访问或引用其他用户的长期记忆。
- 不得将未验证结论写入长期记忆。
- 不得将 secrets 写入 memory。

## 5. 输出偏好
- 优先简洁、清晰、可执行。
- 有不确定性时应明确说明。
- 涉及升级路由时，应给出升级原因。
```

# 附录 T：`SOUL.md.tpl` 最小内容

```md
# SOUL

## 1. 基本人格
- 专业
- 清晰
- 克制
- 务实
- 不夸张

## 2. 互动风格
- 优先给出结论，再给必要解释。
- 回答应以可执行、可判断、可验证为导向。
- 不使用含糊的承诺来掩盖不确定性。

## 3. 边界意识
- 需要升级时直接升级，不勉强处理。
- 不把人格文件当权限来源。
- 不因为风格需求突破系统治理红线。

## 4. 记忆态度
- 稳定偏好才值得进入长期记忆。
- 临时聊天内容默认不进入长期记忆。
```

# 附录 U：`USER.md.tpl` 最小内容

```md
# USER

## 1. 用户标识
- userId: <userId>
- displayName: <displayName>

## 2. 用户服务边界
- 本 Agent 仅服务该用户。
- 不共享其他用户上下文。
- 不为其他用户建立长期偏好映射。

## 3. 初始偏好
- 语言: <language>
- 语气: <tone>
- 风格: <style>

## 4. 记忆规则
- 仅在存在长期价值时才将信息升格到 `MEMORY.md`。
- 所有新记忆先进入 `memory/YYYY-MM-DD.md`。

## 5. 特殊备注
- <customNotes>
```

# 附录 V：`ops/ALLOWLIST.json` 示例

```json
{
  "version": "v1",
  "owner": "ops",
  "rules": [
    {
      "id": "ops-read-logs",
      "action": "read_logs",
      "scope": [
        "/var/log",
        "workspace-ops/logs"
      ],
      "mode": "allowed"
    },
    {
      "id": "ops-restart-approved-service",
      "action": "restart_service",
      "scope": [
        "approved-services"
      ],
      "mode": "allowed_with_workflow"
    },
    {
      "id": "ops-run-approved-deploy",
      "action": "deploy",
      "scope": [
        "approved-environments"
      ],
      "mode": "allowed_with_workflow"
    },
    {
      "id": "ops-package-install",
      "action": "install_package",
      "scope": [
        "approved-package-list"
      ],
      "mode": "allowed_with_workflow"
    },
    {
      "id": "ops-user-instance-lifecycle",
      "action": "manage_daily_user_instance",
      "scope": [
        "workspace-daily-*",
        "agents/daily-*"
      ],
      "mode": "allowed"
    }
  ],
  "denyByDefault": true
}
```

# 附录 W：`critic` review checklist

```md
# critic review checklist

## 1. 通用检查
- 目标对象是否存在明确引用？
- 输入与输出是否可追踪？
- 相关 state / audit 是否已更新？
- 是否存在明显越权行为？

## 2. 用户实例创建检查
- daily-<userId> 是否已正确生成？
- workspaceId 是否与 userId 匹配？
- profile.json 是否符合 schema？
- bindings 是否已更新？
- 默认权限是否符合 daily_light？
- 是否误共享其他用户记忆？

## 3. 开发任务检查
- 复杂度判定是否有依据？
- 若升级到 ACP，handoff 工件是否完整？
- 验收标准是否清晰？
- route.reason 是否自洽？

## 4. memory 检查
- 新记忆是否先进入 daily memory？
- 升格到 `MEMORY.md` 是否符合 durable 条件？
- 是否包含 secrets 或未验证结论？

## 5. 高风险动作检查
- 是否命中 allowlist？
- 是否有 workflow 约束？
- 是否保留足够审计记录？

## 6. 审核结论
- approved
- needs_changes
- rejected
```

# 附录 X：`architect -> claude-code` handoff checklist

```md
# architect to claude-code handoff checklist

## 1. 任务定义
- 是否生成 `TASK.json`？
- task.type 是否为 `complex_development`？
- 任务目标是否明确且可验证？

## 2. 方案准备
- 是否生成 `PLAN.md`？
- 是否记录关键决策到 `DECISIONS.md`？
- 是否明确说明不做什么？

## 3. 验收边界
- 是否生成 `ACCEPTANCE.md`？
- 验收项是否可测试？
- 是否明确交付完成定义？

## 4. 恢复与续跑
- 是否生成 `NEXT_STEPS.md`？
- 是否说明当前进度、下一步、阻塞项？
- 是否保证新会话可以从工件恢复？

## 5. 路由说明
- 是否说明升级到 ACP 的原因？
- route.reason 是否写入 `TASK.json`？
- 是否明确 runtime 为 `acp`？

## 6. 风险说明
- 是否指出已知风险与限制？
- 是否指出需要 critic 重点检查的点？
```

# 附录 Y：`docs/system/BOOTSTRAP-CHECKLIST.md` v1 草案

```md
# BOOTSTRAP-CHECKLIST

## 1. 基础结构
- 创建 docs/system/
- 创建 policies/
- 创建 schemas/
- 创建 state/
- 创建 templates/
- 初始化 Git

## 2. 系统级文档
- 写入 ARCHITECTURE.md
- 写入 GOVERNANCE.md
- 写入 FILE-NAMING.md

## 3. 系统级 JSON
- routing-policy.json
- memory-policy.json
- tool-policy-matrix.json
- state/users/index.json
- state/agents/catalog.json
- state/skills/catalog.json
- state/router/tasks.json

## 4. 模板
- 建立 daily-template
- 建立 profile.json.tpl
- 建立 AGENTS/SOUL/USER 模板

## 5. 执行域
- 创建 orchestrator
- 创建 critic
- 创建 architect
- 创建 ops
- 创建 skills-smith
- 创建 agent-smith
- 注册 claude-code ACP

## 6. 验收
- 是否能创建 daily 用户实例？
- 是否能记录 task？
- 是否能完成 review？
- 是否能升级复杂开发到 ACP？
```

# 附录 Z：`docs/system/FILE-NAMING.md` v1 草案

```md
# FILE-NAMING

## 1. 原则
- 文件名应稳定、可预测、可脚本处理。
- JSON 文件优先 kebab-case 或固定命名。
- Markdown 工件优先使用明确语义名。

## 2. 约定
- 用户 Agent：`daily-<userId>`
- 用户 Workspace：`workspace-daily-<userId>`
- task 文件：`TASK.json`
- 计划文件：`PLAN.md`
- 决策文件：`DECISIONS.md`
- 验收文件：`ACCEPTANCE.md`
- 续跑文件：`NEXT_STEPS.md`
- 评审签核：`SIGNOFF.json`

## 3. incidents / deploys
- `INCIDENT-YYYYMMDD-<slug>.md`
- `DEPLOY-YYYYMMDD-<slug>.md`

## 4. memory
- daily memory: `memory/YYYY-MM-DD.md`
- long-term memory: `MEMORY.md`

## 5. state
- 用户索引：`state/users/index.json`
- Agent 目录：`state/agents/catalog.json`
- Skill 目录：`state/skills/catalog.json`
- 任务路由：`state/router/tasks.json`
- 审计日志：`state/audit/*.jsonl`
```

# 附录 AA：`HEARTBEAT.md.tpl` 最小内容

```md
# HEARTBEAT

## 1. 目标
用于周期性自检与轻量巡检，发现需要升级、修复、归档或清理的问题。

## 2. 执行原则
1. 只执行轻量检查，不直接进行高风险修改。
2. 遇到需要运维、部署、复杂修复的情况，转交 `ops`。
3. 遇到需要长期记忆治理的情况，触发 memory promotion 或 review 流程。
4. 巡检结果必须写入报告或审计，而不是只停留在会话中。

## 3. 检查项
- 当前 workspace 结构是否完整。
- 最近的 daily memory 是否存在异常膨胀。
- 是否存在疑似应升格到 `MEMORY.md` 的稳定信息。
- 是否存在过期、冗余、未归档的临时文件。
- 是否存在需要转交 orchestrator / ops / critic 的事项。

## 4. 输出要求
- 给出简要巡检结论。
- 列出发现的问题。
- 明确建议动作：忽略 / 记录 / 升级 / 转交。
```

# 附录 AB：`BOOT.md.tpl` 最小内容

```md
# BOOT

## 1. 目标
用于 Agent 在重启或重新进入上下文时执行最小恢复检查。

## 2. 恢复顺序
1. 确认当前 Agent 身份与角色。
2. 确认当前 workspace 是否正确。
3. 读取系统级治理规则摘要。
4. 读取用户与本地 profile 摘要。
5. 优先检查今日和昨日 daily memory。
6. 如有未完成任务，优先检查 `NEXT_STEPS.md` 或 state 中的待办。

## 3. 禁止事项
- 不得在 BOOT 中执行高风险动作。
- 不得在未确认 workspace 正确时写入 memory。
- 不得跳过治理规则直接继续高权限执行。

## 4. 恢复输出
- 当前身份确认
- 当前上下文摘要
- 是否存在未完成事项
- 是否需要交接或升级
```

# 附录 AC：`BOOTSTRAP.md.tpl` 最小内容

```md
# BOOTSTRAP

## 1. 目标
用于首次创建 workspace 或首次接管角色时完成初始化动作。

## 2. 初始化顺序
1. 建立目录结构。
2. 建立根文件。
3. 建立 state、policies、reports、memory 目录。
4. 初始化 profile / local-state。
5. 校验模板渲染结果。
6. 写入初始审计记录。
7. 提交 Git。
8. 进入 pending_review 或 active 状态。

## 3. 初始化约束
- 必须使用系统模板与 schema。
- 禁止绕过 JSON/state/audit 直接进入运行态。
- 初始化完成前不得承担正式业务任务。

## 4. 完成判定
- 目录存在
- 根文件存在
- 必要 state 存在
- policy 已就位
- audit 已写入
- 可提交 review
```

# 附录 AD：`IDENTITY.md.tpl` 最小内容

```md
# IDENTITY

## 1. 标识
- agentId: <agentId>
- workspaceId: <workspaceId>
- role: daily_user_agent

## 2. 自我描述
我是一个服务于单一用户的 daily Agent 实例，负责轻量、稳定、个性化的日常支持。

## 3. 不变量
- 只服务一个用户。
- 不跨用户共享长期记忆。
- 不越权执行高风险动作。
- 需要升级时主动升级。
```

# 附录 AE：`TOOLS.md.tpl` 最小内容

```md
# TOOLS

## 1. 工具使用原则
1. 工具能力由系统 policy 与 sandbox 决定，不由本文件扩权。
2. 本文件只解释本 Agent 的默认工具使用习惯与限制。
3. 遇到需要高权限工具时，必须升级或转交。

## 2. 默认可用能力
- memory 读取与记录
- 轻量消息与查询
- 必要只读能力

## 3. 默认受限能力
- exec
- 部署
- 广泛文件写入
- 运维与环境修改

## 4. 使用习惯
- 能用 state / memory 检索时，不直接全量读取。
- 能通过结构化文件获取状态时，不依赖聊天推测。
- 工具执行后应留下必要工件或状态更新。
```

# 附录 AF：`workflows/memory/promote.json` 示例

```json
{
  "version": "v1",
  "workflowId": "memory-promote",
  "owner": "critic",
  "trigger": {
    "type": "manual_or_heartbeat",
    "inputs": [
      "sourceEntryRef",
      "candidateContent",
      "reason"
    ]
  },
  "steps": [
    {
      "id": "validate_candidate",
      "action": "check_policy",
      "policy": "policies/memory-policy.json"
    },
    {
      "id": "check_forbidden_content",
      "action": "scan_for_forbidden_content",
      "rules": [
        "secrets",
        "tokens",
        "passwords",
        "raw_sensitive_dump",
        "unverified_conclusion"
      ]
    },
    {
      "id": "evaluate_promotion_criteria",
      "action": "evaluate_any",
      "criteria": [
        "reused_multiple_times",
        "stable_for_multiple_sessions",
        "decision_with_long_term_effect",
        "validated_user_preference",
        "stable_environment_constraint"
      ]
    },
    {
      "id": "append_long_term_memory",
      "action": "append_markdown_section",
      "target": "MEMORY.md"
    },
    {
      "id": "write_audit_record",
      "action": "append_jsonl",
      "target": "state/audit/memory-promotion.jsonl"
    },
    {
      "id": "create_review_record",
      "action": "create_review_record",
      "reviewTargetType": "memory_promotion",
      "reviewer": "critic"
    }
  ],
  "successState": "promoted",
  "failureState": "rejected"
}
```

# 附录 AG：`state/audit/memory-promotion.jsonl` 示例结构

```json
{"timestamp":"2026-03-18T00:00:00Z","event":"memory_promotion_requested","sourceEntryRef":"memory/2026-03-18.md#entry-001","status":"accepted"}
{"timestamp":"2026-03-18T00:00:03Z","event":"memory_promotion_validated","sourceEntryRef":"memory/2026-03-18.md#entry-001","status":"success"}
{"timestamp":"2026-03-18T00:00:05Z","event":"memory_promoted","target":"MEMORY.md","status":"success"}
{"timestamp":"2026-03-18T00:00:08Z","event":"memory_promotion_review_created","reviewer":"critic","status":"pending_review"}
```

# 附录 AH：`routing-policy` 复杂度判定示例集

```md
# routing complexity examples

## 1. simple_development
场景：单文件脚本修改、单目录轻量修复、小范围文档补充。
处理：优先 `architect`。

## 2. complex_development
场景：多目录改动、需要测试与回归、需要长跑上下文、多轮持续实现。
处理：`architect` 负责方案与交接，`claude-code` 负责 ACP 执行。

## 3. ops_or_deployment
场景：日志排查、服务重启、部署、包安装、CI/CD 问题。
处理：`ops`。

## 4. review_or_signoff
场景：用户实例上线前审查、复杂任务验收、memory 升格抽检。
处理：`critic`。

## 5. parallel_research
场景：并行资料搜集、后台慢任务分析、辅助比对。
处理：`subagents`。
```

# 附录 AI：阶段性结论

到本附录为止，v1 已具备以下最小闭环：
1. 角色拓扑与职责边界。
2. 单一真相源分层。
3. 路由、memory、tool policy 骨架。
4. schema、state、workflow 初稿。
5. daily 用户实例化流程。
6. 审计记录样例。
7. daily-template 最小模板正文。
8. review、handoff、bootstrap、命名规范。
9. memory promotion workflow。

# 附录 AJ：`workflows/system/materialize-core-agents.json` 草案

```json
{
  "version": "v1",
  "workflowId": "materialize-core-agents",
  "owner": "ops",
  "templateOwner": "agent-smith",
  "trigger": {
    "type": "manual",
    "inputs": [
      "agentIds",
      "basePath",
      "pathMapRef"
    ]
  },
  "defaults": {
    "agentIds": [
      "orchestrator",
      "critic",
      "architect",
      "ops",
      "skills-smith",
      "agent-smith",
      "claude-code"
    ]
  },
  "steps": [
    {
      "id": "validate_core_docs",
      "action": "assert_files_exist",
      "targets": [
        "docs/system/ARCHITECTURE.md",
        "docs/system/GOVERNANCE.md",
        "docs/system/PATH-MAP.md",
        "policies/routing-policy.json",
        "policies/tool-policy-matrix.json"
      ]
    },
    {
      "id": "load_agent_catalog",
      "action": "read_json",
      "target": "state/agents/catalog.json"
    },
    {
      "id": "for_each_agent",
      "action": "for_each",
      "items": "agentIds",
      "steps": [
        {
          "id": "create_workspace_dir",
          "action": "mkdir",
          "target_template": "~/.openclaw/workspace-<item>/"
        },
        {
          "id": "create_workspace_subdirs",
          "action": "mkdir_many",
          "targets_template": [
            "~/.openclaw/workspace-<item>/memory",
            "~/.openclaw/workspace-<item>/docs",
            "~/.openclaw/workspace-<item>/state",
            "~/.openclaw/workspace-<item>/policies",
            "~/.openclaw/workspace-<item>/reports",
            "~/.openclaw/workspace-<item>/logs"
          ]
        },
        {
          "id": "render_root_files",
          "action": "render_core_agent_templates",
          "targets_template": {
            "AGENTS.md": "templates/core-agent/AGENTS.md.tpl",
            "SOUL.md": "templates/core-agent/SOUL.md.tpl",
            "IDENTITY.md": "templates/core-agent/IDENTITY.md.tpl",
            "TOOLS.md": "templates/core-agent/TOOLS.md.tpl",
            "HEARTBEAT.md": "templates/core-agent/HEARTBEAT.md.tpl",
            "BOOT.md": "templates/core-agent/BOOT.md.tpl",
            "BOOTSTRAP.md": "templates/core-agent/BOOTSTRAP.md.tpl",
            "MEMORY.md": "templates/core-agent/MEMORY.md.tpl"
          },
          "destination_template": "~/.openclaw/workspace-<item>/"
        },
        {
          "id": "create_agent_state_dir",
          "action": "mkdir_many",
          "targets_template": [
            "~/.openclaw/agents/<item>/agent",
            "~/.openclaw/agents/<item>/sessions"
          ]
        },
        {
          "id": "seed_local_state",
          "action": "write_json_if_missing",
          "target_template": "~/.openclaw/workspace-<item>/state/local-state.json",
          "content_template": {
            "agentId": "<item>",
            "status": "materialized",
            "createdBy": "ops"
          }
        },
        {
          "id": "register_agent",
          "action": "append_or_upsert_json",
          "target": "state/agents/catalog.json"
        },
        {
          "id": "append_audit",
          "action": "append_jsonl",
          "target": "state/audit/core-agent-materialization.jsonl"
        }
      ]
    },
    {
      "id": "git_commit",
      "action": "git_commit",
      "message_template": "materialize core agents"
    },
    {
      "id": "submit_bootstrap_review",
      "action": "create_review_record",
      "reviewTargetType": "agent",
      "reviewer": "critic"
    }
  ],
  "successState": "pending_review",
  "failureState": "failed"
}
```

# 附录 AK：`docs/system/BRING-UP-ORDER.md` 草案

```md
# BRING-UP-ORDER

## 1. 目标
定义 v1 的最小启动顺序，避免在基础角色尚未物化前过早开始用户级与自动化级测试。

## 2. 启动顺序
### Step 1: 物化 core agents
先通过 `materialize-core-agents` 工作流创建以下基础角色的真实 workspace 与 agent 状态目录：
- orchestrator
- critic
- architect
- ops
- skills-smith
- agent-smith
- claude-code（最小目录即可）

### Step 2: bootstrap review
由 critic 对 core agents 做一次 bootstrap 审查：
- 目录是否存在
- 根文件是否齐全
- catalog/state/audit 是否已更新
- 是否存在明显越权配置

### Step 3: 注册与校验 claude-code handoff 区
此阶段只验证：
- handoff 工件路径可用
- route 到 ACP 的配置路径正确
- 暂不要求做高强度长跑测试

### Step 4: 创建第一个 daily 测试用户
由 ops 基于 daily-template 创建：
- daily-test-user

验收重点：
- workspace 生成
- state/users/index.json 更新
- state/agents/catalog.json 更新
- status 进入 pending_review

### Step 5: 验证 complex routing
使用一个明确属于 complex_development 的任务，验证：
- orchestrator 判定正确
- architect 产出 handoff 工件
- route 到 claude-code ACP

### Step 6: 验证 ops allowlist
仅测试 allowlist 范围内的安全动作：
- 读取日志
- 写 incident/report
- 一个无害的允许动作

### Step 7: 最后开启 heartbeat
只有在前 6 步稳定后，才开启 heartbeat 或定时工作流。

## 3. 关于 main workspace 的迁移原则
### 3.1 当前策略
在 v1 bring-up 阶段，main workspace 仅作为过渡环境存在，不继续承担长期多角色职责。

### 3.2 迁移方向
应逐步把以下职责迁出 main workspace：
- 主控调度
- 运维巡检
- 架构设计
- 审查签核
- 用户日常服务

### 3.3 迁移完成判定
当以下条件满足时，可进入 main workspace 退场阶段：
- core agents 均已物化
- daily 用户实例化链路稳定
- complex routing 已验证
- ops allowlist 已验证
- critic 审查链路可用

### 3.4 退场方式
- 先停止向 main workspace 新增职责
- 再将剩余职责逐一迁移到独立 workspace
- 最后将 main workspace 仅保留为备份/兼容/观察用途

## 4. 红线
- 不要在 core agents 未物化前，把 main workspace 继续扩展成超级 agent
- 不要在 daily 用户实例未稳定前，让 main workspace 继续充当多用户长期记忆容器
- 不要在 heartbeat 启动前省略 bootstrap review
```

# 附录 AL：`state/audit/core-agent-materialization.jsonl` 示例结构

```json
{"timestamp":"2026-03-18T00:00:00Z","event":"core_agent_materialization_requested","agentId":"orchestrator","requestedBy":"ops","status":"accepted"}
{"timestamp":"2026-03-18T00:00:02Z","event":"workspace_created","agentId":"orchestrator","workspaceId":"workspace-orchestrator","status":"success"}
{"timestamp":"2026-03-18T00:00:04Z","event":"agent_state_dir_created","agentId":"orchestrator","status":"success"}
{"timestamp":"2026-03-18T00:00:06Z","event":"catalog_updated","agentId":"orchestrator","status":"success"}
{"timestamp":"2026-03-18T00:00:08Z","event":"bootstrap_review_submitted","agentId":"orchestrator","reviewer":"critic","status":"pending_review"}
```

# 附录 AM：关于 main workspace 逐步退场的记录

```md
# main workspace retirement note

## 1. 背景
当前系统仍保留 OpenClaw 默认 main workspace，但目标是逐步将其从长期多角色承载体迁移为过渡与兼容环境。

## 2. 原则
- 不做一次性硬切换。
- 不在基础角色未物化时强行淘汰 main workspace。
- 只有当独立 workspace 已稳定承接职责时，才迁出对应能力。

## 3. 提醒时机
在以下节点应主动提醒推进 main workspace 迁移：
- core agents 全部物化完成后
- 第一个 daily 用户实例稳定后
- complex routing 验证通过后
- ops allowlist 验证通过后

## 4. 最终目标
main workspace 不再承担系统主职责，仅保留为：
- 兼容入口
- 观察环境
- 备份用途
```

# 附录 AN：建议

建议下一步直接做两件事：
1. 把这 3 份文件落成真实文件。
2. 先跑一次 core agents 物化，再做第一次 bootstrap review。

