# Docker Full Validation Checklist (Clone-Only Deployment)

Date: 2026-03-20  
Scope: 在 Docker 中按真实用户路径部署并全量深测；仅允许 `git clone` 到 `~/.openclaw` 作为部署方式。  
Execution mode: `iterative_module_first`（测一点改一点，必要时切换集中修复）

## A. Deployment Baseline (Required)

| id | item | pass criteria | status | evidence |
| --- | --- | --- | --- | --- |
| DEP-01 | 容器内 OpenClaw 可执行 | `openclaw --version` 成功 | pass | docker-deploy-evidence.md |
| DEP-02 | clone-only 部署 | `git clone <repo> ~/.openclaw` 成功，未使用额外部署脚本 | pass | docker-deploy-evidence.md |
| DEP-03 | OpenRouter 凭据注入 | `OPENROUTER_API_KEY` 在容器运行态可见且不落盘 | pass | docker-deploy-evidence.md |
| DEP-04 | OpenRouter provider 可连通 | 最少一次 agent 调用成功返回 | fail | RG-13 |
| DEP-05 | 模型主备链生效 | 看到主模型失败后 fallback 成功或完整失败审计 | in_progress | RG-13, RG-15 |

## B. Module Coverage

| id | module | test focus | status | defects |
| --- | --- | --- | --- | --- |
| MOD-01 | 配置层（openclaw.json/policies/schemas） | schema 合法性、provider 与工具策略一致性 | in_progress | RG-14 |
| MOD-02 | hooks | boot/command hooks 执行与审计字段完整性 | pass | unittest: test_hooks_allowlist |
| MOD-03 | skills | 自动触发条件、前置 guard、负载保护 | pass | unittest: test_skills_governance |
| MOD-04 | state | agents/users/router/skills 状态读写一致性 | pass | unittest: test_product_contracts |
| MOD-05 | audit | requestId 串联、统一字段、路径一致性 | in_progress | RG-12, RG-13 |
| MOD-06 | templates | core/daily 模板渲染完整性与运行可用性 | in_progress | RG-12 |

## C. Agent Coverage

| id | agent | test focus | status | defects |
| --- | --- | --- | --- | --- |
| AG-01 | orchestrator | 调度、重试、失败回滚、任务分配准确性 | in_progress | RG-13, RG-15 |
| AG-02 | skills-smith | skill 生成质量、评估机制、可执行性 | in_progress | RG-13 |
| AG-03 | ops | guard 执行、操作可回滚、交付证据完整 | in_progress | RG-13 |
| AG-04 | critic | review gate 阻断与审计 | in_progress | RG-13 |
| AG-05 | architect | 规范落地与结构一致性验证 | in_progress | RG-14 |
| AG-06 | agent-smith | agent 物化/更新链路完整性 | in_progress | RG-13 |
| AG-07 | claude-code | 外部编码域占位与路由边界 | in_progress | RG-13 |
| AG-08 | daily user agent | 实例化、隔离、权限边界 | pending | |

## D. Workflow Coverage

| id | workflow | test focus | status | defects |
| --- | --- | --- | --- | --- |
| WF-01 | `materialize-core-agents` | 目录/状态/audit/review 全链路 | in_progress | RG-12 |
| WF-02 | `create-daily-user` | 多用户创建、隔离、状态注册 | in_progress | RG-12 |
| WF-03 | `memory-promote` | policy 校验、拒绝与通过双路径、审计一致 | in_progress | RG-12 |

## E. End-to-End Collaboration

| id | scenario | pass criteria | status | defects |
| --- | --- | --- | --- | --- |
| E2E-01 | orchestrator -> skills-smith -> ops -> critic | 任务按预期分配并产出审计闭环 | in_progress | RG-13, RG-15 |
| E2E-02 | 低能力模型降级运行 | 保持质量门控，不因弱模型跳过关键步骤 | in_progress | RG-13 |
| E2E-03 | 故障注入与恢复 | 任一关键失败可定位、可恢复、可重放 | in_progress | RG-12, RG-15 |

## F. Remote Mirror (after Docker closure)

| id | item | pass criteria | status | evidence |
| --- | --- | --- | --- | --- |
| REM-01 | `lc@10.0.1.70` 污染清理 | 基于事实清理 `~/.openclaw` 历史污染 | pending | |
| REM-02 | 同等深度复测 | 复制 Docker 全量清单逐项执行 | pending | |
| REM-03 | 差异分析 | 远程结果与 Docker 结果对比并回流修复 | pending | |
