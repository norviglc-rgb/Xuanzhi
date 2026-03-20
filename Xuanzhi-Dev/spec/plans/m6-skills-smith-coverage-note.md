# M6 Skills-Smith Coverage Note

Date: 2026-03-20
Milestone: `m6`
Target: `chain-001`

## 1. 角色判定

- 结论：`skills-smith` **不参与**本次 m6 链路执行。
- 原因：本次链路只覆盖 `orchestrator -> architect -> claude-code` 的 handoff 与落盘证明，不包含 Skill 维护或 Skill 资产变更。

## 2. 证据

- 作用域只定义了两跳链路：
  - `D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m6-handoff-artifacts-spec.md`
  - 该规格明确列出 `orchestrator -> architect` 与 `architect -> claude-code`，未定义 `skills-smith` 作为链路节点。
- 当前链路产物仅有两份 JSON：
  - `D:\Xuanzhi\Xuanzhi-Dev\generated\m6-dry-run\chain-001\orchestrator-to-architect.json`
  - `D:\Xuanzhi\Xuanzhi-Dev\generated\m6-dry-run\chain-001\architect-to-claude-code.json`
- 现有验收记录已标记该缺口：
  - `D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m6-verification-note.md`
  - `D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m6-full-test-chain-report.md`
  - 两份记录均只验证链路 handoff / traceability，并明确写出 `skills-smith` 在当前 m6 证据集中未覆盖。
- 角色边界定义说明 `skills-smith` 负责 Skills 创建、维护与模板演化，不承担本次链路所需的执行 owner 职责：
  - `D:\Xuanzhi\Xuanzhi-Dev\spec\requirements\open_claw多agent系统v1需求规格.md`

## 3. 有界排除证明

- 排除条件：
  - 任务目标仅限 `chain-001` 的最小可执行 handoff 证明。
  - 输入/输出工件仅限 `m6-handoff-artifacts-spec.md` 规定的两份 handoff JSON。
  - 本次不涉及 Skills 目录、Skill 模板、Skill 文档或 Skill 版本演化。
- 为什么不影响链路正确性：
  - 链路正确性的验收点是 `requestId` 一致、最小字段集完整、路由理由可追踪、工件可解析。
  - 这些检查全部由两跳 handoff 工件闭环完成，不依赖 `skills-smith` 的执行结果。
- 如何验证“不参与”成立：
  - `generated/m6-dry-run/chain-001/` 下仅存在两份 handoff JSON。
  - `m6-verification-note.md` 可复核两份 JSON 已通过解析与字段校验。
  - 若后续出现任何 Skill 资产变更、Skill 模板改写或 Skill 文档重构，则本排除失效，必须补回 `skills-smith` 参与证据。

## 4. 风险控制

- 风险 1：把 Skill 维护误当成链路必经步骤。
  - 控制：严格限制在两跳 handoff 作用域内，不扩展到 Skill 资产层。
- 风险 2：未来 m6 需求升级后，边界被静默扩大。
  - 控制：一旦目标改为 Skill 维护、模板演化或技能治理，立即重新评估并补 `skills-smith` 执行证据。

## 5. 验收结论

- 结论：`pass`
- 理由：已给出 `skills-smith` 的有界排除证明，且现有 m6 链路验证不需要它参与即可成立。
- 后续动作：
  - 保持当前 m6 证据集不变。
  - 若新增 Skill 相关变更，再单独补 `skills-smith` 执行工件与复核记录。
