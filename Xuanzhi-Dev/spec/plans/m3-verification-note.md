# M3 Verification Note

## Status

- milestone: `m3`
- step: `s5`
- status: review draft

## Verification Goal

Check whether `m3` has moved `ops` from a role description into a concrete provisioning executor with:

- explicit execution contract
- explicit state/audit/review write rules
- at least one real dry-run or equivalent execution proof

## Checked Artifacts

Boundary baseline:

- `m3-agent-provisioning-boundary.md`
- `m3-daily-provisioning-boundary.md`
- `m3-provisioning-boundary-draft.md`

Execution contract:

- `m3-agent-provisioning-execution.md`
- `m3-daily-provisioning-execution.md`
- `m3-ops-provisioning-contract.md`

Write rules:

- `m3-agent-state-audit-review-rules.md`
- `m3-daily-state-audit-review-rules.md`
- `m3-state-audit-review-rules.md`

Execution proof:

- `m3-execution-proof.md`
- `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/request.json`
- `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/openclaw.proof.json`
- `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/self-check.json`
- `Xuanzhi-Dev/generated/audit/core-agent-materialization.jsonl`

## Verification Results

### 1. Provisioning Boundary

Result: pass

Reason:

- `agent-smith -> ops -> critic` ownership boundaries are explicit
- generic agent and daily-user tracks are separated where they need different rules
- deprecated `workspaces/...` and `templates/core-agent/*` models are explicitly excluded

### 2. Provisioning Execution Contract

Result: pass

Reason:

- `ops` now has a concrete step sequence for both generic agent and daily-user provisioning
- preflight, execution, failure handling, and pre-review self-check are all explicit
- the contract stays within `ops` execution ownership and does not redefine scaffold ownership

### 3. State / Audit / Review Write Rules

Result: pass

Reason:

- generic agent writes are reduced to runtime filesystem + registry + single audit stream
- daily-user writes are reduced to profile + registration + users index + single audit stream
- `critic` trigger conditions are explicit for both tracks
- overdesigned extra stores and schemas were deferred instead of smuggled in

### 4. Real Execution Evidence

Result: pass

Reason:

- a generic-agent repo drill was executed with attempt id `m3-proof-generic-001`
- the proof produced a request package, filesystem outputs, a registry snapshot, a self-check result, and an audit chain
- the self-check passed and the audit chain reached `review_requested` and `completed`

## Residual Risks

1. generic-agent provisioning still lacks an explicit named allowlist action in `hooks/ops-action-guard/allowlist.json`
2. daily-user track has rule coverage and execution contract, but not yet its own dry-run proof

## Verification Conclusion

`m3` satisfies its completion criteria.

The milestone is strong enough to close because it now has:

- executable provisioning contracts
- explicit state/audit/review rules
- one real execution proof
- clear residual risks recorded for follow-up instead of being hidden
