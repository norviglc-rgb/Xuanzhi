# M6 Handoff Artifacts Spec

Date: 2026-03-20
Milestone: `m6`
Step: `s2` (`定义 complex chain 最小可执行 handoff 工件规范`)

## 1. Purpose

This spec defines the minimum executable handoff artifacts for the `m6` complex chain:

- `orchestrator` -> `architect`
- `architect` -> `claude-code`

The goal is to make escalation auditable, traceable, and safe to resume without re-deriving hidden context.

## 2. Shared Minimum Fields

Every handoff object must include the following fields:

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

Field meaning is consistent across both hops:

- `requestId`: stable identifier shared across the full chain
- `sourceRole`: current owner handing off work
- `targetRole`: next owner expected to continue
- `taskSummary`: one-paragraph summary of the current execution objective
- `acceptanceCriteria`: concrete pass conditions for the next owner
- `constraints`: hard limits, non-goals, and environment boundaries
- `artifactsIn`: exact inputs the current owner already has and is passing forward
- `artifactsOut`: exact outputs the target owner must produce or update
- `routeReason`: why the handoff happens now
- `riskNotes`: known risks, unknowns, and watch items
- `timestamp`: creation time of the handoff artifact in ISO 8601

## 3. Hop 1: `orchestrator` -> `architect`

Use this hop when the task is too ambiguous, too cross-cutting, or too high-risk for direct execution.

### 3.1 Input / Output Field Table

| Field | Input to `architect` | Output expected from `orchestrator` handoff |
|---|---|---|
| `requestId` | Must be reused unchanged | Must be present and chain-stable |
| `sourceRole` | `orchestrator` | Must identify the current owner |
| `targetRole` | `architect` | Must identify the next owner |
| `taskSummary` | Architecture-level summary of the problem | Must compress the user request into execution scope |
| `acceptanceCriteria` | Success criteria for design decisions | Must state what "good" looks like before implementation |
| `constraints` | System, policy, scope, and timing limits | Must list known hard boundaries and exclusions |
| `artifactsIn` | Problem statement, context, links, prior decisions | Must enumerate what evidence is being handed over |
| `artifactsOut` | Architecture brief, decision record, implementation plan | Must define the deliverables the architect must produce |
| `routeReason` | Justification for escalation to architecture | Must explain why execution should not start yet |
| `riskNotes` | Ambiguity, coupling, migration, rollback risk | Must surface the risks that need architectural handling |
| `timestamp` | Creation time of the handoff | Must be machine-readable and current |

### 3.2 `routeReason` Writing Rules

`routeReason` for this hop must explicitly answer all three questions:

1. Why the `orchestrator` should not continue directly
   - Example reasons: requirement ambiguity, multi-module coupling, missing tradeoff decision, hidden migration risk.
2. Why the `architect` is the best next owner
   - Example reasons: the task needs system decomposition, interface definition, dependency ordering, or rollback design.
3. What risk is reduced by escalating now
   - Example reasons: avoids incorrect implementation path, prevents rework, avoids leaking assumptions into code, reduces coordination drift.

Writing constraints:

- write in plain, testable language
- mention the specific uncertainty or dependency, not a generic "needs review"
- tie the escalation to a concrete risk reduction
- avoid repeating `taskSummary`; `routeReason` must justify the ownership change

### 3.3 Minimum Artifact Shape

`orchestrator` should pass:

- user or system request
- current milestone or chain context
- known constraints and exclusions
- any existing artifacts relevant to the decision

`architect` should return:

- scoped architecture decision
- implementation sequence
- dependency and interface notes
- risk mitigations and fallback path

## 4. Hop 2: `architect` -> `claude-code`

Use this hop only after the architecture is specific enough for direct implementation.

### 4.1 Input / Output Field Table

| Field | Input to `claude-code` | Output expected from `architect` handoff |
|---|---|---|
| `requestId` | Must be reused unchanged | Must remain the same across the chain |
| `sourceRole` | `architect` | Must identify the current owner |
| `targetRole` | `claude-code` | Must identify the implementation owner |
| `taskSummary` | Implementation-ready task summary | Must narrow architecture into concrete execution work |
| `acceptanceCriteria` | Verifiable completion checks | Must be measurable and directly testable |
| `constraints` | Runtime, repository, and tooling constraints | Must include non-negotiable implementation limits |
| `artifactsIn` | Architecture brief, decisions, references, prior diffs | Must list everything the implementer needs to continue safely |
| `artifactsOut` | Code changes, tests, verification notes, updated artifacts | Must define the expected implementation outputs |
| `routeReason` | Justification for implementation handoff | Must explain why architecture should stop and coding should start |
| `riskNotes` | Integration risk, test gaps, rollback points | Must surface the remaining execution risks |
| `timestamp` | Creation time of the handoff | Must be machine-readable and current |

### 4.2 `routeReason` Writing Rules

`routeReason` for this hop must explicitly answer all three questions:

1. Why the `architect` should not continue directly
   - Example reasons: the remaining work is code-level, requires iterative edit/test cycles, or depends on repo-local execution details.
2. Why `claude-code` is the most suitable owner
   - Example reasons: the task needs direct file edits, verification runs, test updates, or incremental integration.
3. What risk is reduced by escalating now
   - Example reasons: avoids design-only handoff drift, reduces mismatch between plan and implementation, keeps implementation decisions close to the codebase truth.

Writing constraints:

- state the implementation boundary clearly
- mention the exact repo or runtime evidence that makes implementation safe to start
- do not use vague phrases like "needs coding" without naming the remaining work
- keep the reason specific to this hop; do not restate hop 1

### 4.3 Minimum Artifact Shape

`architect` should pass:

- architecture decision record
- interface and dependency map
- implementation order
- verification expectations
- rollback or fallback assumptions

`claude-code` should return:

- code or document changes
- validation evidence
- updated handoff or review artifacts if required by the chain

## 5. Minimal JSON Samples

### 5.1 Sample: `orchestrator` -> `architect`

```json
{
  "requestId": "m6-20260320-001",
  "sourceRole": "orchestrator",
  "targetRole": "architect",
  "taskSummary": "Prepare the m6 complex-chain handoff design for a multi-module change that cannot be safely implemented without resolving ownership, dependency order, and rollback boundaries first.",
  "acceptanceCriteria": [
    "The scope is decomposed into implementable sub-problems.",
    "The ownership boundary between planning and execution is explicit.",
    "The highest-risk assumptions are called out with mitigation options."
  ],
  "constraints": [
    "Do not start code changes before the design is stabilized.",
    "Preserve the current m6 chain context.",
    "Keep the handoff minimal and traceable."
  ],
  "artifactsIn": [
    "m6 chain baseline note",
    "user request summary",
    "current plan context"
  ],
  "artifactsOut": [
    "architecture decision note",
    "implementation sequencing notes",
    "risk and rollback notes"
  ],
  "routeReason": "The request spans multiple moving parts and still has design uncertainty, so the orchestrator should stop before encoding assumptions into execution. The architect is the right owner because this step needs decomposition, boundary setting, and dependency ordering. Escalating now reduces the risk of premature implementation, hidden coupling, and expensive rework.",
  "riskNotes": [
    "Requirements may be incomplete.",
    "A wrong dependency order could create avoidable churn.",
    "Rollback boundaries are not yet fixed."
  ],
  "timestamp": "2026-03-20T18:50:00+08:00"
}
```

### 5.2 Sample: `architect` -> `claude-code`

```json
{
  "requestId": "m6-20260320-001",
  "sourceRole": "architect",
  "targetRole": "claude-code",
  "taskSummary": "Implement the approved m6 complex-chain handoff artifact spec in the designated spec file, keeping the output minimal, executable, and aligned with the current plan language.",
  "acceptanceCriteria": [
    "The target file is updated with the required fields, rules, samples, checklist, and rollback guidance.",
    "The content stays aligned with m6 complex-chain context.",
    "No unrelated files are modified."
  ],
  "constraints": [
    "Edit only the approved spec file.",
    "Do not weaken the minimum field set.",
    "Preserve existing plan terminology where applicable."
  ],
  "artifactsIn": [
    "architect decision note",
    "field contract",
    "routeReason writing rules",
    "verification expectations"
  ],
  "artifactsOut": [
    "updated m6 handoff artifacts spec",
    "acceptance checklist",
    "failure and rollback guidance"
  ],
  "routeReason": "The remaining work is repository-local document execution, not further design. Claude-code is the right owner because the task requires direct file editing and final content shaping against the current repo truth. Escalating now reduces the risk of design drift, stale wording, and a handoff that never becomes actionable.",
  "riskNotes": [
    "A previous draft could conflict with the required field list.",
    "The spec must stay narrow enough to remain executable.",
    "A malformed example would reduce downstream auditability."
  ],
  "timestamp": "2026-03-20T18:55:00+08:00"
}
```

## 6. Acceptance Checklist

Before marking the handoff spec ready, confirm all of the following:

- field completeness
  - each hop includes all required fields
  - each field has an unambiguous meaning
- traceability
  - `requestId` stays stable across both hops
  - `sourceRole` and `targetRole` match the actual chain direction
  - `timestamp` is present and machine-readable
- auditability
  - `routeReason` explains the stop point, target choice, and risk reduction
  - `riskNotes` list concrete execution risks, not generic warnings
  - `artifactsIn` and `artifactsOut` are specific enough to inspect later
- consistency
  - the two JSON samples use the same field set
  - acceptance criteria match the hop's actual ownership
  - constraints do not contradict the stated task

## 7. Common Failures And Rollback Advice

### 7.1 Common Failures

- missing field
  - symptom: a hop omits `riskNotes` or `artifactsOut`
  - impact: the chain becomes hard to audit and resume
- role drift
  - symptom: `sourceRole` or `targetRole` does not match the actual owner
  - impact: the handoff no longer reflects real accountability
- weak `routeReason`
  - symptom: the reason says only "needs escalation" without naming the specific blocker
  - impact: the escalation is not reviewable or repeatable
- vague artifacts
  - symptom: `artifactsIn` or `artifactsOut` uses broad labels like "docs" or "context"
  - impact: the next owner cannot determine what to continue from
- inconsistent criteria
  - symptom: acceptance criteria describe a different hop or a different milestone
  - impact: the handoff cannot be used as a reliable execution contract

### 7.2 Rollback Advice

- if a handoff is incomplete, keep the last valid handoff artifact and mark the new one as draft
- if a field is wrong, patch only the affected handoff artifact instead of rewriting the full chain history
- if the `requestId` changed accidentally, stop and regenerate the chain from the last trusted request identity
- if `routeReason` is too weak, rewrite it before any execution starts
- if the hop direction is wrong, discard the bad handoff and re-emit with the correct source/target roles

## 8. Outcome For `m6 / s2`

This step is complete when the chain has:

- a minimum field contract for both handoff hops
- a clear `routeReason` writing rule
- minimal JSON examples for both hops
- an acceptance checklist that can be used in review
- rollback guidance that keeps the chain retry-safe

This spec is intentionally minimal: it is enough to execute and audit the `orchestrator` -> `architect` -> `claude-code` path without introducing extra ceremony.
