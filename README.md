# Xuanzhi - OpenClaw Multi-Agent System v1

基于 OpenClaw 平台构建的多 Agent 协作系统骨架。

## 系统拓扑

| 角色 | 职责 |
|------|------|
| `orchestrator` | 主控：任务入口、分类、分解、分配、收敛 |
| `architect` | 架构设计、简单项目处理、复杂任务升级路由 |
| `ops` | 运维、部署、巡检、用户实例生命周期管理 |
| `daily-<userId>` | 按用户隔离的日常聊天与查询 |
| `skills-smith` | Skills 创建与维护 |
| `agent-smith` | Agent 模板与规范维护 |
| `critic` | 质量与风险审查、合规检查 |
| `claude-code` | 复杂开发任务的 ACP 长跑执行 |

## 四层分层结构

```
D:\Xuanzhi/
├── runtime/          # 运行时产品包 - 可复制到 ~/.openclaw/
├── spec/             # 规格与设计资料 - 研发态文档
├── reference/        # 外部参考资料 - OpenClaw 文档镜像
├── generated/        # 运行态生成物 - 不纳入版本控制
└── bootstrap/        # 引导脚本
```

详细导航参见 [REPO-MAP.md](./REPO-MAP.md)

### `runtime/` - 运行时产品包

可整体复制到 `~/.openclaw/` 的运行时资产：

```
runtime/
├── docs/system/           # 真相源文档
│   ├── ARCHITECTURE.md    # 架构定义
│   ├── GOVERNANCE.md      # 治理规则
│   └── FILE-NAMING.md     # 文件命名规范
├── policies/              # 策略配置
├── schemas/               # JSON Schema
├── workflows/             # 工作流定义
├── templates/             # Agent 模板
├── state/                 # 状态种子 (*.seed.json)
├── ops/                   # 运维资产
├── review/                # 审查资产
├── architect/             # 架构师资产
├── skills/                # Skills 说明
└── agents/                # Agent 目录说明
```

### `spec/` - 规格与设计资料

研发态文档，不参与运行时：

```
spec/
├── requirements/          # 需求规格
├── bringup/               # 启动说明
├── migration/             # 迁移资料
└── architecture/          # 架构设计
```

### `generated/` - 运行态生成物

运行时生成的文件，不纳入版本控制：

```
generated/
├── state/                 # 运行态状态
├── audit/                 # 审计日志
└── workspaces/            # 物化后的 workspace 实例
```

### `reference/` - 外部参考资料

```
reference/
├── openclaw/              # OpenClaw 官方文档镜像
└── indexes/               # 文档索引
```

## 快速开始

1. **阅读架构**: `runtime/docs/system/ARCHITECTURE.md`
2. **理解治理**: `runtime/docs/system/GOVERNANCE.md`
3. **启动顺序**: `spec/bringup/BRING-UP-ORDER.md`
4. **物化 Agent**: `runtime/workflows/system/materialize-core-agents.json`

## 下一步

1. 将 `runtime/` 内容复制到 `~/.openclaw/`
2. 配置 OpenClaw bindings
3. 运行 `materialize-core-agents` 工作流
4. 注册 `claude-code` 为 ACP runtime
5. 添加实际的安全策略和沙箱配置
