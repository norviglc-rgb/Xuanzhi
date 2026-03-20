# M5 Real-Env Verification Note

Date: 2026-03-20
Milestone: `m5`
Step: `s4` (`完成真实环境等价验证与 critic review`)
Environment: `lc@10.0.1.70`

## Real-Env Evidence

- profile exists:
  - `~/.openclaw/workspaces/workspace-daily-test-user-001/profile.json`
- users index entry exists:
  - `~/.openclaw/state/users/index.json`
- audit chain exists (5 ordered events):
  - `~/.openclaw/state/audit/user-provision.jsonl`
- runtime registration exists:
  - `~/.openclaw/openclaw.json -> agents.list[id=daily-test-user-001]`

## Docker vs Real-Env Equivalence

Compared dimensions:

- derived naming (`daily-test-user-001`, `workspace-daily-test-user-001`)
- profile status (`pending_review`)
- users index mapping (`userId -> dailyAgentId/workspaceId`)
- audit event order (5-event minimum chain)
- registration entry presence

Result:

- structure and lifecycle semantics are equivalent between Docker proof and real environment.

## Conclusion

Real-environment equivalence check is passed.
