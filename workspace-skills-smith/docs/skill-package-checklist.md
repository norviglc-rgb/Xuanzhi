# skills-smith skill package checklist

## Minimum contract
- skill path exists
- SKILL.md exists
- SKILL.md contains frontmatter with `name` and `description`
- SKILL.md explicitly states source-of-truth precedence when policy/schema mirrors are used
- package contains at least one machine-readable governance file (`*.json`) when the skill claims routing/policy decisions

## Governance alignment
- skillId matches `state/skills/catalog.json` record
- owner is `skills-smith` unless explicitly delegated
- status transition follows `pending_review -> active|blocked|pending_review`
- review-gate decision and closure records are both present

## Safety and boundaries
- no hardcoded secrets/tokens/passwords
- no claim of runtime authority beyond root `policies/`, `schemas/`, and `workflows/`
- references to runtime paths match current root layout

## Handoff quality
- package purpose and placement are explicit
- interfaces section explains expected inputs/outputs
- limitations and non-goals are clearly stated
