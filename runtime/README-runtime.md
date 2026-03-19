# Runtime 运行时产品包

本目录是 Xuanzhi 多 Agent 系统的运行时产品包，可整体复制到 OpenClaw 运行环境。

## 映射到 ~/.openclaw/

| 本目录路径 | 目标路径 | 说明 |
|-----------|----------|------|
| `runtime/docs/system/` | `~/.openclaw/docs/system/` | 真相源文档 |
| `runtime/policies/` | `~/.openclaw/policies/` | 策略配置 |
| `runtime/schemas/` | `~/.openclaw/schemas/` | JSON Schema |
| `runtime/workflows/` | `~/.openclaw/workflows/` | 工作流定义 |
| `runtime/templates/` | `~/.openclaw/templates/` | Agent 模板 |
| `runtime/state/*.seed.json` | `~/.openclaw/state/*.json` | 初始状态 (去除 .seed 后缀) |
| `runtime/ops/` | `~/.openclaw/ops/` | 运维资产 |
| `runtime/review/` | `~/.openclaw/review/` | 审查资产 |
| `runtime/architect/` | `~/.openclaw/architect/` | 架构师资产 |
| `runtime/skills/` | `~/.openclaw/skills/` | Skills 说明 |

## Seed 文件说明

`runtime/state/` 下的 `*.seed.json` 文件是初始种子：

- `agents/catalog.seed.json` → 复制为 `~/.openclaw/state/agents/catalog.json`
- `users/index.seed.json` → 复制为 `~/.openclaw/state/users/index.json`
- `skills/catalog.seed.json` → 复制为 `~/.openclaw/state/skills/catalog.json`
- `router/tasks.seed.json` → 复制为 `~/.openclaw/state/router/tasks.json`

运行后，实际状态会在 `~/.openclaw/state/` 中被修改和更新。

## 真相源文档

`runtime/docs/system/` 包含系统真相源：

- **ARCHITECTURE.md**: 系统架构定义
- **GOVERNANCE.md**: 治理规则
- **FILE-NAMING.md**: 文件命名约定

这些文档定义了系统的核心规则，不应在运行时被修改。

## 工作流

| 工作流 | 用途 |
|--------|------|
| `workflows/system/materialize-core-agents.json` | 物化核心 Agent |
| `workflows/users/create-daily-user.json` | 创建用户级 Daily Agent |
| `workflows/memory/promote.json` | 记忆提升 |

## 模板

| 模板 | 用途 |
|------|------|
| `templates/core-agent/` | 核心系统 Agent 模板 |
| `templates/daily-template/` | 用户级 Daily Agent 模板 |

## 示例配置

参见 `openclaw.json.example` 了解 OpenClaw 配置示例。
