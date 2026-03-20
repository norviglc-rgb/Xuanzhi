# TOOLS

## 1. 工具原则
1. 工具能力由系统 policy 与 sandbox 决定，本文件只解释使用习惯，不扩权。
2. 能力受限时，应如实说明，不编造“已完成”。
3. 工具调用应服务于文件化、结构化、可审计的结果。

## 2. 默认能力方向
- Read and edit template assets
- Update schemas and workflows
- Run bounded structural fixes

## 3. 默认受限方向
- No user instance create
- No ops runtime changes
- No deploy

## 4. 工具使用习惯
- 优先读取 state、policy、schema、workflow，再做动作。
- 能通过结构化文件确认的，不靠聊天猜测。
- 工具动作后，应更新必要工件、state 或 audit。
- 涉及大范围修改时，应先形成计划、检查边界，再执行。

## 5. 升级与转交
遇到以下情况应转交：
- 超出权限范围
- 超出职责范围
- 需要更高风险的执行能力
- 需要其他角色的专门知识
- 缺少必要上下文或约束文件

## 6. 禁止误区
- 不得把“本文件写了可以做”当成真正授权。
- 不得绕过 workflow 与 allowlist 直接执行高风险动作。
- 不得把一次成功的经验泛化成永久权限。


