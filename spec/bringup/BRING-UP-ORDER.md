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