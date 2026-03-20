# Runtime Notes

The intended long-term runtime surface is:

- `openclaw.json`
- `docs/system/`
- `policies/`
- `schemas/`
- `workflows/`
- `state/`
- `agents/`
- `credentials/`
- `cron/`
- `hooks/`
- `logs/`
- `skills/`
- `workspace-*`

Current policy:

- Hard constraints belong in `openclaw.json`, `hooks/`, and machine-readable JSON under `skills/`.
- Soft behavioral guidance belongs in workspace bootstrap files.
- RG-01 anchors runtime truth for architecture/governance/policy/schema/workflow/state at root-level `docs/system`, `policies`, `schemas`, `workflows`, and `state`.
- Legacy custom roots are being retired into `Xuanzhi-Dev/`.
