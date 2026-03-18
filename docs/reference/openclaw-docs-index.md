# OpenClaw 文档索引

> 基于 `D:\Xuanzhi\reference\openclaw\` 目录整理

---

## 一、核心概念

### 1.1 架构概览
- **定位**：自我托管的网关，连接聊天应用与 AI 编码代理
- **核心组件**：Gateway（唯一网关） + Clients（WebSocket） + Nodes（设备能力）
- **协议**：WebSocket + JSON，默认端口 `127.0.0.1:18789`

### 1.2 Agent 组成
| 部分 | 说明 |
|------|------|
| Workspace | 代理的工作目录（cwd） |
| Bootstrap 文件 | AGENTS.md, SOUL.md, USER.md, IDENTITY.md, TOOLS.md, BOOTSTRAP.md |
| Built-in Tools | read/exec/edit/write 等核心工具 |
| Skills | 可加载的技能集 |
| Sessions | 会话存储 |

### 1.3 关键路径
| 路径 | 内容 |
|------|------|
| `~/.openclaw/openclaw.json` | 配置文件 |
| `~/.openclaw/workspace` | 默认工作区 |
| `~/.openclaw/agents/<agentId>/sessions/` | 会话记录 |
| `~/.openclaw/skills/` | 托管技能 |
| `~/.openclaw/credentials/` | OAuth 令牌、API 密钥 |

---

## 二、Workspace 标准结构

```
workspace/
├── AGENTS.md          # 操作指令和记忆
├── SOUL.md            # 人设、语调、边界
├── USER.md            # 用户信息
├── IDENTITY.md        # 代理名称、氛围、表情符号
├── TOOLS.md           # 本地工具说明
├── HEARTBEAT.md       # 心跳任务清单
├── BOOT.md            # 启动时执行的指令
├── BOOTSTRAP.md       # 首次运行初始化（完成后删除）
├── MEMORY.md          # 长期记忆
├── memory/
│   └── YYYY-MM-DD.md  # 每日日志
├── skills/            # 工作区特定技能
└── canvas/            # Canvas UI 文件
```

---

## 三、配置系统

### 3.1 Agent 配置
```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
      model: { primary: "anthropic/claude-sonnet-4-5" },
      heartbeat: { every: "30m", target: "last" },
      sandbox: { mode: "non-main", scope: "agent" },
    },
    list: [
      { id: "home", default: true, workspace: "~/.openclaw/workspace-home" },
      { id: "work", workspace: "~/.openclaw/workspace-work" },
    ],
  },
}
```

### 3.2 Bindings（路由绑定）
```json5
{
  bindings: [
    { agentId: "home", match: { channel: "whatsapp", accountId: "personal" } },
    { agentId: "work", match: { channel: "discord", guildId: "123456789" } },
  ],
}
```

**匹配优先级**：peer > guildId/teamId > accountId > 默认 agent

### 3.3 Tools 配置
```json5
{
  tools: {
    profile: "coding",  // minimal | coding | messaging | full
    allow: ["read", "write", "exec"],
    deny: ["browser", "canvas"],
    byProvider: {
      "openai/gpt-5.2": { allow: ["group:fs"] },
    },
  },
}
```

**工具分组**：
- `group:runtime`: exec, process, bash
- `group:fs`: read, write, edit, apply_patch
- `group:sessions`: sessions_list/history/send/spawn, session_status
- `group:memory`: memory_search, memory_get
- `group:web`: web_search, web_fetch
- `group:ui`: browser, canvas
- `group:messaging`: message

---

## 四、Skills 系统

### 4.1 Skill 结构
```
<skill-name>/
└── SKILL.md          # 必需：技能定义文件
    ├── scripts/      # 可选：脚本
    └── resources/    # 可选：资源
```

### 4.2 SKILL.md 格式
```markdown
---
name: skill-name
description: 简短描述
user-invocable: true
metadata:
  openclaw:
    emoji: "🎨"
    requires: { bins: ["uv"], env: ["API_KEY"] }
---

# Skill 指令
使用 {baseDir} 引用技能目录路径...
```

### 4.3 加载优先级
1. 工作区 Skills：`<workspace>/skills`
2. 托管 Skills：`~/.openclaw/skills`
3. 内置 Skills：随安装提供

### 4.4 CLI 命令
```bash
openclaw skills list              # 列出所有技能
openclaw skills list --eligible   # 仅列出有资格的
openclaw skills info <name>       # 查看详情
openclaw skills check             # 检查要求
```

---

## 五、Memory 系统

### 5.1 双层结构
- `MEMORY.md`：长期记忆（仅主会话加载）
- `memory/YYYY-MM-DD.md`：每日日志（append-only）

### 5.2 Memory 工具
- `memory_search`：语义检索
- `memory_get`：读取特定文件

### 5.3 向量搜索配置
```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "gemini",
        model: "gemini-embedding-001",
        extraPaths: ["../team-docs"],
      }
    }
  }
}
```

---

## 六、多 Agent 系统

### 6.1 添加 Agent
```bash
openclaw agents add work
openclaw agents add social
```

### 6.2 Per-Agent 配置
```json5
{
  agents: {
    list: [
      {
        id: "personal",
        sandbox: { mode: "off" }
      },
      {
        id: "family",
        sandbox: { mode: "all", scope: "agent" },
        tools: { allow: ["read"], deny: ["exec", "write", "edit"] }
      }
    ]
  }
}
```

### 6.3 CLI 命令
```bash
openclaw agents list --bindings
openclaw agents bind --agent work --bind telegram:ops
openclaw agents set-identity --agent main --name "OpenClaw" --emoji "🦞"
```

---

## 七、CLI 命令速查

### 7.1 常用命令
```bash
# 配置
openclaw configure                    # 交互式配置
openclaw config get/set/unset <path>  # 非交互式配置

# Agent
openclaw agent --to +123 --message "hello" --deliver
openclaw agent --agent ops --message "Summarize logs"

# Gateway
openclaw gateway                      # 启动网关
openclaw status                       # 查看状态
openclaw logs                         # 查看日志

# ACP
openclaw acp                          # 启动 ACP 桥接
openclaw acp --url wss://host:18789 --token <token>
```

### 7.2 全局标志
- `--dev`：使用 `~/.openclaw-dev`
- `--profile <name>`：使用 `~/.openclaw-<name>`
- `--no-color`：禁用颜色

---

## 八、部署

### 8.1 安装
```bash
# macOS / Linux / WSL2
curl -fsSL https://openclaw.ai/install.sh | bash

# Windows (PowerShell)
iwr -useb https://openclaw.ai/install.ps1 | iex
```

### 8.2 Docker 部署
```bash
./docker-setup.sh
```

### 8.3 生产环境要点
- **认证**：`OPENCLAW_GATEWAY_TOKEN` 必需
- **持久化**：挂载 `~/.openclaw` 和 `~/.openclaw/workspace`
- **内存**：推荐 2GB，512MB 太小
- **健康检查**：`/healthz`, `/readyz`

---

## 九、Hooks 和自动化

### 9.1 内部 Hooks
- `agent:bootstrap`：构建引导文件期间
- 命令 hooks：`/new`, `/reset`, `/stop`

### 9.2 插件 Hooks
| Hook | 时机 |
|------|------|
| `before_model_resolve` | 预会话，覆盖提供商/模型 |
| `before_prompt_build` | 会话加载后，注入上下文 |
| `agent_end` | 完成后检查 |
| `before_tool_call / after_tool_call` | 拦截工具 |
| `message_received / message_sending` | 消息钩子 |
| `session_start / session_end` | 会话生命周期 |

### 9.3 自动化
- **Cron**：`openclaw cron` 管理
- **Webhook**：`automation/webhook.md`
- **心跳**：`HEARTBEAT.md` + `heartbeat.every` 配置

---

## 十、文档路径索引

### 核心概念
- `reference/openclaw/index.md` - 总览
- `reference/openclaw/concepts/architecture.md` - 架构
- `reference/openclaw/concepts/agent.md` - Agent 概念
- `reference/openclaw/concepts/agent-workspace.md` - Workspace
- `reference/openclaw/concepts/memory.md` - Memory

### 配置
- `reference/openclaw/configuration/index.md` - 配置总览
- `reference/openclaw/configuration/agents.md` - Agent 配置
- `reference/openclaw/configuration/skills.md` - Skills 配置
- `reference/openclaw/configuration/tools.md` - Tools 配置
- `reference/openclaw/configuration/bindings.md` - Bindings

### Skills
- `reference/openclaw/skills/index.md` - Skills 总览
- `reference/openclaw/skills/creating-skills.md` - 创建 Skills

### 多 Agent
- `reference/openclaw/agents/index.md` - 多 Agent 总览
- `reference/openclaw/agents/multiple-agents.md` - 多 Agent 配置
- `reference/openclaw/agents/agent-templates.md` - Agent 模板

### 部署
- `reference/openclaw/deployment/index.md` - 部署总览
- `reference/openclaw/deployment/vps.md` - VPS 部署
- `reference/openclaw/pi.md` - Pi 部署

### CLI
- `reference/openclaw/cli/index.md` - CLI 总览
- `reference/openclaw/cli/agent.md` - agent 命令
- `reference/openclaw/cli/skills.md` - skills 命令
- `reference/openclaw/cli/config.md` - config 命令
- `reference/openclaw/cli/acp.md` - ACP 命令

### 自动化
- `reference/openclaw/automation/hooks.md` - Hooks
- `reference/openclaw/automation/cron-jobs.md` - Cron
- `reference/openclaw/automation/webhook.md` - Webhook

---

*最后更新：2026-03-18*
