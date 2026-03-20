---
name: workspace-integrity
description: "Audit required workspace files and log startup integrity results"
metadata: { "openclaw": { "emoji": "integrity", "events": ["gateway:startup"] } }
---

# Workspace Integrity

Checks that each managed workspace still contains the control files Xuanzhi relies on.

This hook is for startup auditing, not for tool-call interception.
