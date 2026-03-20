# Execution Harness

## Purpose

This document defines the default closed-loop workflow for long-running Xuanzhi work.

It is the operational harness used by the main agent.

## Default Mode

- main agent owns milestone planning
- main agent owns the only active short-term plan
- main agent splits short-term work into bounded tasks
- subagents execute the bounded short-term tasks
- main agent reviews, integrates, verifies, and decides rework
- after milestone review passes, main agent commits the milestone outputs to Git

## Loop

1. confirm the active milestone
2. confirm there is only one active short-term plan
3. write or update implementation details
4. split concrete execution tasks
5. assign bounded tasks to low-cost subagents by default
6. do main-thread work that should not be delegated
7. review and integrate subagent output
8. verify outputs against repository facts
9. run stage review and produce rework list
10. if blocked or failed, keep the plan active and rework
11. if the milestone passes review, update plan state and commit to Git
12. only then create the next short-term plan

## Model Use Rule

- use lower-cost models for subagents by default
- raise subagent capability only when task complexity requires it
- keep the main agent on the highest-quality reasoning path for planning and review

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
