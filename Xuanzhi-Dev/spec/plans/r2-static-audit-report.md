# R2 静态核验报告（2026-03-20）

## 覆盖范围
- 运行根目录下可见的 runtime 资产：`agents/`、`hooks/`、`skills/`、`workspace-*`、`openclaw.json`。
- 按照当前真实结构，贯穿 `Xuanzhi-Dev/spec/plans/` 中正在执行的 `stp-r2-static-audit-plus-r3-docker-bringup` 步骤所指的 component 核验点。

## 组件核验结果

### Agents
- `agents/<agentId>/agent` 与 `agents/<agentId>/sessions` 目录对每个系统 agent 均已创建（`orchestrator`、`critic`、`architect`、`ops`、`skills-smith`、`agent-smith`、`claude-code`），并由 `agents/README.md` 说明其定位与 runtime 结构。当前 agent 目录尚为占位 `.gitkeep`，说明真正的 state/audit 仍待填入，但路径、名称和文件夹结构已经与 `openclaw.json` 中的 agent registry 对齐。
- 证据路径：`D:\Xuanzhi\agents\README.md`、`D:\Xuanzhi\agents\<agentId>`（存在路径）。

### Hooks
- 仅有 `workspace-integrity` 与 `ops-action-guard` 两个 hook 实现，分别提供 workspace 完整性检查与 allowlist 校验，相关策略、handler、日志路径在 `hooks/*` 下可查证（`control-policy.json`、`allowlist.json`、`handler.ts`、`HOOK.md`）。
- `openclaw.json` 的 `command-logger` 与 `boot-md` 在本仓库没有自定义目录；Docker 动态验证显示它们作为 OpenClaw internal hooks 能正常注册。当前风险不在“无法运行”，而在“实现依赖上游内建，仓库内缺少版本锚点和行为约束工件”。
- 证据路径：`D:\Xuanzhi\hooks\workspace-integrity\control-policy.json`、`D:\Xuanzhi\hooks\ops-action-guard\allowlist.json`、`D:\Xuanzhi\openclaw.json`。

### Skills
- 当前运行环境只启用了一个 skill：`xuanzhi-control`，其 `control-model.json`、`memory-policy.json`、`routing-policy.json`、`tool-policy-matrix.json` 与 `workflow-placement.json` 共同描述了 skill onboarding、记忆策略、工作流入口和工具授权。`SKILL.md` 汇总职责与使用说明，符合 `openclaw.json` 中的 skill registry。
- 证据路径：`D:\Xuanzhi\skills\xuanzhi-control\control-model.json`、`D:\Xuanzhi\skills\xuanzhi-control\workflow-placement.json`。

### Workspaces
- 按照 `hooks/workspace-integrity/control-policy.json` 的要求，所有列出的 workspace（orchestrator、critic、architect、ops、skills-smith、agent-smith、claude-code）都具备 `AGENTS.md`、`BOOT.md`、`BOOTSTRAP.md`、`HEARTBEAT.md`、`IDENTITY.md`、`MEMORY.md`、`SOUL.md`、`TOOLS.md` 方位说明，以及 `memory/` 目录。`workspace-integrity` hook 可在启动时验证这些节点，提供了运行时完整性 guard。
- 证据路径：`D:\Xuanzhi\workspace-ops\AGENTS.md`、`D:\Xuanzhi\workspace-architect\BOOT.md`、`D:\Xuanzhi\workspace-critic\HEARTBEAT.md` 等。

### 配置
- `openclaw.json` 直接定义了当前被激活的 agent 列表、hook/skill entries、cron、sandbox 和权限策略，成为唯一的 runtime registry。没有其他 root-level `docs/policies/schemas/workflows/state/templates`，说明规范仍集中于此文件与各 workspace。
- 证据路径：`D:\Xuanzhi\openclaw.json`。

## 发现问题

### P1
1. `openclaw.json` 中声明的 `command-logger` 与 `boot-md` 依赖 OpenClaw internal hooks；本仓库未维护对应实现/版本锚点。动态验证虽可运行，但后续升级时存在行为漂移风险，且无法在仓库内做差异审查。证据路径：`D:\Xuanzhi\openclaw.json`、`D:\Xuanzhi\hooks/`、`Xuanzhi-Dev/spec/plans/r3-docker-e2e-report.md`。
2. `hooks/ops-action-guard/allowlist.json` 明确允许 `workspace-daily-*` 与 `agents/daily-*` 的 user-level 操作，但当前 runtime 根目录下唯一的 `workspace-*` 目录集是 `workspace-orchestrator`、`workspace-critic`、`workspace-architect`、`workspace-ops`、`workspace-skills-smith`、`workspace-agent-smith`、`workspace-claude-code`（参见 `REPO-MAP.md`），`workspace-daily-*` 与 `agents/daily-*` 目录都不存在，也未能为 allowlist 提供实际目标，致使每天创建用户的 allowlist 校验、状态写入与审计链无实际承载。证据路径：`D:\Xuanzhi\hooks\ops-action-guard\allowlist.json`、`D:\Xuanzhi\REPO-MAP.md`。

### P2
- 无。

## 治理一致性缺口
- `.codex/session-state.json` 仍把当前里程碑和短期计划定位在 `m7`/`stp-m7-governance-closure` 并标记为 active/in_progress，但 `Xuanzhi-Dev/spec/plans/master-plan.json` 显示 `m7` 已完成；同时 `Xuanzhi-Dev/spec/plans/release-readiness-master-plan.json` 只把 `r1` 标记为 active，却在 `Xuanzhi-Dev/spec/plans/active-short-term-plan.json` 里执行 `r2`（`stp-r2-static-audit-plus-r3-docker-bringup`）。多个计划系统的状态应同步，否则难以判断哪些 gap 已被闭环。证据路径：`D:\Xuanzhi\.codex\session-state.json`、`D:\Xuanzhi\Xuanzhi-Dev\spec\plans\master-plan.json`、`D:\Xuanzhi\Xuanzhi-Dev\spec\plans\release-readiness-master-plan.json`、`D:\Xuanzhi\Xuanzhi-Dev\spec\plans\active-short-term-plan.json`。
