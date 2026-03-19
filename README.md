# OpenClaw Multi-Agent System v1 Skeleton

This repository is a minimum viable skeleton for an OpenClaw-based multi-agent system.

## Topology
- orchestrator
- critic
- architect
- ops
- skills-smith
- agent-smith
- claude-code (ACP)
- daily-<userId> instances created from template

## Source of truth layers
- docs/system/ARCHITECTURE.md
- docs/system/GOVERNANCE.md
- policies/*.json
- schemas/*.json
- state/*.json
- database for index/audit only

## Directory Structure

```
D:\Xuanzhi/
│
├── README.md                              # 项目说明
│
├── docs/                                  # 文档
│   ├── decisions/                         # 决策记录 (空)
│   ├── design/                            # 设计文档 (空)
│   ├── reference/
│   │   └── openclaw-docs-index.md         # OpenClaw 文档索引
│   ├── requirements/
│   │   └── open_claw多agent系统v1需求规格.md  # 需求规格
│   └── system/
│       ├── ARCHITECTURE.md                # 架构定义
│       ├── BOOTSTRAP-CHECKLIST.md         # 启动检查清单
│       ├── BRING-UP-ORDER.md              # 启动顺序
│       ├── FILE-NAMING.md                 # 文件命名规范
│       ├── GOVERNANCE.md                  # 治理规则
│       └── PATH-MAP.md                    # 路径映射 (唯一真相源)
│
├── policies/                              # 策略配置
│   ├── memory-policy.json                 # 记忆策略
│   ├── routing-policy.json                # 路由策略
│   └── tool-policy-matrix.json            # 工具权限矩阵
│
├── schemas/                               # JSON Schema
│   ├── review.schema.json                 # 审查记录 schema
│   ├── task.schema.json                   # 任务 schema
│   └── user-profile.schema.json           # 用户画像 schema
│
├── workflows/                             # 工作流定义
│   ├── memory/
│   │   └── promote.json                   # 记忆提升工作流
│   ├── system/
│   │   └── materialize-core-agents.json   # Core Agent 物化工作流
│   └── users/
│       └── create-daily-user.json         # Daily User 创建工作流
│
├── templates/                             # 模板
│   ├── core-agent/                        # Core Agent 模板
│   │   ├── AGENTS.md.tpl                  # Agent 列表模板
│   │   ├── BOOT.md.tpl                    # 启动模板
│   │   ├── BOOTSTRAP.md.tpl               # 初始化模板
│   │   ├── HEARTBEAT.md.tpl               # 心跳模板
│   │   ├── IDENTITY.md.tpl                # 身份模板
│   │   ├── MEMORY.md.tpl                  # 记忆模板
│   │   ├── SOUL.md.tpl                    # 灵魂模板
│   │   └── TOOLS.md.tpl                   # 工具模板
│   └── daily-template/                    # Daily User 模板
│       ├── AGENTS.md.tpl
│       ├── BOOT.md.tpl
│       ├── BOOTSTRAP.md.tpl
│       ├── HEARTBEAT.md.tpl
│       ├── IDENTITY.md.tpl
│       ├── MEMORY.md.tpl
│       ├── profile.json.tpl               # 用户配置模板
│       ├── SOUL.md.tpl
│       ├── TOOLS.md.tpl
│       ├── USER.md.tpl
│       ├── policies/
│       │   ├── local-tool-policy.json     # 本地工具策略
│       │   └── memory-policy.json         # 记忆策略
│       └── state/
│           └── local-state.json           # 本地状态
│
├── state/                                 # 运行状态
│   ├── agents/
│   │   └── catalog.json                   # Agent 目录
│   ├── audit/
│   │   ├── core-agent-materialization.jsonl  # Agent 物化审计 (空)
│   │   ├── memory-promotion.jsonl         # 记忆提升审计 (空)
│   │   └── user-provision.jsonl           # 用户创建审计 (空)
│   ├── router/
│   │   └── tasks.json                     # 任务路由 (空: {})
│   ├── skills/
│   │   └── catalog.json                   # Skills 目录
│   └── users/
│       └── index.json                     # 用户索引 (空: {})
│
├── skills/                                # Skills 目录
│   └── README.md                          # Skills 说明
│
├── agents/                                # Agent 实例目录
│   ├── agent-smith/
│   │   ├── agent/                         # Agent 配置 (空)
│   │   └── sessions/                      # 会话记录 (空)
│   ├── architect/
│   │   ├── agent/                         # (空)
│   │   └── sessions/                      # (空)
│   ├── claude-code/
│   │   ├── agent/                         # (空)
│   │   └── sessions/                      # (空)
│   ├── critic/
│   │   ├── agent/                         # (空)
│   │   └── sessions/                      # (空)
│   ├── ops/
│   │   ├── agent/                         # (空)
│   │   └── sessions/                      # (空)
│   ├── orchestrator/
│   │   ├── agent/                         # (空)
│   │   └── sessions/                      # (空)
│   └── skills-smith/
│       ├── agent/                         # (空)
│       └── sessions/                      # (空)
│
├── workspaces/                            # Workspace 目录
│   ├── workspace-agent-smith/             # Agent Smith 工作区 (已物化)
│   │   ├── AGENTS.md                      # Agent 列表
│   │   ├── BOOT.md                        # 启动说明
│   │   ├── BOOTSTRAP.md                   # 初始化说明
│   │   ├── HEARTBEAT.md                   # 心跳配置
│   │   ├── IDENTITY.md                    # 身份定义
│   │   ├── MEMORY.md                      # 记忆配置
│   │   ├── SOUL.md                        # 灵魂定义
│   │   ├── TOOLS.md                       # 工具说明
│   │   ├── docs/                          # 文档副本
│   │   │   ├── ARCHITECTURE.md
│   │   │   ├── BOOTSTRAP-CHECKLIST.md
│   │   │   ├── FILE-NAMING.md
│   │   │   └── GOVERNANCE.md
│   │   ├── logs/                          # 日志 (空)
│   │   ├── memory/                        # 记忆存储 (空)
│   │   ├── policies/                      # 策略 (空)
│   │   ├── reports/                       # 报告 (空)
│   │   ├── schemas/                       # Schema 副本
│   │   │   ├── review.schema.json
│   │   │   ├── task.schema.json
│   │   │   └── user-profile.schema.json
│   │   ├── state/
│   │   │   └── local-state.json           # 本地状态
│   │   ├── templates/                     # (空)
│   │   └── workflows/                     # (空)
│   ├── workspace-architect/               # (空，待物化)
│   ├── workspace-claude-code/             # (空，待物化)
│   ├── workspace-critic/                  # (空，待物化)
│   ├── workspace-ops/                     # (空，待物化)
│   ├── workspace-orchestrator/            # (空，待物化)
│   └── workspace-skills-smith/            # (空，待物化)
│
├── ops/                                   # 运维
│   └── ALLOWLIST.json                     # 操作白名单
│
├── review/                                # 审查
│   └── critic-review-checklist.md         # Critic 审查清单
│
├── architect/                             # 架构
│   └── handoff-checklist.md               # 交接清单
│
└── reference/                             # 参考文档 (PATH-MAP 未定义)
    └── openclaw/                          # OpenClaw 官方文档 (651 文件)
```

### 文件状态说明

| 状态 | 含义 |
|------|------|
| (空) | 目录/文件已创建，无内容 |
| (空: {}) | JSON 文件仅包含空对象 |
| (待物化) | 等待 `materialize-core-agents` 工作流填充 |
| (已物化) | 已通过工作流填充内容 |

### 统计

- 目录：61 个
- 文件：66 个（不含 reference/）
- 空目录：`docs/decisions/`, `docs/design/`, 6 个待物化 workspace
- 空文件：3 个 `.jsonl` 审计文件，2 个 `{}` JSON 文件

## Next steps
1. Bind these files to your OpenClaw workspaces.
2. Wire `ops` to `workflows/users/create-daily-user.json`.
3. Register `claude-code` as ACP runtime.
4. Add your real bindings and sandbox/tool policies.
