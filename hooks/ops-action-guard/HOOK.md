---
name: ops-action-guard
description: "Audit ops-agent guardrails against the local allowlist"
metadata: { "openclaw": { "emoji": "guard", "events": ["gateway:startup"] } }
---

# Ops Action Guard

Verifies that the ops policy file exists and records the current guard state at startup.

Important: this hook audits. The actual hard boundary lives in `openclaw.json` agent tool permissions and sandbox settings.
