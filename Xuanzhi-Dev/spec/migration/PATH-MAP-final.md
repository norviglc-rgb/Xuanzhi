# PATH-MAP

本文档定义本项目在 OpenClaw 中的**唯一有效路径标准**。

本文件的目标不是长期维护“路径映射表”，而是一次性把路径规则、目录结构、职责归属、解析语义全部定死。  
当本项目完成整理并严格遵循本文档后，本文档即可退役；后续开发、同步、复制、替换都应直接以 `~/.openclaw/` 下的真实结构为准，不再维护第二套或第三套不同版本的 workspace 集合。

---

## 0. 设计目标

本项目的路径设计遵循以下目标：

1. **系统根路径唯一**
   - 所有系统级文件、模板、策略、schema、workflow、state 都相对于 `~/.openclaw/` 根目录。
   - 不再维护“逻辑上是一套，真实目录又是另一套”的双重映射。

2. **main 与非 main 分离**
   - `main` 保留默认 `~/.openclaw/workspace`
   - 所有独立 Agent 一律使用：
     - `~/.openclaw/workspaces/workspace-<agentId>`
   - 所有 daily 用户实例一律使用：
     - `~/.openclaw/workspaces/workspace-daily-<userId>`

3. **不维护多套 workspace 集合**
   - 不再同时维护：
     - `workspace-<agentId>`
     - `workspaces/workspace-<agentId>`
     - 项目根目录另一套自定义 workspace
   - 后续所有新建与整理，都只保留一套统一结构。

4. **系统根路径优先，workspace 路径显式**
   - 系统级相对路径默认相对于 `~/.openclaw/`
   - workspace 内路径必须显式写成：
     - `<workspace>/...`
     - 或 `~/.openclaw/workspaces/workspace-<agentId>/...`

---

## 1. 路径解析规则（v1，强制）

除非特别注明，以下路径前缀：

- `docs/...`
- `policies/...`
- `schemas/...`
- `templates/...`
- `workflows/...`
- `state/...`
- `ops/...`
- `review/...`
- `architect/...`

**均解释为相对于 OpenClaw 根目录：**

- `~/.openclaw/`

### 示例

#### 系统级文档
- `docs/system/ARCHITECTURE.md`
  实际路径：
  `~/.openclaw/docs/system/ARCHITECTURE.md`

- `docs/system/BRING-UP-ORDER.md`
  实际路径：
  `~/.openclaw/docs/system/BRING-UP-ORDER.md`

#### 系统级策略
- `policies/routing-policy.json`
  实际路径：
  `~/.openclaw/policies/routing-policy.json`

#### 系统级 workflow
- `workflows/system/materialize-core-agents.json`
  实际路径：
  `~/.openclaw/workflows/system/materialize-core-agents.json`

#### 系统级 state
- `state/agents/catalog.json`
  实际路径：
  `~/.openclaw/state/agents/catalog.json`

### 明确禁止

以下写法在系统级文件中不得再被模糊使用：

- 把 `docs/...` 解释成当前 workspace 下的 `docs/...`
- 把 `templates/...` 解释成某个 agent workspace 下的 `templates/...`
- 把 `state/...` 解释成当前会话目录下的 `state/...`

### workspace 本地路径必须显式写法

如果要表示某个 agent 的本地 workspace 文件，必须写成以下形式之一：

- `<workspace>/MEMORY.md`
- `<workspace>/memory/YYYY-MM-DD.md`
- `<workspace>/policies/local-tool-policy.json`

或者写成绝对路径，例如：

- `~/.openclaw/workspaces/workspace-agent-smith/MEMORY.md`
- `~/.openclaw/workspaces/workspace-ops/reports/`

---

## 2. 根目录标准

项目根目录固定为：

- `~/.openclaw/`

在此目录下，系统级目录应统一为：

- `docs/`
- `policies/`
- `schemas/`
- `templates/`
- `workflows/`
- `state/`
- `skills/`
- `ops/`
- `review/`
- `architect/`
- `agents/`
- `workspaces/`
- `workspace/`（仅 main）

---

## 3. 系统级文件与目录

### 3.1 主配置

| 路径 | 说明 |
|------|------|
| `~/.openclaw/openclaw.json` | OpenClaw 主配置文件 |

---

### 3.2 系统级文档

| 路径 | 说明 |
|------|------|
| `~/.openclaw/docs/system/ARCHITECTURE.md` | 系统拓扑与职责边界 |
| `~/.openclaw/docs/system/GOVERNANCE.md` | 治理规则与红线 |
| `~/.openclaw/docs/system/BRING-UP-ORDER.md` | bring-up 顺序 |
| `~/.openclaw/docs/system/BOOTSTRAP-CHECKLIST.md` | 初始化检查清单 |
| `~/.openclaw/docs/system/FILE-NAMING.md` | 文件命名规则 |

说明：
- `PATH-MAP.md` 本身是过渡文档。
- 当全项目路径整理完成后，可将其归档或删除。
- 后续不应再依赖 `PATH-MAP.md` 做运行期解释。

---

### 3.3 系统级策略

| 路径 | 说明 |
|------|------|
| `~/.openclaw/policies/routing-policy.json` | 路由策略 |
| `~/.openclaw/policies/memory-policy.json` | Memory 治理策略 |
| `~/.openclaw/policies/tool-policy-matrix.json` | 工具权限矩阵 |

---

### 3.4 系统级 schema

| 路径 | 说明 |
|------|------|
| `~/.openclaw/schemas/task.schema.json` | 任务结构定义 |
| `~/.openclaw/schemas/user-profile.schema.json` | 用户配置定义 |
| `~/.openclaw/schemas/review.schema.json` | 审查记录定义 |

---

### 3.5 系统级 workflow

| 路径 | 说明 |
|------|------|
| `~/.openclaw/workflows/system/materialize-core-agents.json` | Core Agent 物化流程 |
| `~/.openclaw/workflows/users/create-daily-user.json` | Daily 用户实例创建流程 |
| `~/.openclaw/workflows/memory/promote.json` | Memory 升格流程 |

---

### 3.6 系统级 state

| 路径 | 说明 |
|------|------|
| `~/.openclaw/state/agents/catalog.json` | Agent 注册表 |
| `~/.openclaw/state/users/index.json` | 用户索引 |
| `~/.openclaw/state/skills/catalog.json` | Skills 目录 |
| `~/.openclaw/state/router/tasks.json` | 路由任务状态 |
| `~/.openclaw/state/audit/` | 审计日志目录 |

常见审计文件包括：

- `~/.openclaw/state/audit/user-provision.jsonl`
- `~/.openclaw/state/audit/core-agent-materialization.jsonl`
- `~/.openclaw/state/audit/memory-promotion.jsonl`

---

### 3.7 系统级模板

| 路径 | 说明 |
|------|------|
| `~/.openclaw/templates/core-agent/` | Core Agent 模板目录 |
| `~/.openclaw/templates/daily-template/` | Daily 用户模板目录 |

#### Core Agent 模板文件

- `~/.openclaw/templates/core-agent/AGENTS.md.tpl`
- `~/.openclaw/templates/core-agent/SOUL.md.tpl`
- `~/.openclaw/templates/core-agent/IDENTITY.md.tpl`
- `~/.openclaw/templates/core-agent/TOOLS.md.tpl`
- `~/.openclaw/templates/core-agent/BOOT.md.tpl`
- `~/.openclaw/templates/core-agent/BOOTSTRAP.md.tpl`
- `~/.openclaw/templates/core-agent/HEARTBEAT.md.tpl`
- `~/.openclaw/templates/core-agent/MEMORY.md.tpl`

#### Daily Template 模板文件

- `~/.openclaw/templates/daily-template/AGENTS.md.tpl`
- `~/.openclaw/templates/daily-template/SOUL.md.tpl`
- `~/.openclaw/templates/daily-template/USER.md.tpl`
- `~/.openclaw/templates/daily-template/IDENTITY.md.tpl`
- `~/.openclaw/templates/daily-template/TOOLS.md.tpl`
- `~/.openclaw/templates/daily-template/HEARTBEAT.md.tpl`
- `~/.openclaw/templates/daily-template/BOOT.md.tpl`
- `~/.openclaw/templates/daily-template/BOOTSTRAP.md.tpl`
- `~/.openclaw/templates/daily-template/MEMORY.md.tpl`
- `~/.openclaw/templates/daily-template/profile.json.tpl`

---

## 4. Workspace 标准

### 4.1 main workspace（保留但逐步退场）

| 路径 | 说明 |
|------|------|
| `~/.openclaw/workspace` | 默认 main workspace |

说明：
- 这是 OpenClaw 默认路径
- 当前保留为过渡与兼容入口
- 后续不再继续向其添加长期多角色职责

---

### 4.2 Core Agent workspaces

所有非 main 的核心 Agent，一律放在：

- `~/.openclaw/workspaces/workspace-<agentId>`

例如：

- `~/.openclaw/workspaces/workspace-orchestrator`
- `~/.openclaw/workspaces/workspace-critic`
- `~/.openclaw/workspaces/workspace-architect`
- `~/.openclaw/workspaces/workspace-ops`
- `~/.openclaw/workspaces/workspace-skills-smith`
- `~/.openclaw/workspaces/workspace-agent-smith`
- `~/.openclaw/workspaces/workspace-claude-code`

---

### 4.3 Daily 用户 workspaces

所有 daily 用户实例，一律放在：

- `~/.openclaw/workspaces/workspace-daily-<userId>`

例如：

- `~/.openclaw/workspaces/workspace-daily-test-user`

---

### 4.4 workspace 内标准结构

任一 workspace 的最小标准结构为：

- `AGENTS.md`
- `SOUL.md`
- `IDENTITY.md`
- `TOOLS.md`
- `BOOT.md`
- `BOOTSTRAP.md`
- `HEARTBEAT.md`
- `MEMORY.md`
- `memory/`
- `docs/`
- `state/`
- `policies/`
- `reports/`
- `logs/`

对于 daily 用户实例，额外包含：

- `USER.md`
- `profile.json`

---

## 5. Agent 运行目录标准

所有 Agent 的运行态目录都在：

- `~/.openclaw/agents/<agentId>/`

其中：

### 5.1 Agent 状态目录
- `~/.openclaw/agents/<agentId>/agent`

### 5.2 Session 目录
- `~/.openclaw/agents/<agentId>/sessions`

### 5.3 认证配置（如使用）
- `~/.openclaw/agents/<agentId>/agent/auth-profiles.json`

---

## 6. Memory 标准

### 6.1 长期记忆
- `<workspace>/MEMORY.md`

### 6.2 每日日志记忆
- `<workspace>/memory/YYYY-MM-DD.md`

### 6.3 规则
- 所有新记忆默认先写 daily memory
- 只有满足 durable 条件才允许升格到 `MEMORY.md`
- 系统级 workflow 中如果写：
  - `MEMORY.md`
  - `memory/YYYY-MM-DD.md`
  
  必须明确这些属于 `<workspace>` 本地路径，而不是系统根路径

---

## 7. 特殊目录标准

### 7.1 ops
- `~/.openclaw/ops/ALLOWLIST.json`

### 7.2 review
- `~/.openclaw/review/critic-review-checklist.md`

### 7.3 architect
- `~/.openclaw/architect/handoff-checklist.md`

### 7.4 skills
- `~/.openclaw/skills/`

说明：
- `~/.openclaw/skills/` 为系统级托管 skills
- `<workspace>/skills/` 为 workspace 本地 skills 覆盖目录
- 后续如无特殊需要，不再单独维护 repo 根目录另一套 `skills/` 镜像

---

## 8. ACP 标准

### 8.1 claude-code Agent 目录
- `~/.openclaw/agents/claude-code/`

### 8.2 可选 handoff 目录
- `~/.openclaw/agents/claude-code/handoff/`

### 8.3 Handoff 工件
如果使用 handoff 目录，文件名标准为：

- `TASK.json`
- `PLAN.md`
- `DECISIONS.md`
- `ACCEPTANCE.md`
- `NEXT_STEPS.md`

---

## 9. 职责归属与路径所有权

### 9.1 agent-smith 负责维护
以下内容由 `agent-smith` 负责维护：

- `~/.openclaw/templates/core-agent/*`
- `~/.openclaw/templates/daily-template/*`
- `~/.openclaw/schemas/*`
- `~/.openclaw/workflows/*`
- 模板、schema、workflow 之间的一致性

### 9.2 ops 负责执行
以下内容由 `ops` 负责物化与运行时创建：

- `~/.openclaw/workspaces/workspace-<agentId>/`
- `~/.openclaw/workspaces/workspace-daily-<userId>/`
- `~/.openclaw/agents/<agentId>/agent`
- `~/.openclaw/agents/<agentId>/sessions`
- `~/.openclaw/state/audit/*.jsonl`
- `state/*.json` 的运行时注册更新

### 9.3 critic 负责审查
以下内容由 `critic` 负责审查：

- bootstrap 物化结果
- daily 用户实例创建结果
- memory promotion
- route / review / signoff

---

## 10. 禁止事项

以下情况视为结构违规，应逐步清理：

1. 同时维护：
   - `~/.openclaw/workspace-<agentId>`
   - `~/.openclaw/workspaces/workspace-<agentId>`

2. 在 repo 根目录再维护一套平行的：
   - `workspaces/`
   - `agents/`
   - `templates/`
   - `state/`
   与 `~/.openclaw/` 长期分叉

3. 在 workflow / policy / schema 中使用含糊相对路径，
   让系统无法判断它到底相对于：
   - `~/.openclaw/`
   - 当前 workspace
   - 当前执行目录

4. 让 `agent-smith` 直接承担 runtime 物化职责

5. 让 `main workspace` 持续扩展成长期多角色超级 workspace

---

## 11. 统一复制/替换原则

本项目整理完成后，应遵循以下原则：

### 11.1 仓库结构即运行结构
仓库内的目录布局应尽可能与 `~/.openclaw/` 完全同构。

### 11.2 复制方式
用户应能够：

1. clone 仓库
2. 将仓库内容复制 / 覆盖到 `~/.openclaw/`
3. 按 bring-up 流程继续运行

### 11.3 不再维护多套结构
后续不再需要：
- “本地开发结构一套”
- “远程 OpenClaw 结构一套”
- “给 agent 看的一套逻辑结构”

应统一为：
- **所有文件最终都以 `~/.openclaw/` 结构为唯一标准**

---

## 12. 与 main workspace 退场的关系

这份路径标准建立后，意味着：

1. `main` 仍可保留
2. 但系统主职责应逐步迁入：
   - `workspaces/workspace-orchestrator`
   - `workspaces/workspace-ops`
   - `workspaces/workspace-agent-smith`
   - 等独立 workspace

### 当以下条件满足时，可推进 main 退场阶段
- core agents 已物化
- bring-up 已跑通
- daily 用户实例已稳定
- routing 与 ops allowlist 已验证
- critic 审查链路可用

在此之前：
- `main` 仅作过渡入口
- 不再新增长期职责

---

## 13. 本文件退役条件

满足以下条件时，`PATH-MAP.md` 可以退役：

1. 所有目录已按本文整理完成
2. workflow / policy / schema 中不存在歧义相对路径
3. 本地与远程均采用同一套 `~/.openclaw/` 结构
4. 团队成员无需再用此文档做“路径翻译”

退役后：
- 以真实目录结构为准
- `ARCHITECTURE.md`、`GOVERNANCE.md`、`FILE-NAMING.md` 继续保留
- `PATH-MAP.md` 可归档到参考目录或删除

---

*创建时间：2026-03-19*  
*最后更新：2026-03-19*  
*状态：v1 最终路径收口文档，完成整理后可退役*