# OpenClaw 多 Agent 系统

基于 OpenClaw 平台构建的多 Agent 协作系统。

## 项目目标

- **最小可运行**：v1 优先保证可运行、可自迭代、可审计、可回滚
- **多 Agent 协作**：按职责分层，支持开发、运维、日常问答
- **单一真相源**：文件化配置 + Git 版本管理

## 目录结构

```
D:\Xuanzhi\
├── docs/                            # 项目文档
│   ├── requirements/                # 需求规格
│   │   └── open-claw-multi-agent-v1-requirements.md
│   ├── system/                      # 系统文档（ARCHITECTURE.md, GOVERNANCE.md）
│   ├── design/                      # 设计文档
│   ├── decisions/                   # 决策记录
│   └── reference/                   # 参考文档索引
│       └── openclaw-docs-index.md   # OpenClaw 文档索引
├── reference/                       # 外部参考资料
│   └── openclaw/                    # OpenClaw 官方文档
└── README.md                        # 本文件
```

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
| `subagents` | 并行研究、慢任务后台处理 |

## 快速开始

1. 阅读 [需求规格](docs/requirements/open-claw-multi-agent-v1-requirements.md)
2. 参考 [OpenClaw 文档索引](docs/reference/openclaw-docs-index.md)

## 状态

🚧 项目初始化中
