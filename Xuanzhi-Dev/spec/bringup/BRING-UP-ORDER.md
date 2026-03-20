# BRING-UP-ORDER

## 1. Goal

Bring Xuanzhi to a minimum runnable state based on the repository as it exists today, without inventing extra structure first.

## 2. Order

### Step 1: Stabilize runtime semantics

Before any provisioning work:

- confirm active workspace paths are `workspace-<agentId>`
- confirm what is runtime truth and what is still only in `Xuanzhi-Dev/legacy-root/`
- confirm seed examples are not treated as live state

### Step 2: Make `agent-smith` ready

Prioritize `agent-smith` first.

`agent-smith` must define:

- what files a new agent needs
- how agent creation should be described
- what schemas and workflows back agent creation
- how to avoid special-case template sprawl

The design target is generic agent creation, not a separate `core-agent` template family.

### Step 3: Make `ops` ready

Prioritize `ops` second.

`ops` must be able to:

- execute agent creation workflows
- execute daily-user creation workflows
- update runtime state and audit trails
- keep lifecycle actions separate from template ownership

### Step 4: Normalize existing system agents

The repository already contains dedicated workspaces for:

- orchestrator
- critic
- architect
- ops
- skills-smith
- agent-smith
- claude-code

At this stage, verify and normalize them instead of introducing another materialization layer unless it is truly needed.

### Step 5: Create the first daily test user

Use one test user such as:

- `daily-test-user`

Success means:

- isolated workspace exists
- required root files exist
- profile exists
- state and audit are updated
- critic can review the result

### Step 6: Validate complex routing

Use a clearly complex development task and verify:

- orchestrator routes correctly
- architect prepares handoff artifacts
- claude-code is selected for implementation runtime

### Step 7: Verify review and allowlist behavior

Check that:

- critic review can actually happen
- ops only executes allowed actions
- audit remains traceable

### Step 8: Enable heartbeat last

Heartbeat should stay off until the previous steps are stable.

## 3. Red Lines

- Do not treat legacy docs as active runtime truth without promotion
- Do not create extra template families before agent creation is clear
- Do not let `ops` absorb template ownership
- Do not let `agent-smith` absorb runtime lifecycle execution
- Do not enable heartbeat before provisioning, review, and routing are stable
