# M7 Allowlist Proof

Date: 2026-03-20
Milestone: `m7`
Step: `s2`

## 结论

当前仓库里存在可执行的 allowlist 证据，但只覆盖到“存在、可读、可审、可被 hook 读取”这一层，尚未证明所有预期动作都已被显式命名并纳入同一条 allowlist 规则链。

### 通过项

1. `allowlist` 文件真实存在，且采用显式规则而不是默认放行。
2. `ops-action-guard` hook 会在 `gateway:startup` 时读取 allowlist 路径并记录当前状态。
3. `openclaw.json` 中对 `ops` 的工具权限做了实际收口，和 allowlist 的“拒绝默认放行”方向一致。
4. generic provisioning 已补入显式 action id，和 daily-user lifecycle 保持对称命名。
5. allowlist 可以通过独立脚本对 `action + scope` 做命中判定，并返回命中规则 id。

### 未通过项

1. 暂无。

## 检查项

| 检查项 | 证据路径 | 结论 | 说明 |
|---|---|---|---|
| allowlist 文件存在且可读 | `D:\Xuanzhi\hooks\ops-action-guard\allowlist.json` | 通过 | 文件包含 `version`、`owner`、`rules`、`denyByDefault`、`approvalSystem`。 |
| 规则是显式 allow / deny 边界 | `D:\Xuanzhi\hooks\ops-action-guard\allowlist.json` | 通过 | 规则里明确列出 `read_logs`、`restart_service`、`deploy`、`install_package`、`manage_daily_user_instance`。 |
| hook 能读取 allowlist 并留痕 | `D:\Xuanzhi\hooks\ops-action-guard\HOOK.md`，`D:\Xuanzhi\hooks\ops-action-guard\handler.ts` | 通过 | hook 在 startup 读取 allowlist 路径，并把 `allowlistPresent` 写入 `~/.openclaw/logs/ops-guard.jsonl`。 |
| hard boundary 不是仅靠 allowlist 文案 | `D:\Xuanzhi\openclaw.json` | 通过 | `ops` 工具面限制了 `write/edit/apply_patch`，并保留 `exec` 仅给 `ops` 使用。 |
| generic provisioning action 已显式纳入 allowlist | `D:\Xuanzhi\hooks\ops-action-guard\allowlist.json`，`D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m3-review-and-rework.md` | 通过 | 新增 `ops-generic-agent-provisioning`，action 为 `manage_generic_agent_instance`，scope 覆盖 `workspace-*` 与 `agents/*`。 |
| allowlist 命中可用一条记录复现判断 | `D:\Xuanzhi\hooks\ops-action-guard\validate-allowlist.js` | 通过 | 可用脚本输入 `action + scope`，直接返回 `allow/deny` 和命中的 `ruleId`。 |

## 风险与建议

- 风险：把“文件存在”误判成“动作已被安全执行”，会掩盖未命名动作的扩展风险。
- 风险：allowlist 仍然是默认拒绝，未命中的 action 会继续被阻断，这符合当前边界设计。
- 建议：如果后续要扩展 generic provisioning 的子动作，继续沿用显式 action id，避免把 scope 膨胀成隐式放行。

## 命中判定

命令：

```bash
node hooks/ops-action-guard/validate-allowlist.js manage_generic_agent_instance workspace-demo-agent
```

输出样例：

```json
{"decision":"allow","ruleId":"ops-generic-agent-provisioning","action":"manage_generic_agent_instance","scope":"workspace-demo-agent"}
```

补充验证：

```bash
node hooks/ops-action-guard/validate-allowlist.js manage_generic_agent_instance agents/daily-demo-01
```

输出样例：

```json
{"decision":"allow","ruleId":"ops-generic-agent-provisioning","action":"manage_generic_agent_instance","scope":"agents/daily-demo-01"}
```

默认拒绝样例：

```bash
node hooks/ops-action-guard/validate-allowlist.js destroy_instance workspace-demo-agent
```

输出样例：

```json
{"decision":"deny","ruleId":null,"action":"destroy_instance","scope":"workspace-demo-agent"}
```
