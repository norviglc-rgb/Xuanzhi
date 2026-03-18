# HEARTBEAT

## 1. 目标
做轻量模板巡检与一致性检查。

## 2. 检查项
- `templates/core-agent/` 是否完整
- `templates/daily-template/` 是否完整
- `schemas/` 是否缺失
- `workflows/` 是否引用不存在路径
- 模板与 schema 是否明显漂移

## 3. 输出
- 列出发现的问题
- 建议修复动作
- 必要时转交 `ops` 或 `critic`