# M6 Replay Package Note

Date: 2026-03-20
Milestone: `m6`
Target: `chain-001` replay package

## 1. Package Purpose

这个 replay 包的目标是让新操作者从 fresh state 直接复现 `chain-001`，并得到与现有 dry-run 工件一致的结果。

它只覆盖 replay 所需的最小信息，不引入新的链路设计，也不改写现有 handoff 规则。

## 2. Package Contents

- `Xuanzhi-Dev/generated/m6-dry-run/chain-001/replay-input.json`
  - 最小启动输入
  - 包含 replay 身份、链路身份、稳定 `requestId`、fresh state 标记和源工件引用
- `Xuanzhi-Dev/generated/m6-dry-run/chain-001/replay-checklist.md`
  - 按步骤复现说明
  - 每一步的期望输出
  - 每一步的失败回滚检查点
- 现有对照工件
  - `Xuanzhi-Dev/spec/plans/m6-chain-baseline-note.md`
  - `Xuanzhi-Dev/spec/plans/m6-handoff-artifacts-spec.md`
  - `Xuanzhi-Dev/spec/plans/m6-execution-proof.md`
  - `Xuanzhi-Dev/spec/plans/m6-verification-note.md`
  - `Xuanzhi-Dev/generated/m6-dry-run/chain-001/orchestrator-to-architect.json`
  - `Xuanzhi-Dev/generated/m6-dry-run/chain-001/architect-to-claude-code.json`

## 3. How To Use

1. 从 `replay-input.json` 读取 replay 身份和 chain 身份。
2. 先读 `m6-chain-baseline-note.md` 和 `m6-handoff-artifacts-spec.md`，再按 `replay-checklist.md` 逐步重建 chain-001。
3. 生成两份 handoff JSON 后，直接对照现有 `chain-001` 工件检查字段、角色方向、`requestId` 和 `routeReason`。
4. 只有在两份 JSON 都与现有工件一致时，才把 replay 视为完成。

## 4. Pass Standard

replay 包通过时，必须同时满足以下条件：

- 从 fresh state 启动，不依赖隐藏的中间结果
- `requestId` 在两段 handoff 中保持一致
- 两份 JSON 都包含 `m6-handoff-artifacts-spec.md` 定义的 minimum field set
- `routeReason` 明确说明停止点、下一 owner 选择和风险降低效果
- 复现结果与现有 `chain-001` 工件一致
- replay 过程没有额外文件写入，也没有越出 approved dry-run 范围

## 5. Notes

这个 replay 包解决的是“可复制即用”的复现入口问题，不替代 `m6` 的其它 review 结论。

如果后续要把 replay 包当成验收依据，仍需保留与现有 chain-001 工件的逐项比对结果。 
