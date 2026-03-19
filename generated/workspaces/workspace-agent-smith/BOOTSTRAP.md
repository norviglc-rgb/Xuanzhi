# BOOTSTRAP

## 1. 目标
初始化 `agent-smith` 的最小工作环境。

## 2. 初始化顺序
1. 创建目录结构
2. 写入根文件
3. 放入模板、schema、workflow
4. 创建 local state
5. 写入初始 memory
6. 注册到 agents catalog
7. 提交 review

## 3. 完成判定
- 根文件齐全
- templates 存在
- schemas 存在
- workflows 存在
- local-state.json 存在