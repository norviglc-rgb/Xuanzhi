# Execution Harness

## Purpose

This document defines the default closed-loop workflow for long-running Xuanzhi work.

It is the operational harness used by the main agent.

It must preserve output quality even when the active model is lower-capability.

## Default Mode

- main agent owns milestone planning
- main agent owns the only active short-term plan
- main agent owns implementation design
- main agent splits short-term work into bounded tasks
- main agent creates subagents based on task complexity
- subagents execute the bounded short-term tasks by default
- main agent reviews, integrates, verifies, and decides rework
- after milestone review passes, main agent commits the milestone outputs to Git
- after the commit, main agent reports milestone completion to the user

## Harness Principles (2026 Agent-Harness Style)

- harness is the reliability layer, model is replaceable compute
- keep control flow minimal; prefer robust atomic tools + explicit verification
- build to delete: avoid hard-coding brittle logic that blocks future model upgrades
- treat trajectories as dataset: capture structured execution events for replay and grading
- optimize for durability under long tasks, not only short benchmark-like success

## Loop

1. confirm the active milestone
2. confirm there is only one active short-term plan
3. write or update implementation details
4. design the implementation path for the current milestone
5. split concrete execution tasks
6. create 1 to 2 subagents by default
7. choose lower-cost subagent models first, only increasing capability when needed
8. assign execution tasks to subagents
9. keep main-thread work on planning, integration, and validation; delegate concrete execution unless blocked
10. review and integrate subagent output
11. verify outputs against repository facts
12. run full-chain validation (including previously completed key agent tracks where applicable)
13. run product-quality review (复制即用、可恢复、真实环境可用性)
14. produce rework list for any gap
15. if blocked or failed, keep the plan active and rework
16. if the milestone passes review, update plan state and commit to Git
17. confirm commit hash is recorded in stage artifacts
18. close one-off subagents that are no longer needed
19. report milestone completion to the user
20. only then create the next short-term plan
21. run the phase transition checklist before continuing
22. log model-routing and critical execution outcomes to unified audit streams

## Model Use Rule

- use lower-cost models for subagents by default
- raise subagent capability only when task complexity requires it
- keep the main agent on the highest-quality reasoning path for planning and review

## Parallelism Rule

- default to 1 or 2 subagents
- avoid broad parallel fan-out
- only exceed 2 subagents when there is a strong reason and low deadlock risk
- prefer fewer long-lived useful workers over many short-lived query-only workers

## Subagent Lifecycle Rule

- make subagents reusable when the same short-term plan will continue using them
- if a subagent is one-off and no longer needed, close it promptly after integration
- do not keep completed one-off subagents open without a reason

## Git Rule

- do not wait until the whole project ends
- commit after milestone review passes
- commit only reviewed and integrated outputs
- do not move to the next milestone with an uncommitted passed milestone unless an explicit defer reason is recorded
- keep `.codex/` local and out of Git unless strategy changes explicitly

## Failure Rule

If any stage produces weak or incomplete output:

- do not close the short-term plan
- add the issue to the rework list
- continue the loop from the affected step

## Low-Capability Model Resilience Mode

Trigger this mode when quota pressure forces a downgrade to weaker models.

- split tasks into smaller bounded units with strict acceptance criteria
- enforce two-pass verification:
  - pass 1: deterministic checks (schema/path/state/tool constraints)
  - pass 2: critic quality gate against requirements and risks
- require replayable artifacts before marking any step as complete
- reduce autonomy radius:
  - fewer parallel tasks
  - stronger allowlist constraints
  - mandatory rollback checkpoint per risky step
- escalate to human confirmation for ambiguous/noisy outcomes instead of guessing

Exit criteria:

- product tests pass
- critical audit streams are complete
- no open P0 blockers in release fix checklist

## Phase Transition Rule

Before moving to the next milestone or next short-term plan:

- run `PHASE-TRANSITION-CHECKLIST.md`
- sync formal plan state and `.codex` state
- confirm subagent lifecycle is clean
- confirm the next execution step is unambiguous
