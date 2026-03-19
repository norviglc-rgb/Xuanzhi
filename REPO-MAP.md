# Xuanzhi 仓库导航

## 四层分层结构

```
D:\Xuanzhi/
├── runtime/          # 运行时产品包 - 可复制到 ~/.openclaw/
├── spec/             # 规格与设计资料 - 研发态文档
├── reference/        # 外部参考资料 - OpenClaw 文档镜像
├── generated/        # 运行态生成物 - 不纳入版本控制
└── bootstrap/        # 引导脚本
```

## 目录职责

### `runtime/` - 运行时产品包
**职责**: 存放可直接部署的运行时资产，可整体复制到 `~/.openclaw/`

| 子目录 | 内容 | 复制到 ~/.openclaw/ |
|--------|------|---------------------|
| `docs/system/` | 真相源文档 (ARCHITECTURE, GOVERNANCE, FILE-NAMING) | 是 |
| `policies/` | 策略配置 (memory, routing, tool-policy) | 是 |
| `schemas/` | JSON Schema 定义 | 是 |
| `workflows/` | 工作流定义 | 是 |
| `templates/` | Agent 模板 (core-agent, daily-template) | 是 |
| `state/` | 状态种子 (*.seed.json) | 是 (作为初始状态) |
| `ops/` | 运维资产 | 是 |
| `review/` | 审查资产 | 是 |
| `architect/` | 架构师资产 | 是 |
| `skills/` | Skills 说明 | 是 |
| `agents/` | Agent 目录说明 | 参考 |

### `spec/` - 规格与设计资料
**职责**: 存放需求规格、迁移资料、bring-up 说明

| 子目录 | 内容 |
|--------|------|
| `requirements/` | 需求规格文档 |
| `bringup/` | 启动说明、检查清单 |
| `migration/` | 迁移资料 (PATH-MAP 等) |
| `architecture/` | 架构设计、决策记录 |

**注意**: `spec/` 下的文档不参与运行时，仅供开发参考。

### `reference/` - 外部参考资料
**职责**: 存放外部文档镜像，便于离线查阅

| 子目录 | 内容 |
|--------|------|
| `openclaw/` | OpenClaw 官方文档镜像 |
| `indexes/` | 文档索引 |

### `generated/` - 运行态生成物
**职责**: 存放运行时生成的文件，**不纳入版本控制**

| 子目录 | 内容 |
|--------|------|
| `state/` | 运行态状态 |
| `audit/` | 审计日志 (*.jsonl) |
| `workspaces/` | 物化后的 workspace 实例 |

### `bootstrap/` - 引导脚本
**职责**: 存放初始化和引导脚本

## 映射关系

```
仓库路径                    →  运行时路径
runtime/                   →  ~/.openclaw/
runtime/state/*.seed.json  →  ~/.openclaw/state/*.json (初始复制)
generated/workspaces/*     →  ~/.openclaw/workspaces/* (运行时)
generated/audit/*.jsonl    →  ~/.openclaw/audit/*.jsonl (运行时)
```

## 快速导航

- **架构概览**: `runtime/docs/system/ARCHITECTURE.md`
- **治理规则**: `runtime/docs/system/GOVERNANCE.md`
- **需求规格**: `spec/requirements/open_claw多agent系统v1需求规格.md`
- **启动顺序**: `spec/bringup/BRING-UP-ORDER.md`
- **核心模板**: `runtime/templates/core-agent/`
- **物化工作流**: `runtime/workflows/system/materialize-core-agents.json`
