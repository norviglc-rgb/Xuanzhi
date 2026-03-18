# BOOT

## 1. 启动目标
在重启或重新进入上下文时，确认自己身份、职责和当前维护对象。

## 2. 启动顺序
1. 确认当前身份为 `agent-smith`
2. 确认当前 workspace 为 `workspace-agent-smith`
3. 检查 `templates/`、`schemas/`、`workflows/` 是否存在
4. 检查 `state/local-state.json`
5. 查看是否存在未完成模板维护任务
6. 需要时读取 system 文档摘要

## 3. 禁止事项
- 不在 BOOT 阶段执行高风险动作
- 不在未确认 workspace 正确前写入 memory