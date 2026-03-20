# M7 Governance Baseline Note

Date: 2026-03-20
Milestone: `m7`
Step: `s1` (`整理治理闭环输入基线`)

## 1. Minimum Completion Definition

### 1.1 `allowlist`

- 输入、目标、工具、路径、角色都必须落在显式 allowlist 内。
- allowlist 必须是可读、可审、可复用的固定版本。
- 任何未列入项一律拒绝，不做默认放行。
- 完成定义：已明确 allow / deny 边界，并能用一条记录判断一次请求是否命中 allowlist。

### 1.2 `review gate`

- 所有进入下一步的变更都必须先过 review gate。
- review gate 必须给出明确结论：`pass` / `fail` / `rework`。
- 不允许“先执行、后补审”。
- 完成定义： gate 能阻断未审输入，并保留可追溯的审查结论与原因。

### 1.3 `audit consistency`

- 每个关键动作都必须有对应审计记录，且能串成同一条链。
- 记录至少包含 `requestId`、`source`、`target`、`action`、`decision`、`timestamp`。
- 顺序必须一致，不能出现跳记录、倒序、断链。
- 完成定义：从输入到结论的证据链可重建，且与实际状态一致。

### 1.4 `heartbeat`

- 运行期必须持续发出 heartbeat，证明闭环仍在工作。
- heartbeat 必须包含最近一次活跃时间和当前健康状态。
- 超时、缺失、过期都视为异常。
- 完成定义：能稳定证明“活着”，并能被监测到中断。

## 2. Recommended Execution Order

1. `allowlist`
2. `audit consistency`
3. `review gate`
4. `heartbeat`

Reason:

- 先收紧输入边界，避免无关请求进入闭环。
- 再固定审计链，确保后续所有判断都有证据。
- 然后走 review gate，基于稳定证据做放行或回流。
- 最后验证 heartbeat，因为它依赖前面控制面已稳定。

## 3. Risk Boundary

必须停止的情况：

- allowlist 不明确，或存在未定义的默认放行。
- 请求触及未授权目标、路径、工具、角色。
- 审计链断裂、缺项、乱序，或无法对齐实际状态。
- review gate 无法给出明确结论，或要求先执行后审。
- heartbeat 超时、缺失、连续异常，或显示状态不可信。
- 出现跨边界写入、不可逆扩散、或疑似失控回写。

## 4. Rework Triggers

回流重做的条件：

- 任一完成定义未满足。
- 证据和实际状态不一致。
- 审核结论与审计记录冲突。
- allowlist、审计字段、review 规则、heartbeat 规则发生变更。
- 新增边界、路径、角色、工具，但未同步进基线。
- 任一环节出现超时、缺证、误放行、误阻断。

## 5. Acceptance Conclusion Template

```text
Result: pass | fail | rework
Scope: <what was checked>
Allowlist: <pass/fail and evidence>
Review gate: <pass/fail/rework and reason>
Audit consistency: <pass/fail and evidence>
Heartbeat: <pass/fail and status>
Risk boundary: <clear / stopped / violated>
Rework items: <none | list>
Final note: <one-line conclusion>
```

## 6. Baseline Complete

`m7/s1` baseline is complete when:

- four capabilities each have a minimum completion definition
- execution order and reason are explicit
- stop conditions and rework triggers are explicit
- conclusion template is ready for direct use
