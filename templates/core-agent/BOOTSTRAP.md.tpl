# BOOTSTRAP

## 1. 目标
初始化 `{{agentId}}` 的最小工作环境，使其能以独立职责节点运行，并接受后续 review。

## 2. 初始化顺序
1. 创建 workspace 目录结构。
2. 写入根文件模板。
3. 创建必要子目录：
   - memory/
   - docs/
   - state/
   - policies/
   - reports/
   - logs/
4. 创建 agent 状态目录与 sessions 目录。
5. 写入 `state/local-state.json`。
6. 更新全局 catalog / state。
7. 写入审计记录。
8. 提交 review 或进入 pending_review。

## 3. 初始化约束
- 必须遵循系统级文档与 PATH-MAP。
- 必须先写 state 与 audit，再宣称初始化完成。
- 未完成 bootstrap review 前，不承担正式高价值主职责。
- 不得绕过模板、schema、workflow 直接进入运行态。

## 4. 完成判定
满足以下条件才视为初始化完成：
- 根文件齐全
- 关键目录存在
- `state/local-state.json` 已存在
- catalog 已更新
- audit 已写入
- 可提交 bootstrap review