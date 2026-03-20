# Execution Harness

## Purpose

This document defines the default closed-loop workflow for long-running Xuanzhi work.

It is the operational harness used by the main agent.

## Default Mode

- main agent owns milestone planning
- main agent owns the only active short-term plan
- main agent owns implementation design
- main agent splits short-term work into bounded tasks
- main agent creates subagents based on task complexity
- subagents execute the bounded short-term tasks
- main agent reviews, integrates, verifies, and decides rework
- after milestone review passes, main agent commits the milestone outputs to Git
- after the commit, main agent reports milestone completion to the user

## Loop

1. confirm the active milestone
2. confirm there is only one active short-term plan
3. write or update implementation details
4. design the implementation path for the current milestone
5. split concrete execution tasks
6. create 1 to 2 subagents by default
7. choose lower-cost subagent models first, only increasing capability when needed
8. assign execution tasks to subagents
9. do main-thread work that should not be delegated
10. review and integrate subagent output
11. verify outputs against repository facts
12. run stage review and produce rework list
13. if blocked or failed, keep the plan active and rework
14. if the milestone passes review, update plan state and commit to Git
15. report milestone completion to the user
16. only then create the next short-term plan
17. run the phase transition checklist before continuing

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
- keep `.codex/` local and out of Git unless strategy changes explicitly

## Failure Rule

If any stage produces weak or incomplete output:

- do not close the short-term plan
- add the issue to the rework list
- continue the loop from the affected step

## Phase Transition Rule

Before moving to the next milestone or next short-term plan:

- run `PHASE-TRANSITION-CHECKLIST.md`
- sync formal plan state and `.codex` state
- confirm subagent lifecycle is clean
- confirm the next execution step is unambiguous
