# M1 Execution Details

## Milestone

- milestone: `m1`
- name: `运行语义收口`

## Goal

Turn the current runtime facts into stable execution input for the next milestones.

This milestone is not complete with document edits alone. It must also produce:

- a usable cleanup inventory
- a usable runtime semantics summary
- a verification note
- a stage review with rework decisions

## Inputs

- `README.md`
- `Xuanzhi-Dev/REPO-MAP.md`
- `Xuanzhi-Dev/spec/migration/PATH-MAP-final.md`
- `Xuanzhi-Dev/spec/bringup/BRING-UP-ORDER.md`
- `Xuanzhi-Dev/spec/bringup/BOOTSTRAP-CHECKLIST.md`
- `workspace-agent-smith/AGENTS.md`
- `workspace-ops/AGENTS.md`
- `Xuanzhi-Dev/spec/requirements/open_claw多agent系统v1需求规格.md`
- `Xuanzhi-Dev/legacy-root/`
- `Xuanzhi-Dev/generated/`

## Execution Steps

### Step A

Produce migration cleanup inventory.

Output:

- `Xuanzhi-Dev/spec/migration/MIGRATION-CLEANUP-INVENTORY.md`

Completion rule:

- must cover requirements, legacy-root, and generated
- must classify each issue as `migrate`, `archive`, or `ignore`

### Step B

Produce runtime semantics summary.

Output:

- `Xuanzhi-Dev/spec/migration/RUNTIME-SEMANTICS-SUMMARY.md`

Completion rule:

- must freeze current workspace convention
- must freeze current runtime truth boundary
- must state the current template direction

### Step C

Verify milestone outputs against repository facts.

Output:

- `Xuanzhi-Dev/spec/plans/m1-verification-note.md`

Verification checklist:

- cleanup inventory matches current repository layout
- runtime summary does not claim unpromoted directories are active runtime truth
- current role boundary for `agent-smith` and `ops` is reflected consistently
- no active document still claims `workspaces/workspace-*` is the current runtime convention

### Step D

Run stage review and generate rework list.

Output:

- `Xuanzhi-Dev/spec/plans/m1-review-and-rework.md`

Review checklist:

- what was actually executed
- what was verified
- what remains ambiguous
- what failed or is still weak
- what must be redone before `m2`

## Rework Rule

If verification or review finds weak output:

1. do not close `m1`
2. append the issue to the rework list
3. update active short-term plan state
4. re-run the affected step before moving to `m2`

## Done Condition

`m1` is only done when all four outputs exist and the review does not leave blocking rework items open.
