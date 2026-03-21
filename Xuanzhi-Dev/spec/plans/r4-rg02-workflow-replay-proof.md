# R4 RG-02 Workflow Replay Proof

## Run commands (2026-03-20)

- `powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/workflow-materialize-core-agents.ps1`
  - Appended JSON L audit entries to `logs/audit/materialize-core-agents.jsonl` and refreshed `state/workflows/materialize-core-agents.json`.
  - Each audit record now carries the required `requestId/source/target/action/decision/timestamp` envelope as well as the originating `workflowId`.

- `powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/workflow-create-daily-user.ps1`
  - Created new audit lines in `logs/audit/create-daily-user.jsonl` and recorded the input summary in `state/workflows/create-daily-user.json`.
  - The state artifact mirrors the most recent audit event, making the same key fields available for playback verification.

- `powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/workflow-memory-promote.ps1`
  - Added entries to `logs/audit/memory-promote.jsonl` and bumped `state/workflows/memory-promote.json` with the latest decision details.
  - Promoter-level metadata (`owner` = `critic`, `decision` = `success`, etc.) now lives in both audit and state.

- `powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File Xuanzhi-Dev/testing/scripts/workflow-replay-r4.ps1`
  - Ran the three scripts in sequence, printed the per-workflow digest (workflowId/requestId/step count/audit log path) and returned the same summary objects so external systems can act on the run.

## Evidence artifacts

- Audit logs: `logs/audit/materialize-core-agents.jsonl`, `logs/audit/create-daily-user.jsonl`, `logs/audit/memory-promote.jsonl`
- State pivots: `state/workflows/materialize-core-agents.json`, `state/workflows/create-daily-user.json`, `state/workflows/memory-promote.json`
- Each of the above files now embeds `requestId`, the source/target roles, the action/decision pair, and the ISO timestamp that RG-02 demands.

## Verification

- `python -m unittest tests.test_workflow_runtime_replay` (2026-03-20) — PASS. The suite executes every runtime script, checks the corresponding state file for the expected metadata, and replay-confirms that the audit log contains entries with `requestId`, `source`, `target`, `action`, `decision`, and `timestamp`.

This run documents the executable proofs for RG-02 and moves the feature from `todo` to `done` in preparation for the R4 gate.
