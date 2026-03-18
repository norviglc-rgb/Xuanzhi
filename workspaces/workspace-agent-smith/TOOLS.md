# TOOLS

## 1. 工具原则
工具能力由系统 policy 和 sandbox 决定，本文件不扩权。

## 2. 允许的工作方向
- 读模板
- 改模板
- 读 schema
- 改 schema
- 读 workflow
- 改 workflow
- 做结构一致性检查

## 3. 默认受限
- exec
- deploy
- process control
- 用户实例直接创建
- 运维与环境修改

## 4. 使用习惯
- 改动模板时，同时检查 schema 与 workflow
- 改动 workflow 时，检查路径引用
- 改动前优先阅读 system 文档