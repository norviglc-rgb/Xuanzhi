# M1 Review And Rework

## Stage

- milestone: `m1`
- short-term plan: `stp-m1-runtime-semantics-closure`

## What Was Actually Executed

1. Rewrote active high-level docs to match current repository facts.
2. Corrected `agent-smith` and `ops` role framing in active workspace docs.
3. Scanned requirements, legacy-root, and generated materials for old paths and old terms.
4. Integrated subagent inventory results into a single cleanup inventory.
5. Produced a frozen runtime semantics summary.
6. Produced implementation details for milestone execution.
7. Verified outputs against current repository structure.

## What Was Verified

- required milestone outputs exist
- active docs no longer present old paths as current runtime truth
- runtime summary matches actual repository layout
- current role boundary for `agent-smith` and `ops` is aligned

## Strengths

- the repository now has a stable written baseline for current runtime semantics
- old-path cleanup work is now explicit instead of implicit
- future work can start from current facts rather than target-state assumptions
- continuity state in `.codex/` is aligned with formal plan state

## Weaknesses

1. `spec/requirements/open_claw多agent系统v1需求规格.md` still contains a large amount of target-state and legacy wording.
2. `Xuanzhi-Dev/legacy-root/` still carries old workflow and template assumptions that could be reused incorrectly.
3. `Xuanzhi-Dev/generated/` still contains generated samples that look authoritative if read out of context.

## Rework List

### Non-blocking rework

1. Add clearer labeling to `legacy-root/` and `generated/` if confusion continues.
2. Rewrite or supersede the old requirements draft when the implementation milestones are further along.
3. Replace old sample workflow references when `agent-smith` and `ops` contracts are finalized.

### Blocking rework

- none for closing `m1`

## Review Decision

- result: pass
- blocking_status: clear

## Closeout Conclusion

`m1` can be closed.

Reason:

- the milestone goal was to close runtime semantics, not to finish full implementation
- the outputs now provide enough factual baseline to begin `m2`
- remaining issues are real, but they belong to later implementation and cleanup milestones rather than blocking `m1`
