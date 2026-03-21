---
name: xuanzhi-control
description: Use machine-readable placement and governance files to decide whether a workflow belongs in OpenClaw, NocoBase, or FastGPT.
user-invocable: false
---

# Xuanzhi Control

Use the JSON files in this folder before inventing new top-level runtime directories.

Canonical truth is still the root runtime files under `policies/` and `schemas/`.
Files in this skill are governance mirrors for decision assistance and must stay in sync with root truth.

Priority:

1. `control-model.json`
2. `workflow-placement.json`
3. `routing-policy.json`
4. `tool-policy-matrix.json`
5. `memory-policy.json`
6. `review.schema.json`

Rules:

- Prefer `openclaw.json` for hard runtime constraints.
- Prefer root `policies/*.json` and `schemas/*.json` when there is any conflict with this folder.
- Prefer `hooks/` for startup checks, audits, and event-driven automation.
- Prefer `openclaw.json.cron` for scheduling.
- Prefer workspace files for per-agent operating behavior.
- Prefer NocoBase for human approval and durable business state.
- Prefer FastGPT for RAG-heavy or LLM-only subflows.
