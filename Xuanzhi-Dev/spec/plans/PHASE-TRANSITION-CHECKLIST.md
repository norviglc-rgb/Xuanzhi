# Phase Transition Checklist

## Purpose

This checklist reduces drift when moving from one milestone or short-term plan state to the next.

Use it:

- when a short-term plan is completed
- when a milestone is completed
- before opening the next short-term plan

## Transition Checks

### 1. Plan State

- confirm the current short-term plan status is correct
- confirm milestone status is correct
- if the short-term plan is complete, archive it or clear the active slot
- confirm the next expected milestone is correct

### 2. Artifacts

- confirm required outputs for the completed stage exist
- confirm verification and review artifacts exist if the stage requires them
- confirm artifact names match what the plan says

### 3. `.codex` Sync

- update `.codex/session-state.json`
- update `.codex/handoff.md`
- update `.codex/worklog.md`
- confirm `.codex` reflects the same phase boundary as formal plan files

### 4. Subagent Lifecycle

- confirm reusable subagents are intentionally kept
- close one-off subagents whose outputs are already integrated
- confirm no stale subagent is being mentally treated as still active

### 5. Git Boundary

- if a milestone passed review, commit reviewed outputs
- if a milestone did not pass review, do not treat it as ready for milestone commit
- if commit is intentionally deferred, record explicit defer reason and owner
- record milestone commit hash in stage artifacts
- keep `.codex/` out of Git unless strategy explicitly changes

### 6. User Reporting

- if the milestone is complete and committed, report the milestone result to the user
- if the milestone is not complete, provide only progress updates

### 7. Next-Step Safety

- if no short-term plan is active, do not continue execution until the next active short-term plan is created
- confirm the next short-term plan is the only active one
- confirm the next plan starts from the latest verified outputs, not stale drafts
- confirm full-chain validation scope is defined (including previously completed key agent tracks)
- confirm product-quality checks are defined (not only structural checks)

## Exit Condition

The phase transition is complete only when:

- formal plans are synced
- `.codex` is synced
- subagent lifecycle is clean
- Git/reporting state matches milestone state
- the next execution step is unambiguous
