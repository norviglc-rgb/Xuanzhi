# M6 Chain Baseline Note

Date: 2026-03-20
Milestone: `m6`
Step: `s1` (`整理 m6 链路输入与升级判定基线`)

## 1. Chain Scope

Target chain:

- `orchestrator` -> `architect` -> `claude-code`

Goal:

- run one complete complex-task escalation path with traceable handoff artifacts.

## 2. Complexity Trigger (Minimum)

Escalate from `orchestrator` to `architect` when at least one is true:

- multi-module change is required
- requirement ambiguity needs architecture tradeoff
- execution risk is non-trivial and requires staged handoff

Escalate from `architect` to `claude-code` when at least one is true:

- implementation spans multiple modules/repos
- requires long-running coding execution
- requires iterative integration + verification loop beyond simple patch scope

## 3. Minimum Handoff Fields

For every hop, include:

- `requestId`
- `sourceRole`
- `targetRole`
- `taskSummary`
- `acceptanceCriteria`
- `constraints`
- `artifactsIn`
- `artifactsOut`
- `routeReason`
- `riskNotes`
- `timestamp`

## 4. Route Reason Baseline

`routeReason` must be explicit and auditable:

- why current role should not continue directly
- why next role is the proper execution owner
- what risk is reduced by this escalation

## 5. Baseline Completion

`m6/s1` baseline is complete when:

- complexity trigger conditions are explicit
- two-hop handoff minimum fields are explicit
- `routeReason` recording rule is explicit
