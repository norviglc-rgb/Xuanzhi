# M7 Audit Consistency Report

Date: 2026-03-20
Milestone: `m7`
Step: `s3`

## 总结结论

**结论：通过。**

修复后，`ops-action-guard`、`user-provision`、`core-agent-materialization` 和新补齐的 `config-audit` 都已经满足当前审计一致性检查要求。其中 `ops-action-guard` 通过 handler 输出统一字段达标，`logs/audit` 下的三条运行时流则都补齐了初始化行和至少 1 条非初始化样例行。样例记录统一带有：

- `requestId`
- `source`
- `target`
- `action`
- `decision`
- `timestamp`

## 已检查的关键审计流

### 1) `ops-action-guard`

证据：

- [hooks/ops-action-guard/handler.ts](D:\Xuanzhi\hooks\ops-action-guard\handler.ts)

检查结果：

- `requestId` 已补齐，当前用 `null` 占位。
- `source` 已统一为 `gateway`。
- `target` 已统一为 `hooks/ops-action-guard/allowlist.json`。
- `action` 已统一为 `gateway_startup_guard_check`。
- `decision` 已统一为 `allow` / `deny`。
- `timestamp` 保持 ISO 时间戳。

判断：

- **通过**

残余风险：

- 这是启动期守卫留痕，不是请求级审计链，所以 `requestId` 继续保留 `null` 占位是当前场景下的合理边界。
- 该流的运行时留痕落在用户主目录下的 hook 日志，不在本次 `logs/audit/*.jsonl` 修复范围内。

### 2) `user-provision`

证据：

- [logs/audit/user-provision.jsonl](D:\Xuanzhi\logs\audit\user-provision.jsonl)

检查结果：

- `requestId` 已补齐。
- `source` 已统一为 `xuanzhi-runtime`。
- `target` 已统一为 `workspace-daily-example-user`。
- `action` 已统一为 `provision_user_instance`。
- `decision` 已统一为 `approved`。
- `timestamp` 已补齐。

判断：

- **通过**

残余风险：

- 当前样例主要用于证明字段一致性；后续如果补更多运行实例，仍应保持同一字段口径。

### 3) `core-agent-materialization`

证据：

- [logs/audit/core-agent-materialization.jsonl](D:\Xuanzhi\logs\audit\core-agent-materialization.jsonl)

检查结果：

- `requestId` 已补齐。
- `source` 已统一为 `xuanzhi-runtime`。
- `target` 已统一为 `agents/proof-agent/agent`。
- `action` 已统一为 `materialize_core_agent`。
- `decision` 已统一为 `approved`。
- `timestamp` 已补齐。

判断：

- **通过**

残余风险：

- 现有 runtime 样例可证明字段落地，但后续生产链路仍应继续保留同类字段，避免回退为仅事件名和状态码。

### 4) `config-audit`

证据：

- [logs/audit/config-audit.jsonl](D:\Xuanzhi\logs\audit\config-audit.jsonl)

检查结果：

- `requestId` 已补齐。
- `source` 已统一为 `xuanzhi-runtime`。
- `target` 已统一为 `state/config`。
- `action` 已统一为 `audit_config_materialization`。
- `decision` 已统一为 `approved`。
- `timestamp` 已补齐。

判断：

- **通过**

残余风险：

- `config-audit` 现在已经有独立命名的运行时样例，但后续仍建议与 `core-agent-materialization` 保持可交叉核验的字段口径。

## 最终判定

### 通过项

- 统一字段映射已经落地，`requestId/source/target/action/decision/timestamp` 在受检样例中齐全。
- `config-audit` 命名口径已经补齐，不再依赖同等流替代命名。
- `logs/audit/core-agent-materialization.jsonl`、`logs/audit/user-provision.jsonl` 和 `logs/audit/config-audit.jsonl` 都已经补齐初始化行与非初始化样例行。

### 未通过项

- 当前未发现新的未通过项。

## 说明

本次结论基于修复后的仓库事实。`ops-action-guard` 的 `requestId` 采用 `null` 占位，不影响本次一致性通过，但也说明它仍是启动期守卫记录，而不是请求级业务审计记录。
