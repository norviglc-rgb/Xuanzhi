# M3 Execution Proof

## Status

- milestone: `m3`
- step: `s4`
- status: completed draft

## Goal

Provide a minimal but real execution proof that `ops` can consume the m2 contract outputs and the m3 provisioning rules without falling back to legacy workflow assumptions.

## Proof Mode

This proof used `repo drill` mode instead of mutating active runtime truth.

Reason:

- it exercises the provisioning sequence end to end
- it produces file-backed artifacts and audit evidence
- it avoids polluting the active runtime before `m4` and `m5`

## Attempt Summary

- attempt id: `m3-proof-generic-001`
- track: generic agent provisioning
- target id: `proof-agent`
- proof root: `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/`

## Inputs Used

Request package:

- `agentId`: `proof-agent`
- `workspace`: `workspace-proof-agent`
- `agentDir`: `agents/proof-agent/agent`
- `tools.allow`: `["read"]`
- `tools.deny`: `["exec", "write", "edit", "apply_patch", "browser", "canvas"]`

Stored at:

- `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/request.json`

## Executed Actions

The repo drill performed these concrete actions:

1. created `workspace-proof-agent/`
2. created required root files:
   - `AGENTS.md`
   - `SOUL.md`
   - `IDENTITY.md`
   - `TOOLS.md`
   - `BOOT.md`
   - `BOOTSTRAP.md`
   - `HEARTBEAT.md`
   - `MEMORY.md`
3. created required directories:
   - `memory/`
   - `skills/`
   - `hooks/`
   - `docs/`
4. created runtime-owned directories:
   - `agents/proof-agent/agent/`
   - `agents/proof-agent/sessions/`
5. created a runtime registry snapshot with an added `proof-agent` entry:
   - `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/openclaw.proof.json`
6. appended audit events to:
   - `Xuanzhi-Dev/generated/audit/core-agent-materialization.jsonl`

## Self-Check Result

Recorded at:

- `Xuanzhi-Dev/generated/m3-dry-run/generic-agent-proof/self-check.json`

Observed result:

- `workspaceExists = true`
- `runtimeAgentDirExists = true`
- `runtimeSessionsDirExists = true`
- `requiredFilesPresent = true`
- `requiredDirsPresent = true`
- `registryEntryPresent = true`
- `status = passed`

## Audit Chain Result

Observed event chain for this attempt:

1. `requested`
2. `preflight_checked`
3. `workspace_materialized`
4. `runtime_dirs_materialized`
5. `registry_upserted`
6. `self_check_passed`
7. `review_requested`
8. `completed`

This confirms the `m3 / s3` audit model is executable in repo drill mode.

## What This Proof Demonstrates

- `ops` can consume a contract-shaped generic agent request package.
- `ops` can execute the generic provisioning sequence without using deprecated `workspaces/...` paths.
- the runtime registration model can be exercised through a snapshot update that matches the current `openclaw.json` structure.
- the audit model is concrete enough to emit an ordered event chain.
- the review handoff point is explicit and can be represented by a `review_requested` event.

## Limitations

- this proof used repo drill mode, not active runtime mutation.
- this proof covered the generic agent track only.
- generic agent allowlist hardening still has a gap: `hooks/ops-action-guard/allowlist.json` names daily-user lifecycle explicitly, but not generic provisioning as a named action.

## Conclusion

`m3 / s4` is satisfied by this proof.

It is strong enough to show that the provisioning contract, write rules, and review trigger can be executed coherently in a controlled drill without relying on legacy workflow files.
