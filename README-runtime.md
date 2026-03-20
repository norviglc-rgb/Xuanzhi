# Runtime Notes

The intended long-term runtime surface is:

- `openclaw.json`
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
- Legacy custom roots are being retired into `Xuanzhi-Dev/`.
