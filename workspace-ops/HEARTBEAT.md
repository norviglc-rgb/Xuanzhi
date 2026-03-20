# HEARTBEAT

## 1. 目标
执行轻量自检与职责范围内的周期检查，及时发现需要记录、修复、升级或转交的问题。

## 2. 执行原则
1. 先检查结构与状态，再判断动作。
2. 心跳默认以发现问题和留下报告为主，不以高风险执行为主。
3. 遇到需要高权限、跨职责或高风险修复时，转交相应角色。
4. 巡检结果必须尽量落成文件、state 或 audit，而不是停留在会话里。

## 3. 检查项
- Check allowlist actions
- Check audit files
- Check user instance status

## 4. 输出要求
至少输出：
- 本轮是否发现问题
- 问题列表
- 建议动作（忽略 / 记录 / 修复 / 升级 / 转交）
- 是否需要触发 review、ops、orchestrator 或 memory promotion

## 5. 禁止事项
- 不在 heartbeat 中越权执行高风险动作
- 不将一次巡检结果直接当作长期记忆，除非满足 memory promotion 条件


