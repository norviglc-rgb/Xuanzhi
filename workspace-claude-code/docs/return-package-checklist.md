# claude-code return package checklist

## Input contract before execution
- TASK.json exists and `task.type = complex_development`
- PLAN.md exists
- DECISIONS.md exists
- ACCEPTANCE.md exists
- NEXT_STEPS.md exists
- TASK.route.targetAgent = claude-code
- TASK.route.runtime = acp
- TASK.route.reason is not empty

## Output contract after execution
- EXECUTION_REPORT.md exists
- EXECUTION_REPORT.md includes: scope, changed files, verification, unresolved risks
- ACCEPTANCE.md updated with pass/fail against criteria
- NEXT_STEPS.md updated with remaining actions and ownership
- DECISIONS.md updated when implementation choices changed

## Audit and handoff quality
- result summary is traceable to concrete file changes
- failed checks are explicit (do not hide failed tests)
- risk items are explicit and actionable
