# FILE_ACTION_PLAN_P0.md

## 1. 目的
本文件用于把 P0 执行清单转化为**实际文件层面的创建 / 修改 / 降级 / 延后动作**。

它回答的是：
- 具体改哪些文件
- 新建哪些文件
- 哪些只做标记不重写
- 哪些先不碰
- 执行顺序是什么

---

## 2. 动作类型说明

- **CREATE**：新建文件
- **REWRITE**：整体重写
- **UPDATE**：局部更新
- **MERGE**：内容归并后删除或降级原文件
- **DOWNGRADE**：降级为交接材料 / 历史档案 / 非主事实源
- **DEFER**：暂缓处理
- **DELETE**：删除空壳或无价值占位（仅在确认后执行）

---

## 3. P0 文件动作总表

| 路径 | 动作 | 优先级 | 目的 | 备注 |
|---|---|---:|---|---|
| `PROJECT_CHARTER.md` | CREATE | P0 | 建立目标基线 | 若已有旧版，可改为 REWRITE |
| `BOUNDARY_AND_SCOPE.md` | CREATE | P0 | 建立边界基线 | 当前仓库缺口明显 |
| `ARCHITECTURE_BASELINE.md` | REWRITE / UPDATE | P0 | 同步真实技术栈与系统角色图 | 需替换 LiteLLM -> Higress |
| `DELIVERY_STAGES.md` | CREATE | P0 | 建立阶段推进基线 | 收编 `.claude/` 中相关内容 |
| `CHANGE_CONTROL.md` | CREATE | P0 | 建立变更控制基线 | 吸收治理与会话材料中的变更逻辑 |
| `QUALITY_GATES.md` | CREATE | P0 | 建立质量门禁基线 | 把 red lines / risk / consistency 抽出来 |
| `README.md` | REWRITE | P0 | 成为统一入口 | 必须反映当前真实组件图 |
| `TOOLS.md` | UPDATE | P0 | 同步工具 / 平台现实 | 纳入 Higress、Coze Studio、n8n、NocoBase |
| `IDENTITY.md` | UPDATE | P0 | 对齐项目身份 | 防止和宪章冲突 |
| `USER.md` | UPDATE | P1 | 校正用户关系与边界 | 不应承载架构主叙事 |
| `BOOTSTRAP.md` | REWRITE | P0 | 消除关键空壳 | 最少补成最小有效文档 |
| `governance/RULE_HARDENING_POLICY.md` | REWRITE | P0 | 消除关键空壳 | 定义规则硬化原则 |
| `governance/GOVERNANCE_GLOSSARY.md` | UPDATE | P0 | 统一术语 | 加入 Higress / Coze Studio / n8n / NocoBase |
| `governance/RISK_MODEL.md` | UPDATE | P0 | 对齐新审批与人工审核平面 | 与 NocoBase 关联 |
| `governance/APPROVAL_POLICY.md` | UPDATE | P0 | 映射人工审核路径 | 明确 NocoBase 角色 |
| `governance/ROOT_FILE_POLICY.md` | UPDATE | P0 | 收紧根层边界 | 配合六类基线 |
| `governance/FIELD_CANON.md` | UPDATE | P1 | 清理字段与命名漂移 | 防止 schema/policy 失配 |
| `policies/approval_rules.yaml` | UPDATE | P0 | 与审批模型对齐 | 映射人工审核节点 |
| `policies/risk_policy.yaml` | UPDATE | P0 | 与风险模型对齐 | 同步新组件职责 |
| `policies/memory_write_rules.yaml` | UPDATE | P1 | 与记忆原则对齐 | 与 MEMORY / governance 对齐 |
| `policies/state_transitions.yaml` | UPDATE | P1 | 与状态机一致 | 与 `STATE_MACHINE.md` 对齐 |
| `integrations/HIGRESS_INTEGRATION.md` | CREATE | P0 | 建立新模型网关接入位 | 替代 LiteLLM 叙事 |
| `integrations/COZE_STUDIO_INTEGRATION.md` | CREATE | P0 | 建立 AI 应用中枢接入位 | 新增组件 |
| `integrations/N8N_INTEGRATION.md` | CREATE | P0 | 建立自动化 / 编排接入位 | 新增组件 |
| `integrations/NOCOBASE_INTEGRATION.md` | CREATE | P0 | 建立后台 / 审核接入位 | 新增组件 |
| `integrations/CLAUDE_CODE_EXECUTION.md` | UPDATE | P1 | 对齐默认开发执行器定位 | 保持边界清晰 |
| `integrations/GITLAB_INTEGRATION.md` | UPDATE | P1 | 对齐边界系统角色 | 无需大改，重在一致性 |
| `.claude/CURRENT_WORKSPACE_STATUS.md` | DOWNGRADE | P0 | 降级为阶段交接材料 | 不再当主事实源 |
| `.claude/NEW_SESSION_MASTER_CONTEXT.md` | DOWNGRADE | P0 | 降级为会话材料 | 同上 |
| `.claude/NEXT_PHASE_EXECUTION_PLAN.md` | MERGE + DOWNGRADE | P0 | 吸收阶段内容后降级 | 内容并入 `DELIVERY_STAGES.md` |
| `.claude/DESIGN_CORE_PRINCIPLES_AND_RED_LINES.md` | MERGE + DOWNGRADE | P0 | 吸收红线内容 | 并入 `BOUNDARY_AND_SCOPE.md` / `QUALITY_GATES.md` |
| `.claude/OFFICIAL_COMPATIBILITY_AND_PRACTICE.md` | DOWNGRADE | P1 | 保留经验材料属性 | 不作主事实源 |
| `.claude/OPEN_QUESTIONS_AND_TECH_DEBT.md` | UPDATE / RETAIN | P0 | 转成正式技术债来源之一 | 可保留并做正式索引 |
| `AGENTS.bak.md` | DOWNGRADE | P1 | 历史档案化 | 不参与当前判断 |
| `MEMORY.bak.md` | DOWNGRADE | P1 | 历史档案化 | 不参与当前判断 |
| `SOUL.bak.md` | DOWNGRADE | P2 | 历史档案化 | 不参与当前判断 |
| `TOOLS.bak.md` | DOWNGRADE | P2 | 历史档案化 | 不参与当前判断 |
| `USER.bak.md` | DOWNGRADE | P2 | 历史档案化 | 不参与当前判断 |
| `memory/2026-03-15.md` | UPDATE or DELETE | P1 | 处理空壳记忆文件 | 要么补样例，要么删除占位 |
| `skills/README.md` | DEFER | P2 | 暂不优先处理 | 角色未定 |
| `workflows/daily_brief/README.md` | DEFER | P2 | 暂不优先处理 | 除非选其做最小闭环 |
| `workflows/media_generation/README.md` | DEFER | P2 | 暂不优先处理 | 当前非关键 |
| `workflows/publish/README.md` | DEFER | P2 | 暂不优先处理 | 当前非关键 |
| `workflows/weekly_review/README.md` | DEFER / UPDATE | P1 | 可作为未来最小闭环候选 | 先不抢跑 |

---

## 4. 新建文件清单（CREATE）

### 4.1 必建的六类基线
1. `PROJECT_CHARTER.md`
2. `BOUNDARY_AND_SCOPE.md`
3. `DELIVERY_STAGES.md`
4. `CHANGE_CONTROL.md`
5. `QUALITY_GATES.md`

> 注：`ARCHITECTURE_BASELINE.md` 当前更像 **更新/重写**，而非从零创建。

### 4.2 必建的集成骨架
1. `integrations/HIGRESS_INTEGRATION.md`
2. `integrations/COZE_STUDIO_INTEGRATION.md`
3. `integrations/N8N_INTEGRATION.md`
4. `integrations/NOCOBASE_INTEGRATION.md`

---

## 5. 关键重写文件（REWRITE）

### 5.1 `README.md`
目标：
- 作为统一入口
- 清楚回答项目是什么 / 不是什么
- 展示当前技术栈与目录骨架
- 引导到六类基线文档

### 5.2 `BOOTSTRAP.md`
目标：
- 不再空置
- 至少说明 bootstrap 的角色、触发时机、与 BOOT/PROJECT_BOOTSTRAP_SPEC 的关系

### 5.3 `governance/RULE_HARDENING_POLICY.md`
目标：
- 不再空置
- 明确什么规则应从 prose 进入 schema/policy/validator
- 明确优先级与同步原则

### 5.4 `ARCHITECTURE_BASELINE.md`
目标：
- 统一替换旧组件图
- 将当前组件职责写清：
  - Xuanzhi-Core
  - Claude Code
  - Coze Studio
  - n8n
  - NocoBase
  - QMD
  - Higress
  - GitLab CE
  - Docker

---

## 6. 关键更新文件（UPDATE）

### 6.1 根层
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`

### 6.2 治理层
- `governance/GOVERNANCE_GLOSSARY.md`
- `governance/RISK_MODEL.md`
- `governance/APPROVAL_POLICY.md`
- `governance/ROOT_FILE_POLICY.md`
- `governance/FIELD_CANON.md`

### 6.3 策略层
- `policies/approval_rules.yaml`
- `policies/risk_policy.yaml`
- `policies/memory_write_rules.yaml`
- `policies/state_transitions.yaml`

### 6.4 集成层
- `integrations/CLAUDE_CODE_EXECUTION.md`
- `integrations/GITLAB_INTEGRATION.md`

---

## 7. 归并与降级计划

### 7.1 归并（MERGE）
#### 来源：
- `.claude/NEXT_PHASE_EXECUTION_PLAN.md`
- `.claude/DESIGN_CORE_PRINCIPLES_AND_RED_LINES.md`

#### 目标：
- 将可复用内容吸收到：
  - `DELIVERY_STAGES.md`
  - `BOUNDARY_AND_SCOPE.md`
  - `QUALITY_GATES.md`

### 7.2 降级（DOWNGRADE）
以下文件应明确标记为：
- 交接材料
- 历史档案
- 不作为主事实源

#### 交接材料
- `.claude/CURRENT_WORKSPACE_STATUS.md`
- `.claude/NEW_SESSION_MASTER_CONTEXT.md`
- `.claude/NEXT_PHASE_EXECUTION_PLAN.md`
- `.claude/OFFICIAL_COMPATIBILITY_AND_PRACTICE.md`

#### 历史档案
- `*.bak.md`

---

## 8. 建议新增的“说明性索引文件”

### 8.1 可新增：`BASELINE_INDEX.md`
用途：
- 列出六类基线文档
- 列出主事实源
- 列出交接材料和历史档案的分级说明

### 8.2 可新增：`TECH_STACK_CURRENT.md`
用途：
- 记录当前真实组件图
- 避免 README 承载过多变更说明
- 作为架构基线的补充索引

> 这两个不是 P0 必须，但很有帮助。
> 若追求最小动作，可以先不建。

---

## 9. 暂缓处理（DEFER）

以下内容当前不作为 P0 核心目标：

### 9.1 `skills/`
- `skills/README.md`

理由：
- 当前角色未定
- 不影响基线确立

### 9.2 `workflows/`
- `workflows/daily_brief/README.md`
- `workflows/media_generation/README.md`
- `workflows/publish/README.md`

理由：
- 当前没有真实闭环优先级
- 先做基线与结构收敛更重要

### 9.3 非关键空壳集成文档
- `integrations/COMFYUI_PIPELINE.md`
- `integrations/PUBLISH_PIPELINE.md`
- `integrations/VIDEO_PIPELINE.md`

理由：
- 若当前没有实际落地路径，先延后，不再假装完成

---

## 10. 推荐执行顺序（文件级）

### Step 1：建立主轴
1. `PROJECT_CHARTER.md`
2. `BOUNDARY_AND_SCOPE.md`
3. `ARCHITECTURE_BASELINE.md`
4. `DELIVERY_STAGES.md`
5. `CHANGE_CONTROL.md`
6. `QUALITY_GATES.md`

### Step 2：修正入口与根层
7. `README.md`
8. `TOOLS.md`
9. `IDENTITY.md`

### Step 3：修关键空壳
10. `BOOTSTRAP.md`
11. `governance/RULE_HARDENING_POLICY.md`

### Step 4：修治理对齐
12. `governance/GOVERNANCE_GLOSSARY.md`
13. `governance/RISK_MODEL.md`
14. `governance/APPROVAL_POLICY.md`
15. `governance/ROOT_FILE_POLICY.md`

### Step 5：修策略对齐
16. `policies/approval_rules.yaml`
17. `policies/risk_policy.yaml`

### Step 6：补集成骨架
18. `integrations/HIGRESS_INTEGRATION.md`
19. `integrations/COZE_STUDIO_INTEGRATION.md`
20. `integrations/N8N_INTEGRATION.md`
21. `integrations/NOCOBASE_INTEGRATION.md`

### Step 7：做材料分级
22. 降级 `.claude/` 中交接文件
23. 降级 `*.bak.md`

---

## 11. 每个文件的最小完成标准

### CREATE 类
- 文件存在
- 至少有：目的、定义/范围、核心规则、维护要求
- 不与已有核心文档冲突

### REWRITE 类
- 明确取代旧叙事
- 与当前技术栈一致
- 删除或吸收过时内容

### UPDATE 类
- 只修关键冲突
- 不做无关扩写
- 不引入新术语噪音

### DOWNGRADE 类
- 明确标记其非主事实源身份
- 不再参与当前基线判断

---

## 12. 完成后的稳定点应长什么样

执行完本计划后，仓库应满足：

1. 有正式的六类工程化基线
2. README 成为正确入口
3. Higress / Coze Studio / n8n / NocoBase 已进入正式叙事
4. `.claude/` 不再和正式基线混层
5. 关键空壳不再占着高价值位置装完成体
6. 后续任何推进都能回答：
   - 为什么做
   - 做到哪
   - 什么算偏
   - 偏了怎么纠正

---

## 13. 一句话结论
当前最正确的动作不是继续发明更多文档，而是把已有骨架整理成**一个可信的工程化事实平面**。
