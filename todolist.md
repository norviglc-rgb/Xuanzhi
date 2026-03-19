# Xuanzhi 仓库重构 TODO List

> 目标：按“方案 A”完成仓库分层整理，把当前混合的设计态 / 运行态 / 生成物 / 参考资料拆开，为后续继续跑 MVP 做准备。  
> 原则：**先整理结构，再修路径，再验证 workflow，最后再继续跑 MVP。**

---

## 0. 使用说明

- [ ] 整理过程中，**不要一边重构一边新增功能**
- [ ] 所有移动文件操作，优先 `git mv`，保证历史可追踪
- [ ] 每完成一个大阶段，执行一次：
  - [ ] `git status`
  - [ ] 核对目录树
  - [ ] 检查是否出现断链引用
- [ ] 不确定的文件先放入 `spec/` 或 `generated/`，**不要先删**
- [ ] 删除动作必须满足：确认不是 runtime 真相源、不是 workflow 依赖、不是唯一信息载体

---

## 1. 建立新的顶层分层结构

### 1.1 新建顶层目录
- [ ] 新建 `runtime/`
- [ ] 新建 `spec/`
- [ ] 新建 `reference/`
- [ ] 新建 `generated/`
- [ ] 新建 `bootstrap/`

### 1.2 新建顶层说明文件
- [ ] 新建 `REPO-MAP.md`
- [ ] 准备重写根目录 `README.md`
- [ ] 检查 `.gitignore`，准备补充 generated / logs / sessions / audit 规则

### 1.3 完成标准
- [ ] 根目录已经具备 5 个新顶层目录
- [ ] 旧内容还未移动前，目录骨架已就位
- [ ] `git status` 可读，没有误删关键文件

---

## 2. 迁移 spec（研发说明 / 需求 / bring-up 资料）

### 2.1 requirements
- [ ] 将 `docs/requirements/open_claw多agent系统v1需求规格.md` 移动到 `spec/requirements/open_claw多agent系统v1需求规格.md`

### 2.2 system 文档中属于设计/迁移/操作说明的内容
- [ ] 将 `docs/system/BOOTSTRAP-CHECKLIST.md` 移动到 `spec/bringup/BOOTSTRAP-CHECKLIST.md`
- [ ] 将 `docs/system/BRING-UP-ORDER.md` 移动到 `spec/bringup/BRING-UP-ORDER.md`
- [ ] 将 `docs/system/PATH-MAP.md` 移动到 `spec/migration/PATH-MAP-final.md`

### 2.3 design / decisions
- [ ] 将 `docs/design/` 移动到 `spec/architecture/design/`（若为空则删除空目录）
- [ ] 将 `docs/decisions/` 移动到 `spec/architecture/decisions/`（若为空则删除空目录）

### 2.4 检查报告 / 临时说明
- [ ] 新建 `spec/bringup/check-reports/`
- [ ] 将模板检查报告、一次性核对报告、临时 bring-up 报告移入该目录
- [ ] 把“上个会话交接用但已低可信”的文档归档到 `spec/migration/` 或 `spec/bringup/` 下，不再作为真相源

### 2.5 完成标准
- [ ] `spec/` 下已能完整承载需求、迁移、bring-up 说明
- [ ] 根目录和 `runtime/` 中不再混放研发期说明书
- [ ] 所有 spec 文件都不再被误当成 runtime 依赖

---

## 3. 建立 runtime 真相源目录

### 3.1 新建 runtime 子目录
- [ ] 新建 `runtime/docs/system/`
- [ ] 新建 `runtime/policies/`
- [ ] 新建 `runtime/schemas/`
- [ ] 新建 `runtime/workflows/`
- [ ] 新建 `runtime/templates/`
- [ ] 新建 `runtime/ops/`
- [ ] 新建 `runtime/review/`
- [ ] 新建 `runtime/architect/`
- [ ] 新建 `runtime/skills/`
- [ ] 新建 `runtime/agents/`
- [ ] 新建 `runtime/workspaces/`
- [ ] 新建 `runtime/state/`

### 3.2 迁移 system 真相源文件
- [ ] 将 `docs/system/ARCHITECTURE.md` 精简后放入 `runtime/docs/system/ARCHITECTURE.md`
- [ ] 将扩展说明版另存为 `spec/architecture/ARCHITECTURE-extended.md`
- [ ] 将 `docs/system/GOVERNANCE.md` 精简后放入 `runtime/docs/system/GOVERNANCE.md`
- [ ] 将 `docs/system/FILE-NAMING.md` 放入 `runtime/docs/system/FILE-NAMING.md`

### 3.3 补充 runtime README / 配置示例
- [ ] 新建 `runtime/README-runtime.md`
- [ ] 新建 `runtime/openclaw.json.example`

### 3.4 完成标准
- [ ] runtime 已经成为“可搬运产品包”的雏形
- [ ] runtime/docs/system 只保留简洁真相源，不混入历史解释
- [ ] `ARCHITECTURE.md` / `GOVERNANCE.md` / `FILE-NAMING.md` 可以被 agent 直接读取，不是长篇附录文档

---

## 4. 迁移 policies / schemas / workflows

### 4.1 policies
- [ ] 将 `policies/memory-policy.json` 移动到 `runtime/policies/memory-policy.json`
- [ ] 将 `policies/routing-policy.json` 移动到 `runtime/policies/routing-policy.json`
- [ ] 将 `policies/tool-policy-matrix.json` 移动到 `runtime/policies/tool-policy-matrix.json`

### 4.2 schemas
- [ ] 将 `schemas/review.schema.json` 移动到 `runtime/schemas/review.schema.json`
- [ ] 将 `schemas/task.schema.json` 移动到 `runtime/schemas/task.schema.json`
- [ ] 将 `schemas/user-profile.schema.json` 移动到 `runtime/schemas/user-profile.schema.json`

### 4.3 workflows
- [ ] 将 `workflows/system/materialize-core-agents.json` 移动到 `runtime/workflows/system/materialize-core-agents.json`
- [ ] 将 `workflows/users/create-daily-user.json` 移动到 `runtime/workflows/users/create-daily-user.json`
- [ ] 将 `workflows/memory/promote.json` 移动到 `runtime/workflows/memory/promote.json`

### 4.4 完成标准
- [ ] runtime 下具备完整的 machine-readable 真相源
- [ ] 根目录旧的 `policies/` / `schemas/` / `workflows/` 已清空或移除
- [ ] 路径重构后，没有 workflow 仍然指向旧根目录位置

---

## 5. 迁移 templates

### 5.1 core-agent 模板
- [ ] 将 `templates/core-agent/AGENTS.md.tpl` 移动到 `runtime/templates/core-agent/AGENTS.md.tpl`
- [ ] 将 `templates/core-agent/BOOT.md.tpl` 移动到 `runtime/templates/core-agent/BOOT.md.tpl`
- [ ] 将 `templates/core-agent/BOOTSTRAP.md.tpl` 移动到 `runtime/templates/core-agent/BOOTSTRAP.md.tpl`
- [ ] 将 `templates/core-agent/HEARTBEAT.md.tpl` 移动到 `runtime/templates/core-agent/HEARTBEAT.md.tpl`
- [ ] 将 `templates/core-agent/IDENTITY.md.tpl` 移动到 `runtime/templates/core-agent/IDENTITY.md.tpl`
- [ ] 将 `templates/core-agent/MEMORY.md.tpl` 移动到 `runtime/templates/core-agent/MEMORY.md.tpl`
- [ ] 将 `templates/core-agent/SOUL.md.tpl` 移动到 `runtime/templates/core-agent/SOUL.md.tpl`
- [ ] 将 `templates/core-agent/TOOLS.md.tpl` 移动到 `runtime/templates/core-agent/TOOLS.md.tpl`

### 5.2 daily-template 模板
- [ ] 将 `templates/daily-template/` 整体移动到 `runtime/templates/daily-template/`
- [ ] 确认其中只保留模板和本地 policy / state 初始模板
- [ ] 删除或迁移 daily-template 中非运行必需的说明性文件到 `spec/`

### 5.3 模板检查报告
- [ ] 将 `templates/core-agent/CHECK-REPORT.md`（如存在）移动到 `spec/bringup/check-reports/core-agent-template-check-report.md`

### 5.4 完成标准
- [ ] `runtime/templates/` 里只保留模板，不再混入检查报告
- [ ] `agent-smith` 的模板资产集中且清晰
- [ ] 模板目录已经适合被 workflow 直接引用

---

## 6. 重构 state：拆成 seed 与 generated

### 6.1 建立 runtime/state 种子结构
- [ ] 新建 `runtime/state/agents/`
- [ ] 新建 `runtime/state/users/`
- [ ] 新建 `runtime/state/skills/`
- [ ] 新建 `runtime/state/router/`
- [ ] 新建 `runtime/state/audit/`

### 6.2 处理 catalog / index / tasks
- [ ] 将 `state/agents/catalog.json` 改造成 `runtime/state/agents/catalog.seed.json`
- [ ] 将 `state/users/index.json` 改造成 `runtime/state/users/index.seed.json`
- [ ] 将 `state/skills/catalog.json` 改造成 `runtime/state/skills/catalog.seed.json`
- [ ] 将 `state/router/tasks.json` 改造成 `runtime/state/router/tasks.seed.json`

### 6.3 建立 generated/state 运行态目录
- [ ] 新建 `generated/state/agents/`
- [ ] 新建 `generated/state/users/`
- [ ] 新建 `generated/state/skills/`
- [ ] 新建 `generated/state/router/`

### 6.4 处理 audit
- [ ] 新建 `generated/audit/`
- [ ] 将 `state/audit/core-agent-materialization.jsonl` 移动到 `generated/audit/core-agent-materialization.jsonl`
- [ ] 将 `state/audit/memory-promotion.jsonl` 移动到 `generated/audit/memory-promotion.jsonl`
- [ ] 将 `state/audit/user-provision.jsonl` 移动到 `generated/audit/user-provision.jsonl`
- [ ] 在 `runtime/state/audit/` 仅保留 `.gitkeep` 或 `README.md`

### 6.5 完成标准
- [ ] runtime/state 只保留种子结构
- [ ] generated/ 才承载真实运行态
- [ ] 再也不会把 jsonl 审计活文件当成产品源文件

---

## 7. 重构 agents 目录

### 7.1 建立 runtime 层最小说明
- [ ] 新建 `runtime/agents/README.md`
- [ ] 在 README 中写清：
  - [ ] 实际 agent 目录在 `~/.openclaw/agents/<agentId>/`
  - [ ] repo 主要维护模板与结构约定
  - [ ] `sessions/` 属于运行态，不纳入 repo

### 7.2 处理当前 `agents/*`
- [ ] 检查 `agents/agent-smith/agent/` 是否为空；若为空则删除
- [ ] 检查 `agents/agent-smith/sessions/` 是否为空；删除
- [ ] 检查 `agents/architect/agent/` 是否为空；删除
- [ ] 检查 `agents/architect/sessions/` 是否为空；删除
- [ ] 检查 `agents/claude-code/agent/` 是否为空；删除
- [ ] 检查 `agents/claude-code/sessions/` 是否为空；删除
- [ ] 检查 `agents/critic/agent/` 是否为空；删除
- [ ] 检查 `agents/critic/sessions/` 是否为空；删除
- [ ] 检查 `agents/ops/agent/` 是否为空；删除
- [ ] 检查 `agents/ops/sessions/` 是否为空；删除
- [ ] 检查 `agents/orchestrator/agent/` 是否为空；删除
- [ ] 检查 `agents/orchestrator/sessions/` 是否为空；删除
- [ ] 检查 `agents/skills-smith/agent/` 是否为空；删除
- [ ] 检查 `agents/skills-smith/sessions/` 是否为空；删除

### 7.3 如需保留占位
- [ ] 仅在必要时用 `.gitkeep` 保留极少量目录占位
- [ ] 不保留任何空 `sessions/`

### 7.4 完成标准
- [ ] repo 里不再把 `sessions/` 当结构性目录保存
- [ ] agent 运行态目录已从源码仓库中退出
- [ ] `runtime/agents/README.md` 能解释清楚真实路径语义

---

## 8. 重构 workspaces 目录

### 8.1 当前已物化 workspace
- [ ] 将 `workspaces/workspace-agent-smith/` 从主线结构中移走
- [ ] 选择其归宿：
  - [ ] 若作为示例：放入 `spec/architecture/examples/workspace-agent-smith-example/`
  - [ ] 若作为运行态产物：放入 `generated/workspaces/workspace-agent-smith/`

### 8.2 空的待物化 workspace
- [ ] 删除 `workspaces/workspace-architect/`（若为空）
- [ ] 删除 `workspaces/workspace-claude-code/`（若为空）
- [ ] 删除 `workspaces/workspace-critic/`（若为空）
- [ ] 删除 `workspaces/workspace-ops/`（若为空）
- [ ] 删除 `workspaces/workspace-orchestrator/`（若为空）
- [ ] 删除 `workspaces/workspace-skills-smith/`（若为空）

### 8.3 建立 generated/workspaces
- [ ] 新建 `generated/workspaces/`
- [ ] 所有真实物化出的 workspace 今后默认进入 `generated/workspaces/`（repo 演练态）
- [ ] 真正部署时再同步到 `~/.openclaw/workspaces/`

### 8.4 完成标准
- [ ] runtime 中不再混放大量真实物化 workspace
- [ ] workspace 实例与模板彻底分开
- [ ] 空壳目录不再占位污染目录树

---

## 9. 迁移 ops / review / architect 资产

### 9.1 ops
- [ ] 将 `ops/ALLOWLIST.json` 移动到 `runtime/ops/ALLOWLIST.json`

### 9.2 review
- [ ] 将 `review/critic-review-checklist.md` 移动到 `runtime/review/critic-review-checklist.md`

### 9.3 architect
- [ ] 将 `architect/handoff-checklist.md` 移动到 `runtime/architect/handoff-checklist.md`

### 9.4 完成标准
- [ ] 这三个目录只保留 runtime 必需文件
- [ ] 不再把 checklist 混在根目录业务资产中
- [ ] core-agent 协作工件已经集中在 runtime 范围内

---

## 10. 重构 skills

### 10.1 skills README
- [ ] 将 `skills/README.md` 移动到 `runtime/skills/README.md`

### 10.2 技能结构说明
- [ ] 在 `runtime/skills/README.md` 里写清楚：
  - [ ] repo 中 skill 目录的职责
  - [ ] OpenClaw 实际 workspace skill 路径约定
  - [ ] 未来 skills-smith 如何维护 skill 模板 / 真正安装技能

### 10.3 完成标准
- [ ] `skills/` 已纳入 runtime 层
- [ ] skill 的 repo 管理与 OpenClaw workspace 安装位置区别清晰

---

## 11. 重构 reference

### 11.1 迁移 openclaw 文档镜像
- [ ] 将 `reference/openclaw/` 统一放到顶层 `reference/openclaw/`
- [ ] 将 `docs/reference/openclaw-docs-index.md` 移动到 `reference/indexes/openclaw-docs-index.md`

### 11.2 控制 reference 体积
- [ ] 检查是否要保留 651 文件的全量镜像
- [ ] 若不必要，改成：
  - [ ] 保留索引
  - [ ] 保留常用子集
  - [ ] 或新增拉取脚本到 `bootstrap/`

### 11.3 完成标准
- [ ] 外部参考资料彻底从 runtime 剥离
- [ ] reference 成为可选知识层，而不是产品包内容

---

## 12. 修复 workflow / 文档路径引用

### 12.1 搜索旧路径引用
- [ ] 全局搜索 `docs/system/`
- [ ] 全局搜索 `policies/`
- [ ] 全局搜索 `schemas/`
- [ ] 全局搜索 `workflows/`
- [ ] 全局搜索 `templates/`
- [ ] 全局搜索 `state/`
- [ ] 全局搜索 `workspaces/`
- [ ] 全局搜索 `agents/`

### 12.2 修复 `materialize-core-agents.json`
- [ ] 确保仅引用 `runtime/` 下真文件
- [ ] 不再引用 `spec/` 下文档
- [ ] 不再依赖 `PATH-MAP.md` 作为运行时路径解释层

### 12.3 修复 `create-daily-user.json`
- [ ] 检查模板路径是否全部指向 `runtime/templates/...`
- [ ] 检查 schema / policy / state 的路径是否全部指向 `runtime/...`
- [ ] 检查生成目标是否明确区分 repo 演练态与真实 `~/.openclaw/`

### 12.4 修复 `promote.json`
- [ ] 检查 audit 输出位置
- [ ] 检查 state / memory 目标位置是否已与新结构匹配

### 12.5 完成标准
- [ ] runtime 内部路径闭环成立
- [ ] 没有 workflow 继续指向旧根目录布局
- [ ] `spec/` 被完全从运行依赖链中剥离

---

## 13. 重写 README / REPO-MAP / runtime 说明

### 13.1 根 README
- [ ] 重写根目录 `README.md`
- [ ] 内容只保留：
  - [ ] 仓库定位
  - [ ] 四层分层说明
  - [ ] 如何使用 `runtime/`
  - [ ] 如何阅读 `spec/`
  - [ ] MVP 继续前的注意事项

### 13.2 REPO-MAP
- [ ] 完成 `REPO-MAP.md`
- [ ] 明确每个顶层目录职责
- [ ] 明确哪些内容会被复制到 `~/.openclaw/`
- [ ] 明确哪些内容绝不能复制

### 13.3 runtime 说明
- [ ] 完成 `runtime/README-runtime.md`
- [ ] 解释 runtime 到 `~/.openclaw/` 的映射关系
- [ ] 写明哪些文件是 seed，哪些会运行后生成

### 13.4 完成标准
- [ ] 新加入的人能在 5 分钟内理解仓库结构
- [ ] README 不再承担系统全量说明
- [ ] REPO-MAP 成为整理后的导航入口

---

## 14. 更新 .gitignore

### 14.1 必加项
- [ ] 忽略 `generated/audit/*.jsonl`
- [ ] 忽略 `generated/workspaces/**/logs/`
- [ ] 忽略 `generated/workspaces/**/memory/`
- [ ] 忽略 `generated/workspaces/**/reports/`
- [ ] 忽略 `generated/agents/**/sessions/`
- [ ] 忽略本地缓存、临时检查文件、下载缓存

### 14.2 完成标准
- [ ] 运行态噪音不再污染 git
- [ ] generated 层只保留必要结构，不强制提交活数据

---

## 15. 删除清理阶段

### 15.1 可直接删除的内容
- [ ] 删除所有空目录
- [ ] 删除所有空 `sessions/`
- [ ] 删除所有未物化但空的 workspace 占位
- [ ] 删除旧根目录已迁走后的重复文件
- [ ] 删除不再需要的临时检查输出（前提是已归档或确认无价值）

### 15.2 谨慎删除的内容
- [ ] 删除 `PATH-MAP` 前再次确认 workflow 已不依赖它
- [ ] 删除任何 state 活文件前先确认 seed / generated 双层已完成
- [ ] 删除任何唯一示例前先确认已迁移到 `spec/examples/`

### 15.3 完成标准
- [ ] 根目录显著变干净
- [ ] 不存在同一真相源的双份冲突
- [ ] 没有“看起来重要但其实空”的历史包袱目录

---

## 16. 第一轮重构后的验证

### 16.1 结构验证
- [ ] 输出一次新的目录树
- [ ] 人工核对顶层是否只剩合理内容
- [ ] 核对 runtime / spec / reference / generated 是否边界清晰

### 16.2 路径验证
- [ ] 全局搜索是否还残留旧路径
- [ ] 检查 JSON workflow 中是否有路径断裂
- [ ] 检查 markdown 中是否有严重过时说明

### 16.3 逻辑验证
- [ ] `agent-smith` 仍只负责模板，不负责物化
- [ ] `ops` 仍负责物化和 lifecycle
- [ ] `critic` 仍负责 bootstrap / provision / delivery review
- [ ] core-agent workspace 目标路径仍相对 `~/.openclaw/`

### 16.4 完成标准
- [ ] 重构后不会再次把 repo 拉回“根目录堆东西”的状态
- [ ] 可以开始进入第二轮：workflow 实跑前检查

---

## 17. 第二轮（重构后、MVP 前）准备项

> 这一部分不是现在立刻做，而是在第一轮整理完成后再开始。

### 17.1 runtime 包检查
- [ ] 检查 `runtime/` 是否已经足够复制到 `~/.openclaw/`
- [ ] 检查 `runtime/openclaw.json.example` 是否足够表达最小配置
- [ ] 检查 `runtime/docs/system/*` 是否足够精简

### 17.2 workflow 检查
- [ ] dry-run `materialize-core-agents`
- [ ] dry-run `create-daily-user`
- [ ] 检查 state seed -> runtime state 的生成逻辑

### 17.3 MVP 恢复前门槛
- [ ] core-agent 物化路径清晰
- [ ] daily-user 实例化路径清晰
- [ ] complex routing 依赖文件都在 runtime 闭环内
- [ ] heartbeat 仍保持关闭，最后再启

---

## 18. 你整理时的判断准则（每碰到一个文件都过一遍）

- [ ] 这是运行时必须读的吗？是则进 `runtime/`
- [ ] 这是需求/迁移/历史说明吗？是则进 `spec/`
- [ ] 这是外部参考资料吗？是则进 `reference/`
- [ ] 这是运行后才会生成或频繁变化的吗？是则进 `generated/`
- [ ] 以上都不是：优先归档再判断，不要直接丢

---

## 19. 第一轮完成定义（DoD）

当以下条件全部满足时，视为第一轮重构完成：

- [ ] 仓库已分成 `runtime/`、`spec/`、`reference/`、`generated/`
- [ ] 根目录 README 已重写
- [ ] `REPO-MAP.md` 已完成
- [ ] runtime 已包含 docs/system + policies + schemas + workflows + templates + ops/review/architect
- [ ] state 已拆为 seed 与 generated
- [ ] workspaces / agents 的运行态部分已剥离
- [ ] reference 已剥离
- [ ] workflow 路径已开始切到 runtime 闭环
- [ ] 仓库目录看起来像“可发布产品 + 设计资料库”，不再像“一个大杂烩根目录”

---

## 20. 第二轮完成后再做的事（暂不执行）

- [ ] 物化全部 core agents
- [ ] 跑第一次 bootstrap review
- [ ] 创建第一个 `daily-test-user`
- [ ] 验证 complex routing -> `claude-code`
- [ ] 最后才开启 heartbeat

---

## 附：建议整理顺序（实际操作）

- [ ] 第 1 步：先新建顶层目录，不删任何旧文件
- [ ] 第 2 步：先搬 `spec/` 和 `reference/`
- [ ] 第 3 步：再搬 `runtime/` 真相源
- [ ] 第 4 步：再拆 `state/`
- [ ] 第 5 步：再清 `agents/` / `workspaces/`
- [ ] 第 6 步：最后修 workflow 路径
- [ ] 第 7 步：最后删旧目录和空壳
- [ ] 第 8 步：输出新目录树，做第二轮审查
