# M6 Chain-001 Replay Checklist

## 1. Replay Goal

从 fresh state 复现 `chain-001`，生成与现有工件一致的两段 handoff JSON，并确保新操作者无需补读隐藏上下文即可完成校验。

## 2. Preconditions

- 已读取 `Xuanzhi-Dev/generated/m6-dry-run/chain-001/replay-input.json`
- 已读取 `Xuanzhi-Dev/spec/plans/m6-chain-baseline-note.md`
- 已读取 `Xuanzhi-Dev/spec/plans/m6-handoff-artifacts-spec.md`
- 当前为 fresh state，未依赖未记录的中间产物

## 3. Replay Steps

1. 以 `replay-input.json` 为唯一启动输入，确认 `replayId`、`chainId`、`requestId` 和 `freshState` 的值。
   - Expected output: 启动参数稳定，且 `requestId` 直接指向 `m6-20260320-chain-001`。
   - Rollback checkpoint: 如果 `requestId` 与现有 chain-001 不一致，停止 replay，不继续生成任何输出。
2. 根据 `m6-chain-baseline-note.md` 和 `m6-handoff-artifacts-spec.md` 重建 `orchestrator -> architect` 手工件。
   - Expected output: `Xuanzhi-Dev/generated/m6-dry-run/chain-001/orchestrator-to-architect.json` 可解析，且包含 minimum field set。
   - Rollback checkpoint: 如果该 JSON 缺失字段、角色方向错误或 `routeReason` 过于笼统，只修正这一份文件后再继续。
3. 以同一 `requestId`、同一字段合同和同一 chain 范围生成 `architect -> claude-code` 手工件。
   - Expected output: `Xuanzhi-Dev/generated/m6-dry-run/chain-001/architect-to-claude-code.json` 可解析，且与 hop-1 保持同一请求身份。
   - Rollback checkpoint: 如果 hop-2 出现新 `requestId`、越界文件引用或不符合实现边界的表述，回退到 hop-1 已确认状态，仅重写 hop-2。
4. 逐项比对两份 JSON 与 `m6-handoff-artifacts-spec.md` 的 minimum fields、`routeReason` 写法和 `artifactsIn` / `artifactsOut` 语义。
   - Expected output: 两份 JSON 的字段集合一致，且与 spec 的最小字段定义一致。
   - Rollback checkpoint: 如果字段集合不一致，优先补齐缺失字段，不要改写 chain 方向或 requestId。
5. 对照 `m6-execution-proof.md` 与 `m6-verification-note.md` 的链路结论，确认 replay 结果与现有 chain-001 工件一致。
   - Expected output: replay 结果可被现有验证口径接受，且不需要重建隐藏上下文。
   - Rollback checkpoint: 如果验证结论无法对齐，停止标记 replay complete，先修正不一致的单个工件。

## 4. Failure Rollback Rules

- 只要出现 `requestId` 漂移，整条 replay 视为失效，必须回到 fresh state 重新开始。
- 只要出现 hop 方向错误，保留正确的一侧，重写错误的一侧，不要重建整个链。
- 只要出现额外文件写入，删除新增文件并恢复到最近一次已确认的 JSON 状态。
- 只要 `routeReason` 不满足可审计要求，先修正文案，再继续后续步骤。

## 5. Replay Success Output

- 两份 JSON 都可解析
- 两份 JSON 使用同一个 `requestId`
- 两份 JSON 都覆盖 `m6-handoff-artifacts-spec.md` 的 minimum field set
- replay 过程不依赖未记录的隐藏上下文
- replay 结果与现有 chain-001 工件一致
