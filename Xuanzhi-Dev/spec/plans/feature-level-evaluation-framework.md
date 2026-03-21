# Feature-Level Evaluation Framework

Date: 2026-03-21
Status: active design baseline
Owner: main agent

## 1. Purpose

This framework changes testing from:

- generic smoke tests
- isolated prompt-response checks
- broad module coverage without product verdict depth

to:

- feature-level product evaluation
- role-by-role expectation validation
- scenario-driven verdicts with external-blocker classification
- reportable conclusions that can support a release decision

## 2. Core Method

Every evaluation must be abstracted using the same five-layer model:

1. Capability Domain
   - example: `agent creation`, `routing`, `review gate`, `daily-user lifecycle`
2. Function Module
   - example: `agent-smith specialist creation fidelity`
3. Scenario Family
   - example: `specialist creation`, `specialist discoverability`, `expert response quality`
4. Concrete Test Case
   - exact prompt, environment, expected behavior, failure rule
5. Evidence Bundle
   - raw output
   - runtime path
   - file mutation proof
   - config/state delta
   - verdict

This means no future test should begin from a one-off prompt idea. It must first be mapped into this structure.

## 3. Verdict Model

Every function module must end in one of four verdicts:

- `meets_expectation`
- `partially_meets_expectation`
- `does_not_meet_expectation`
- `externally_blocked`

`externally_blocked` is only allowed when:

- the blocker is outside OpenClaw design ownership
- the function logic is otherwise shown to be sound
- the missing prerequisite is explicitly identified

## 4. Evidence Rules

A module-level verdict is valid only if it includes:

- expectation statement
- test scope
- exact test cases executed
- actual observations
- deviation analysis
- root-cause classification:
  - design gap
  - implementation gap
  - registration/config gap
  - environment gap
  - external dependency gap
- final conclusion

## 5. Module Taxonomy

### 5.1 System-Level Modules

- `routing-and-delegation`
- `registration-and-discoverability`
- `cross-agent-handoff`
- `audit-and-review-closure`
- `state-and-runtime-consistency`
- `model-and-provider-governance`

### 5.2 Prebuilt Agent Modules

- `agent-smith`
- `orchestrator`
- `architect`
- `claude-code`
- `skills-smith`
- `ops`
- `critic`
- `daily-user`

### 5.3 Specialist-Agent Modules

Specialist agents created by `agent-smith` must be tested as a separate layer:

- creation quality
- runtime registration quality
- orchestrator discoverability
- specialist response quality
- domain evidence sufficiency

This prevents a false pass where an agent is "generated" but not actually runnable or discoverable.

## 6. Required Evaluation Pattern Per Agent

Each prebuilt agent must be evaluated using these six standard dimensions:

1. Role fidelity
   - does it act within its defined boundary?
2. Core output quality
   - does it produce the kind of work the role is supposed to own?
3. Runtime operability
   - can it be invoked successfully in the real runtime path?
4. Discoverability / routability
   - can the rest of the system find and use it correctly?
5. Evidence discipline
   - does it leave or reference the right artifacts?
6. Failure behavior
   - does it refuse, escalate, or degrade correctly when blocked?

## 7. Agent-Specific Core Expectations

### 7.1 `agent-smith`

Expected:

- create structurally valid agents
- create matching workspace/runtime surfaces
- register agents into actual runtime config, not only local scratch paths
- produce specialists that can answer at least one credible domain test

### 7.2 `orchestrator`

Expected:

- classify requests correctly
- route to the proper role
- preserve context through multi-turn planning
- converge results without inventing unavailable roles

### 7.3 `architect`

Expected:

- handle simple development directly
- produce architecture decisions for ambiguous or multi-module work
- emit structured handoff to coding domain when complexity crosses threshold

### 7.4 `claude-code`

Expected:

- accept structured development handoff
- produce concrete implementation-style outcomes
- preserve scope and constraints from upstream handoff

### 7.5 `skills-smith`

Expected:

- maintain and evaluate shared skills
- compare strategies with meaningful governance tradeoffs
- detect shallow or non-compliant skill structures

### 7.6 `ops`

Expected:

- execute lifecycle and deployment tasks
- provide rollback-aware action plans
- preserve runtime safety and audit chain

### 7.7 `critic`

Expected:

- issue explicit pass/fail/rework or go/no-go outcomes
- reject insufficient evidence
- explain blockers in decision-ready language

### 7.8 `daily-user`

Expected:

- boot with personalized daily-user behavior
- maintain scope isolation
- provide useful assistant behavior instead of generic system-agent output

## 8. Specialist-Agent Evaluation Pattern

When `agent-smith` creates domain experts, evaluate them in this order:

1. Creation proof
   - files exist
   - role text exists
   - config fragment exists
2. Registration proof
   - agent is present in runtime `openclaw.json`
3. Invocation proof
   - `openclaw agent --local --agent <id>` works
4. Quality proof
   - agent gives strong answers on at least one domain-realistic prompt
5. System integration proof
   - orchestrator can discover, mention, or route to the agent when appropriate

If step 1 passes but step 2 fails, the verdict is not "creation success". It is:

- `creation_success_registration_failure`

This rule is important and must be enforced in later reports.

## 9. External Blocker Policy

A function may still be judged as meeting expectation despite one blocked sub-area only if:

- the blocked sub-area is not caused by OpenClaw design
- the rest of the function is deeply validated
- the report explicitly isolates the blocked dimension

Example:

- Higress expert cannot be judged on real Higress competence when the repository contains no Higress artifacts.
- In that case the verdict is not "agent failed".
- It is "domain validation externally blocked by missing domain artifacts".

## 10. Report Structure

Every independent report under `Xuanzhi-Dev/Report/` must use:

1. Function
2. Expected outcome
3. Test modules
4. Test cases executed
5. Observed results
6. Gaps and blocker classification
7. Final verdict

Recommended file naming:

- `01-agent-smith-evaluation.md`
- `02-orchestrator-evaluation.md`
- `03-architect-evaluation.md`
- `04-claude-code-evaluation.md`
- `05-skills-smith-evaluation.md`
- `06-ops-evaluation.md`
- `07-critic-evaluation.md`
- `08-daily-user-evaluation.md`
- `09-routing-and-discoverability-evaluation.md`
- `10-specialist-agents-evaluation.md`
- `00-index.md`

## 11. Execution Phases

### Phase A: Design Freeze

- freeze expectation model
- freeze report template
- freeze function-module catalog

### Phase B: Artifact Preparation

- ensure runtime config is the exact version under test
- ensure required domain fixtures exist
- classify missing fixtures as test blockers before execution

### Phase C: Feature-Level Evaluation

- run per-agent deep tests
- run specialist-agent deep tests
- run cross-agent integration tests

### Phase D: Consolidated Verdict

- aggregate module verdicts
- classify blockers as internal vs external
- form release-facing recommendation

## 12. Non-Negotiable Rule

From this point onward, no major functional claim may be written as:

- "works"
- "passes smoke test"
- "looks fine"

without being tied back to:

- a function module
- an expected outcome
- a verdict class
- an evidence bundle
