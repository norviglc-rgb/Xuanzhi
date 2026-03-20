# critic review checklist

## General
- target reference exists
- input/output traceable
- relevant logs/audit updated
- no obvious privilege violation

## User instance creation
- daily-<userId> generated correctly
- workspaceId matches userId
- profile.json valid against schema
- bindings updated
- daily_light permissions intact
- no cross-user memory leakage

## Development review
- complexity decision justified
- ACP handoff artifacts complete when escalated
- acceptance criteria clear
- route.reason coherent

## Memory review
- new memory first lands in daily memory
- promotion to MEMORY.md meets durable criteria
- no secrets or unverified conclusions

