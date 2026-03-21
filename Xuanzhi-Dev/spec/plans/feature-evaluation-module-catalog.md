# Feature Evaluation Module Catalog

Date: 2026-03-21
Status: active design baseline

## 1. Scope

This catalog defines the concrete function modules that must be evaluated before release-quality judgment can be considered complete.

## 2. Prebuilt Agent Modules

### FSM-AGENT-SMITH

- module: `agent-smith specialist creation and runtime landing`
- expected:
  - create usable agents
  - create matching workspace/runtime surfaces
  - land them into real runtime registration
  - produce specialists with credible domain output

test families:

- `fsm-as-01` creation fidelity
- `fsm-as-02` runtime registration fidelity
- `fsm-as-03` orchestrator discoverability
- `fsm-as-04` specialist quality
- `fsm-as-05` completion-claim honesty

### FSM-ORCH

- module: `orchestrator routing and convergence`

test families:

- `fsm-orch-01` intake and complexity judgment
- `fsm-orch-02` routing correctness
- `fsm-orch-03` multi-turn continuity
- `fsm-orch-04` cross-agent handoff planning
- `fsm-orch-05` discovery of newly registered specialists

### FSM-ARCH

- module: `architect simple-development and architecture handoff`

test families:

- `fsm-arch-01` direct handling of simple design/dev requests
- `fsm-arch-02` architecture tradeoff quality
- `fsm-arch-03` claude-code handoff quality

### FSM-CLAUDE-CODE

- module: `claude-code complex development execution domain`

test families:

- `fsm-cc-01` handoff acceptance fidelity
- `fsm-cc-02` multi-module execution realism
- `fsm-cc-03` structured outcome quality

### FSM-SKILLS-SMITH

- module: `skills-smith maintenance and governance`

test families:

- `fsm-ss-01` skill generation quality
- `fsm-ss-02` skill comparison and tradeoff reasoning
- `fsm-ss-03` compliance and consistency checking

### FSM-OPS

- module: `ops lifecycle, deployment, and rollback discipline`

test families:

- `fsm-ops-01` read-only health assessment
- `fsm-ops-02` actionable repair plan quality
- `fsm-ops-03` rollback-aware execution planning
- `fsm-ops-04` daily-user lifecycle execution

### FSM-CRITIC

- module: `critic review gate and blocker expression`

test families:

- `fsm-critic-01` evidence sufficiency detection
- `fsm-critic-02` decisive gate output
- `fsm-critic-03` blocker wording quality

### FSM-DAILY

- module: `daily-user bootstrap, personalization, and isolation`

test families:

- `fsm-daily-01` runtime availability
- `fsm-daily-02` bootstrap behavior
- `fsm-daily-03` daily-assistant usefulness
- `fsm-daily-04` isolation and non-cross-scope behavior

## 3. Cross-Agent Modules

### FSM-ROUTING

- module: `runtime registration and discoverability`

test families:

- `fsm-route-01` config registration
- `fsm-route-02` invocation success
- `fsm-route-03` orchestrator recognition of new roles

### FSM-HANDOFF

- module: `multi-agent handoff closure`

test families:

- `fsm-handoff-01` orchestrator -> architect
- `fsm-handoff-02` architect -> claude-code
- `fsm-handoff-03` skills-smith -> ops -> critic

### FSM-AUDIT

- module: `audit/review/state consistency`

test families:

- `fsm-audit-01` audit event completeness
- `fsm-audit-02` review-gate traceability
- `fsm-audit-03` state/config alignment

## 4. Specialist-Agent Modules

The first specialist batch to evaluate:

- `docs-expert`
- `higress-expert`
- `fastgpt-expert`
- `n8n-expert`
- `workflow-expert`

Each specialist must be judged with:

- `domain-artifact sufficiency`
- `role-text quality`
- `callability`
- `answer quality`
- `discoverability by orchestrator`

## 5. External Blocker Mapping

Use these blocker classes in reports:

- `missing-domain-artifacts`
- `missing-runtime-registration`
- `missing-discovery-path`
- `provider-or-environment-limitation`
- `evidence-insufficient`
- `scope-not-materialized`

## 6. Output Rule

Every future report must reference one or more module IDs from this catalog.
