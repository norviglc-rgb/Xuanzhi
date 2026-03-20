# M7 Review Gate Proof

Date: 2026-03-20
Milestone: `m7`
Step: `s2`

## 结论

当前仓库里已经补齐 review gate 的角色定义、检查清单、权限边界，以及标准化决策工件和回流链路样例，因此 review gate 已满足可执行、可留痕、可回流的最小通过条件，结论更新为通过。

### 通过项

1. `critic` 角色被明确标成 `review_gate`，且拥有独立 workspace。
2. `workspace-critic/docs/review-checklist.md` 已经把 review gate 的检查项拆成通用、用户实例、开发 review、memory review 四类。
3. `openclaw.json` 里 `critic` 仅有只读会话能力，没有写入、执行或补丁权限，符合“先审后动”的门禁边界。
4. `workspace-critic/docs/review-decision-template.json` 给出了标准化 review gate 决策工件模板，字段覆盖 `scope`、`decision`、`reason`、`reviewer`、`timestamp`、`reworkItems`、`nextAction`。
5. `Xuanzhi-Dev/generated/m7-review-gate-sample.json` 给出了可审计的 sample 决策实例，且使用 `rework` + `nextAction` 明确展示回流路径。

### 回流链路证据

1. 决策工件模板固定了 review 输出格式，避免 `pass / fail / rework` 结论只停留在口头或临时记录。
2. sample 决策把 `decision: rework`、`reworkItems` 和 `nextAction` 连成闭环，能从结果直接追到回流动作。
3. proof 页面本身继续引用该 sample，形成“证明页 -> 决策工件 -> 回流动作”的可重建链路。

## 检查项

| 检查项 | 证据路径 | 结论 | 说明 |
|---|---|---|---|
| critic 具备 review gate 角色 | `D:\Xuanzhi\workspace-critic\IDENTITY.md` | 通过 | 文件明确写了 `agentId: critic`、`workspaceId: workspace-critic`、`role: review_gate`。 |
| critic 的运行原则是审查而非执行 | `D:\Xuanzhi\workspace-critic\TOOLS.md`，`D:\Xuanzhi\workspace-critic\HEARTBEAT.md` | 通过 | 明确限制 `No exec`、`No deploy`、`No direct edits`，并要求输出问题、建议动作与是否触发 review。 |
| review checklist 已存在且可读 | `D:\Xuanzhi\workspace-critic\docs\review-checklist.md` | 通过 | 清单包含 general、user instance creation、development review、memory review。 |
| gate 的权限边界在注册表中收口 | `D:\Xuanzhi\openclaw.json` | 通过 | `critic` 仅允许 `read` 和 session 读取，拒绝 `exec`、`write`、`edit`、`apply_patch`。 |
| gate 有明确 pass / fail / rework 输出链 | `D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m7-governance-baseline-note.md`，`D:\Xuanzhi\workspace-critic\docs\review-decision-template.json`，`D:\Xuanzhi\Xuanzhi-Dev\generated\m7-review-gate-sample.json` | 通过 | 计划层要求已经落到模板和样例工件上，且样例包含可审计的决策字段。 |
| gate 能阻断未审输入 | `D:\Xuanzhi\workspace-critic\docs\review-checklist.md`，`D:\Xuanzhi\openclaw.json` | 通过 | 检查项与只读权限边界共同构成先审后动的阻断面。 |
| gate 与 review 结论可追溯绑定 | `D:\Xuanzhi\workspace-critic\docs\review-decision-template.json`，`D:\Xuanzhi\Xuanzhi-Dev\generated\m7-review-gate-sample.json`，`D:\Xuanzhi\Xuanzhi-Dev\spec\plans\m7-review-gate-proof.md` | 通过 | 模板、样例和 proof 互相指向，能够重建 decision -> reworkItems -> nextAction 的链路。 |

## 风险与建议

- 风险：如果后续新增字段而不同步模板，决策工件的可比性会下降。
- 风险：如果 sample 不再引用 proof，回流链路会退化成孤立样例。
- 建议：继续沿用 `review-decision-template.json` 作为 gate 的唯一结构来源，避免不同 milestone 各写一套格式。
- 建议：把 `rework` 和 `pass` 两类样例都保留在生成目录，方便后续做门禁一致性核验。
