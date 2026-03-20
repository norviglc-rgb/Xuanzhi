# M7 Heartbeat Verification Note

Date: 2026-03-20
Milestone: `m7`
Step: `s4`

## 1. 修改点

- 将 `openclaw.json` 中 `agents.defaults.heartbeat.every` 从 `0m` 调整为 `10m`。
- 保持其余结构不变，不新增字段，不改变现有 agent 定义和 sandbox 配置。

## 2. 配置理由

- `0m` 不是可运行的稳定心跳间隔，容易被解释为关闭、无效或立即触发。
- `10m` 属于保守节奏，能满足“持续存在”的验证需求，同时避免过于频繁地产生噪音。
- 该值与现有配置结构兼容，只改动一个标量字段，回退成本低。

## 3. 稳定性检查项

1. `openclaw.json` 能被正常解析，且 JSON 结构保持完整。
2. `agents.defaults.heartbeat.every` 生效为 `10m`，没有被其他配置覆盖。
3. 启动后心跳行为按固定间隔运行，不出现连续触发、抖动或缺失。
4. 相关日志中能观察到稳定的 heartbeat 记录，且间隔与配置一致。
5. 不影响 `tools`、`skills`、`hooks`、`cron` 和各 agent 的权限边界。

## 4. 回滚方法

1. 打开 `openclaw.json`。
2. 将 `agents.defaults.heartbeat.every` 从 `10m` 改回原值 `0m`。
3. 保存文件并重载/重启使用该配置的运行环境。
4. 重新检查 heartbeat 是否恢复到原先状态，确认没有其他字段被改动。

## 5. 验收结论

- 当前配置将 heartbeat 调整为可运行的稳定间隔，适合作为 m7 的基础验证设置。
- 如果后续需要更积极的监测频率，可以在保持稳定性的前提下再评估 `5m`。
