# PATH-MAP

本文档定义本项目在 **单一目录结构** 下的路径映射规则，统一约束：

1. **骨架逻辑路径** - 项目内使用的相对路径
2. **OpenClaw 实际路径** - OpenClaw 运行时使用的绝对路径
3. **引用关系** - 哪些文件、workflow、agent 会引用这些路径

---

## 0. 路径标准结论（v1）

当前环境采用以下统一路径标准：

1. 默认 `main` workspace：
   - `~/.openclaw/workspace`

2. 非 `main` 的独立 Agent workspace：
   - `~/.openclaw/workspaces/workspace-<agentId>`

3. Daily 用户独立 workspace：
   - `~/.openclaw/workspaces/workspace-daily-<userId>`

4. Agent 状态目录：
   - `~/.openclaw/agents/<agentId>/agent`

5. Agent session 目录：
   - `~/.openclaw/agents/<agentId>/sessions`

6. 系统级 state 目录：
   - `~/.openclaw/state/...`

7. 系统级 templates / workflows / policies / schemas / docs：
   - `~/.openclaw/<category>/...`

8. 本地与远程应尽量保持同构：
   - 开发、整理、同步时，原则上都以 `~/.openclaw/` 下的统一结构为准
   - 不再额外维护第二套或第三套不同命名风格的 workspace 集合

---

## 一、配置与状态路径

### 1.1 主配置文件

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `openclaw.json` | `~/.openclaw/openclaw.json` | 主配置文件 | Gateway, CLI, ACP |
| `OPENCLAW_CONFIG_PATH` | 环境变量覆盖 | 配置路径覆盖 | 部署脚本 |

**引用文件：**
- `workflows/users/create-daily-user.json` → `update_binding_config` 步骤
- `workflows/system/materialize-core-agents.json` → 依赖整体目录结构与配置有效

### 1.2 状态目录

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `state/agents/catalog.json` | `~/.openclaw/state/agents/catalog.json` | Agent 注册表 | orchestrator, ops, critic |
| `state/users/index.json` | `~/.openclaw/state/users/index.json` | 用户索引 | ops, critic |
| `state/skills/catalog.json` | `~/.openclaw/state/skills/catalog.json` | Skills 目录 | skills-smith |
| `state/router/tasks.json` | `~/.openclaw/state/router/tasks.json` | 任务队列 | orchestrator |
| `state/audit/` | `~/.openclaw/state/audit/` | 审计日志目录 | 所有 agents / workflows |

**引用文件：**
- `workflows/users/create-daily-user.json`
  - Step `register_user_state` → `state/users/index.json`
  - Step `register_agent_catalog` → `state/agents/catalog.json`
  - Step `write_audit` → `state/audit/user-provision.jsonl`
- `workflows/memory/promote.json`
  - Step `write_audit_record` → `state/audit/memory-promotion.jsonl`
- `workflows/system/materialize-core-agents.json`
  - Step `register_agent_in_catalog` → `state/agents/catalog.json`
  - Step `append_audit_entry` → `state/audit/core-agent-materialization.jsonl`

---

## 二、Agent Workspace 路径

### 2.1 Workspace 目录

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `workspaces/workspace-<agentId>/` | `~/.openclaw/workspaces/workspace-<agentId>/` | Core Agent workspace | OpenClaw Gateway |
| `workspaces/workspace-daily-<userId>/` | `~/.openclaw/workspaces/workspace-daily-<userId>/` | Daily 用户 workspace | ops（动态创建） |
| `workspace/` | `~/.openclaw/workspace/` | 默认 main workspace | main (default) |

### 2.2 Bootstrap 文件

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `AGENTS.md` | `<workspace>/AGENTS.md` | 操作指令与职责边界 | Agent loop |
| `SOUL.md` | `<workspace>/SOUL.md` | 风格、语调、边界 | Agent loop |
| `USER.md` | `<workspace>/USER.md` | 用户信息（主要用于 daily） | Agent loop |
| `IDENTITY.md` | `<workspace>/IDENTITY.md` | Agent 标识与定位 | Agent loop |
| `TOOLS.md` | `<workspace>/TOOLS.md` | 本地工具说明 | Agent loop |
| `MEMORY.md` | `<workspace>/MEMORY.md` | 长期记忆 | memory tools |
| `HEARTBEAT.md` | `<workspace>/HEARTBEAT.md` | 心跳任务说明 | heartbeat runner |
| `BOOT.md` | `<workspace>/BOOT.md` | 启动恢复指令 | Agent startup |
| `BOOTSTRAP.md` | `<workspace>/BOOTSTRAP.md` | 首次初始化说明 | Agent bootstrap |

**引用文件：**
- `workflows/users/create-daily-user.json`
  - Step `render_root_files` → daily workspace bootstrap 文件
- `workflows/system/materialize-core-agents.json`
  - Step `render_root_files` → core agent bootstrap 文件

### 2.3 Agent 运行目录结构

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `agents/<agentId>/agent/` | `~/.openclaw/agents/<agentId>/agent/` | Agent 状态目录 | Gateway |
| `agents/<agentId>/sessions/` | `~/.openclaw/agents/<agentId>/sessions/` | 会话存储 | session tools |
| `agents/<agentId>/agent/auth-profiles.json` | `~/.openclaw/agents/<agentId>/agent/auth-profiles.json` | 认证配置 | channel auth |

---

## 三、Memory 路径

### 3.1 双层 Memory

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `MEMORY.md` | `<workspace>/MEMORY.md` | 长期记忆 | memory_get, memory_search |
| `memory/YYYY-MM-DD.md` | `<workspace>/memory/YYYY-MM-DD.md` | 每日日志 | memory tools |

**引用文件：**
- `policies/memory-policy.json`
  - `layers.daily_memory.path_pattern` → `memory/YYYY-MM-DD.md`
  - `layers.long_term_memory.path` → `MEMORY.md`
- `workflows/memory/promote.json`
  - Step `append_long_term_memory` → `MEMORY.md`

### 3.2 Memory 搜索路径

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `<workspace>/` | Agent workspace | 主搜索路径 | memory_search |
| `memorySearch.extraPaths[]` | 配置扩展 | 额外搜索路径 | memory_search |

---

## 四、Templates 路径

### 4.1 Daily 用户模板

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `templates/daily-template/` | `~/.openclaw/templates/daily-template/` | Daily 用户模板目录 | ops, agent-smith |
| `templates/daily-template/*.tpl` | `~/.openclaw/templates/daily-template/*.tpl` | 模板文件 | create-daily-user workflow |
| `templates/daily-template/policies/` | `~/.openclaw/templates/daily-template/policies/` | 本地策略模板 | 实例化时复制 |
| `templates/daily-template/state/` | `~/.openclaw/templates/daily-template/state/` | 本地状态模板 | 实例化时复制 |

**引用文件：**
- `workflows/users/create-daily-user.json`
  - Step `copy_template` → `templates/daily-template`
  - Step `render_profile` → `profile.json`
  - Step `render_root_files` → 所有 `.tpl` 文件

### 4.2 Core Agent 模板

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `templates/core-agent/AGENTS.md.tpl` | `~/.openclaw/templates/core-agent/AGENTS.md.tpl` | Core agent AGENTS 模板 | materialize-core-agents |
| `templates/core-agent/SOUL.md.tpl` | `~/.openclaw/templates/core-agent/SOUL.md.tpl` | Core agent SOUL 模板 | materialize-core-agents |
| `templates/core-agent/IDENTITY.md.tpl` | `~/.openclaw/templates/core-agent/IDENTITY.md.tpl` | Core agent IDENTITY 模板 | materialize-core-agents |
| `templates/core-agent/TOOLS.md.tpl` | `~/.openclaw/templates/core-agent/TOOLS.md.tpl` | Core agent TOOLS 模板 | materialize-core-agents |
| `templates/core-agent/HEARTBEAT.md.tpl` | `~/.openclaw/templates/core-agent/HEARTBEAT.md.tpl` | Core agent HEARTBEAT 模板 | materialize-core-agents |
| `templates/core-agent/BOOT.md.tpl` | `~/.openclaw/templates/core-agent/BOOT.md.tpl` | Core agent BOOT 模板 | materialize-core-agents |
| `templates/core-agent/BOOTSTRAP.md.tpl` | `~/.openclaw/templates/core-agent/BOOTSTRAP.md.tpl` | Core agent BOOTSTRAP 模板 | materialize-core-agents |
| `templates/core-agent/MEMORY.md.tpl` | `~/.openclaw/templates/core-agent/MEMORY.md.tpl` | Core agent MEMORY 模板 | materialize-core-agents |

**引用文件：**
- `workflows/system/materialize-core-agents.json`
  - Step `validate_core_templates`
  - Step `render_root_files`

### 4.3 模板参考来源

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `templates/` | `~/.openclaw/templates/` | 项目主模板根目录 | agent-smith |
| `reference/openclaw/reference/templates/` | 本地参考资料 | OpenClaw 内置模板参考 | agent-smith |

---

## 五、Policies 路径

### 5.1 系统级策略

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `policies/routing-policy.json` | `~/.openclaw/policies/routing-policy.json` | 任务路由策略 | orchestrator |
| `policies/memory-policy.json` | `~/.openclaw/policies/memory-policy.json` | Memory 治理策略 | critic, memory workflow |
| `policies/tool-policy-matrix.json` | `~/.openclaw/policies/tool-policy-matrix.json` | 工具权限矩阵 | 所有 agents |

**引用文件：**
- `workflows/memory/promote.json`
  - Step `validate_candidate` → `policies/memory-policy.json`
- `docs/system/GOVERNANCE.md` → 引用所有策略文件
- `workflows/system/materialize-core-agents.json`
  - Step `validate_system_files` → `policies/routing-policy.json`, `policies/tool-policy-matrix.json`

### 5.2 Agent 本地策略

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `<workspace>/policies/local-tool-policy.json` | Workspace 内 | 本地工具策略覆盖 | Agent runtime |
| `<workspace>/policies/memory-policy.json` | Workspace 内 | 本地 Memory 策略覆盖 | Agent runtime |

**引用文件：**
- `templates/daily-template/policies/local-tool-policy.json` → 实例化时复制
- `templates/daily-template/policies/memory-policy.json` → 实例化时复制

---

## 六、Schemas 路径

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `schemas/task.schema.json` | `~/.openclaw/schemas/task.schema.json` | 任务结构定义 | orchestrator, workflows |
| `schemas/user-profile.schema.json` | `~/.openclaw/schemas/user-profile.schema.json` | 用户配置定义 | ops, create-daily-user |
| `schemas/review.schema.json` | `~/.openclaw/schemas/review.schema.json` | 审查记录定义 | critic |

**引用文件：**
- `workflows/users/create-daily-user.json`
  - Step `validate_input` → `schemas/user-profile.schema.json`
- `state/skills/catalog.json`
  - `inputSchema` → `schemas/task.schema.json`

---

## 七、Workflows 路径

### 7.1 系统工作流

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `workflows/system/materialize-core-agents.json` | `~/.openclaw/workflows/system/materialize-core-agents.json` | Core Agents 物化流程 | ops |
| `workflows/users/create-daily-user.json` | `~/.openclaw/workflows/users/create-daily-user.json` | 用户创建流程 | ops |
| `workflows/memory/promote.json` | `~/.openclaw/workflows/memory/promote.json` | Memory 升格流程 | critic |

**引用文件：**
- `workflows/system/materialize-core-agents.json`
  - Step `validate_system_files` → `docs/system/ARCHITECTURE.md`, `docs/system/GOVERNANCE.md`, `docs/system/PATH-MAP.md`, `docs/system/BRING-UP-ORDER.md`
  - Step `validate_core_templates` → `templates/core-agent/*.tpl`
  - Step `register_agent_in_catalog` → `state/agents/catalog.json`
  - Step `append_audit_entry` → `state/audit/core-agent-materialization.jsonl`

---

## 八、Skills 路径

### 8.1 Skills 目录

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `<workspace>/skills/` | Workspace 内 | 工作区特定 Skills | Agent runtime |
| `~/.openclaw/skills/` | `~/.openclaw/skills/` | 托管 Skills | 所有 agents |
| 内置 Skills | OpenClaw 安装目录 | 内置 Skills | 所有 agents |

### 8.2 Skills 结构

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `<skill-name>/SKILL.md` | Skills 目录内 | 技能定义文件 | skills loader |
| `<skill-name>/scripts/` | Skills 目录内 | 脚本目录 | skill execution |
| `<skill-name>/resources/` | Skills 目录内 | 资源目录 | skill execution |

---

## 九、Credentials 路径

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `~/.openclaw/credentials/` | `~/.openclaw/credentials/` | 凭证存储 | channel auth |
| `~/.openclaw/credentials/<channel>/<account>/` | 按渠道/账号 | 渠道凭证 | channel drivers |

**注意：** 凭证路径不应在项目骨架中硬编码，由 OpenClaw 运行时管理。

---

## 十、ACP 路径

### 10.1 ACP 配置

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `agents/claude-code/acp-config.json` | `~/.openclaw/agents/claude-code/acp-config.json` | ACP 连接配置 | claude-code agent |
| `agents/claude-code/handoff/` | `~/.openclaw/agents/claude-code/handoff/` | Handoff 文件目录 | orchestrator → claude-code |

### 10.2 Handoff 文件

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `TASK.json` | handoff 目录内 | 任务描述 | architect → claude-code |
| `PLAN.md` | handoff 目录内 | 执行计划 | architect → claude-code |
| `DECISIONS.md` | handoff 目录内 | 决策记录 | claude-code |
| `ACCEPTANCE.md` | handoff 目录内 | 验收标准 | critic |
| `NEXT_STEPS.md` | handoff 目录内 | 后续步骤 | claude-code → orchestrator |

**引用文件：**
- `policies/routing-policy.json`
  - `complexity_upgrade.handoff_required` → 所有 handoff 文件

---

## 十一、路径优先级

### 11.1 Skills 加载优先级

1. `<workspace>/skills/` - 工作区 Skills  
2. `~/.openclaw/skills/` - 托管 Skills  
3. 内置 Skills - OpenClaw 安装目录

### 11.2 配置覆盖优先级

1. 环境变量 (`OPENCLAW_*`)
2. 命令行参数 (`--url`, `--token` 等)
3. `openclaw.json`
4. 默认值

### 11.3 策略覆盖优先级

1. `<workspace>/policies/*.json` - 本地覆盖  
2. `~/.openclaw/policies/*.json` - 系统级  
3. OpenClaw 默认策略

---

## 十二、本地参考文档路径

### 12.1 需求文档

| 骨架逻辑路径 | 说明 | 状态 |
|-------------|------|------|
| `docs/requirements/open_claw多agent系统v1需求规格.md` | 系统需求规格 | ✅ 本地参考 |

### 12.2 参考文档索引

| 骨架逻辑路径 | 说明 | 状态 |
|-------------|------|------|
| `docs/reference/openclaw-docs-index.md` | OpenClaw 文档索引 | ✅ 本地参考 |
| `reference/openclaw/` | OpenClaw 官方文档集合 | ✅ 本地参考 |

---

## 十三、角色配置路径

### 13.1 角色清单与配置

| 骨架逻辑路径 | OpenClaw 实际路径 | 说明 | 引用方 |
|-------------|------------------|------|--------|
| `architect/handoff-checklist.md` | `~/.openclaw/architect/handoff-checklist.md` | Architect Handoff 清单 | architect → claude-code |
| `ops/ALLOWLIST.json` | `~/.openclaw/ops/ALLOWLIST.json` | Ops 允许列表 | ops agent |
| `review/critic-review-checklist.md` | `~/.openclaw/review/critic-review-checklist.md` | Critic 审查清单 | critic agent |

---

## 十四、统一目录策略（本地与远程）

### 14.1 原则

本项目不再长期维护多套不同命名和层级的 workspace 集合。  
后续整理原则如下：

1. 本地开发目录与远程 OpenClaw 目录尽量同构。
2. 核心运行目录统一以 `~/.openclaw/` 为根。
3. `main` 保留在 `~/.openclaw/workspace`。
4. 所有新增独立 Agent 一律放在：
   - `~/.openclaw/workspaces/workspace-<agentId>`
5. 所有 daily 用户实例一律放在：
   - `~/.openclaw/workspaces/workspace-daily-<userId>`

### 14.2 不再推荐的做法

以下做法应逐步停止：
- 同时维护 `workspace-<agentId>` 与 `workspaces/workspace-<agentId>` 两套路由
- 在项目根目录再复制一套独立 workspaces 集合
- 让本地骨架与远程运行目录长期结构不一致

---

## 十五、职责与待创建路径

以下路径在骨架中定义，但应区分“模板维护责任”和“物化执行责任”：

| 路径 | 类型 | 负责人 | 说明 |
|------|------|--------|------|
| `openclaw.json` | 配置 | ops | 运行时主配置 |
| `workspaces/workspace-orchestrator/` | Workspace | ops | 由 core materialization workflow 物化 |
| `workspaces/workspace-critic/` | Workspace | ops | 由 core materialization workflow 物化 |
| `workspaces/workspace-architect/` | Workspace | ops | 由 core materialization workflow 物化 |
| `workspaces/workspace-ops/` | Workspace | ops | 由 core materialization workflow 物化 |
| `workspaces/workspace-skills-smith/` | Workspace | ops | 由 core materialization workflow 物化 |
| `workspaces/workspace-agent-smith/` | Workspace | ops | 已存在，后续纳入统一治理 |
| `workspaces/workspace-claude-code/` | Workspace | ops | 先做最小目录物化 |
| `agents/<agentId>/agent/` | Agent 状态目录 | ops | 运行时目录物化 |
| `agents/<agentId>/sessions/` | Session 目录 | ops | 运行时目录物化 |
| `state/audit/*.jsonl` | 状态 / 审计 | workflows / ops | workflow 写入，ops 负责执行链路 |
| `templates/core-agent/*.tpl` | 模板 | agent-smith | 模板维护责任 |
| `templates/daily-template/*.tpl` | 模板 | agent-smith | 模板维护责任 |
| `workflows/system/materialize-core-agents.json` | 工作流 | agent-smith 维护 / ops 执行 | 施工蓝图与执行分离 |
| `workflows/users/create-daily-user.json` | 工作流 | agent-smith 维护 / ops 执行 | 用户实例创建 |
| `workflows/memory/promote.json` | 工作流 | agent-smith / critic | 记忆升格流程 |

**已完成的路径：**
- `templates/core-agent/*.tpl` - 已创建
- `workflows/system/materialize-core-agents.json` - 已创建

---

## 十六、远程服务器路径映射

### 16.1 服务器信息

| 服务器 | 地址 | 用户 | OpenClaw 根目录 |
|--------|------|------|-----------------|
| OpenClaw Server | `10.0.1.70` | `lc` | `~/.openclaw/` |

### 16.2 远程目录结构

| 本地骨架路径 | 远程实际路径 | 状态 |
|-------------|-------------|------|
| `openclaw.json` | `~/.openclaw/openclaw.json` | ✅ 已存在 |
| `state/agents/catalog.json` | `~/.openclaw/state/agents/catalog.json` | ✅ 已存在 |
| `state/users/index.json` | `~/.openclaw/state/users/index.json` | ✅ 已存在 |
| `state/skills/catalog.json` | `~/.openclaw/state/skills/catalog.json` | ✅ 已存在 |
| `state/router/tasks.json` | `~/.openclaw/state/router/tasks.json` | ✅ 已存在 |
| `state/audit/` | `~/.openclaw/state/audit/` | ✅ 已存在 |
| `templates/daily-template/` | `~/.openclaw/templates/daily-template/` | ✅ 已存在 |
| `templates/core-agent/` | `~/.openclaw/templates/core-agent/` | ✅ 已存在 |
| `workflows/users/` | `~/.openclaw/workflows/users/` | ✅ 已存在 |
| `workflows/memory/` | `~/.openclaw/workflows/memory/` | ✅ 已存在 |
| `workflows/system/` | `~/.openclaw/workflows/system/` | ✅ 已存在 |
| `policies/` | `~/.openclaw/policies/` | ✅ 已存在 |
| `schemas/` | `~/.openclaw/schemas/` | ✅ 已存在 |
| `docs/system/ARCHITECTURE.md` | `~/.openclaw/docs/system/ARCHITECTURE.md` | ✅ 已存在 |
| `docs/system/GOVERNANCE.md` | `~/.openclaw/docs/system/GOVERNANCE.md` | ✅ 已存在 |
| `docs/system/PATH-MAP.md` | `~/.openclaw/docs/system/PATH-MAP.md` | ✅ 已存在 |
| `docs/system/BOOTSTRAP-CHECKLIST.md` | `~/.openclaw/docs/system/BOOTSTRAP-CHECKLIST.md` | ✅ 已存在 |
| `docs/system/FILE-NAMING.md` | `~/.openclaw/docs/system/FILE-NAMING.md` | ✅ 已存在 |
| `docs/system/BRING-UP-ORDER.md` | `~/.openclaw/docs/system/BRING-UP-ORDER.md` | ⏳ 建议补齐 |
| `agents/claude-code/` | `~/.openclaw/agents/claude-code/` | ✅ 已存在 |

### 16.3 远程 Workspaces 映射

| Agent ID | 远程 Workspace 路径 | 状态 |
|----------|-------------------|------|
| `main` | `~/.openclaw/workspace` | ✅ 已存在 |
| `orchestrator` | `~/.openclaw/workspaces/workspace-orchestrator` | ✅ 已存在 |
| `critic` | `~/.openclaw/workspaces/workspace-critic` | ✅ 已存在 |
| `architect` | `~/.openclaw/workspaces/workspace-architect` | ✅ 已存在 |
| `ops` | `~/.openclaw/workspaces/workspace-ops` | ✅ 已存在 |
| `skills-smith` | `~/.openclaw/workspaces/workspace-skills-smith` | ✅ 已存在 |
| `agent-smith` | `~/.openclaw/workspaces/workspace-agent-smith` | ✅ 已存在 |
| `claude-code` | `~/.openclaw/workspaces/workspace-claude-code` | ⚠️ 路径存在，注册状态需单独核对 |

### 16.4 同步命令（仅在需要时使用）

```bash
# 同步文档
scp docs/system/*.md lc@10.0.1.70:~/.openclaw/docs/system/

# 同步 workflows
scp workflows/users/*.json lc@10.0.1.70:~/.openclaw/workflows/users/
scp workflows/memory/*.json lc@10.0.1.70:~/.openclaw/workflows/memory/
scp workflows/system/*.json lc@10.0.1.70:~/.openclaw/workflows/system/

# 同步 policies
scp policies/*.json lc@10.0.1.70:~/.openclaw/policies/

# 同步 schemas
scp schemas/*.json lc@10.0.1.70:~/.openclaw/schemas/

# 同步 templates
scp -r templates/daily-template lc@10.0.1.70:~/.openclaw/templates/
scp -r templates/core-agent lc@10.0.1.70:~/.openclaw/templates/