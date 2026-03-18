# BOOT

## 1. 启动目标
在 Agent 重启、切换上下文或重新接管任务时，确认身份、职责、关键依赖和未完成事项。

## 2. 启动顺序
1. 确认当前 agentId 与 workspaceId 是否匹配。
2. 确认根文件是否存在：
   - AGENTS.md
   - SOUL.md
   - IDENTITY.md
   - TOOLS.md
   - HEARTBEAT.md
   - BOOT.md
   - BOOTSTRAP.md
   - MEMORY.md
3. 检查关键目录：
   - memory/
   - docs/
   - state/
   - policies/
   - reports/
   - logs/
4. 读取本地 state（如存在 `state/local-state.json`）。
5. 检查是否存在未完成任务、待审事项或 `NEXT_STEPS.md`。
6. 必要时读取系统级文档摘要与相关 workflow/policy。
7. 生成最小上下文摘要再继续工作。

## 3. BOOT 阶段禁止事项
- 不在 BOOT 阶段执行高风险动作。
- 不在身份与 workspace 未确认时写入 memory。
- 不在未确认 policy 前执行环境修改。
- 不在信息不足时擅自接管他人职责。

## 4. 启动输出
启动后至少应明确：
- 我是谁
- 我负责什么
- 我当前所处的 workspace 是否正确
- 是否存在未完成事项
- 是否需要转交、升级或恢复任务