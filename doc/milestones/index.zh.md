# 家庭照片站项目里程碑目录（Index）

目的
- 将所有里程碑拆分为独立文件，并在本目录集中维护清单与状态，避免单文件过大，提升可导航性与架构清晰度。
- 与产品设计文档协同：doc/product-design-desktop.gdp.zh.md、doc/product-design-desktop.zh.md 等。

使用方式
- 每个里程碑均为一个独立文件，命名规范：`M{编号}-{英文短标识}.zh.md`，例如：`M2-desktop-library-init-and-pairing.zh.md`。
- 创建新里程碑时复制 `_template.zh.md`，按模板填写；更新状态：`pending | in_progress | completed`。
- 在 PR/变更中，仅修改对应里程碑文件与此索引（状态与链接），确保变更可追踪。

命名与规范
- 文档语言：中文；代码注释统一英文（代码仓规则）。
- 不在文档中放置密钥或敏感信息；遵循安全和隐私最佳实践。
- 关联目录：
  - 桌面端实现：`station/desktop/`
  - 移动端实现：`mobile/`
  - 原型/协议：`protos/`
  - 设计文档：`doc/`

里程碑总览（计划与链接）
- M0 产品基线与范围对齐（pending）
  - 文件：`M0-product-baseline-and-scope.zh.md`
- M1 技术架构与环境初始化（pending）
  - 文件：`M1-technical-architecture-and-env-init.zh.md`
- M2 桌面库初始化与配对向导（pending）
  - 文件：`M2-desktop-library-init-and-pairing.zh.md`
- M3 局域网同步与传输（pending）
  - 文件：`M3-lan-sync-and-transfer.zh.md`
- M4 导入、去重与索引（pending）
  - 文件：`M4-import-dedup-index.zh.md`
- M5 浏览与检索（pending）
  - 文件：`M5-browse-and-search.zh.md`
- M6 共享相册与导出/回收站（pending）
  - 文件：`M6-sharing-export-recycle.zh.md`
- M7 备份与恢复（pending）
  - 文件：`M7-backup-and-restore.zh.md`
- M8 隐私与安全（pending）
  - 文件：`M8-privacy-and-security.zh.md`
- M9 移动端配对与同步策略（pending）
  - 文件：`M9-mobile-pairing-and-sync-strategy.zh.md`
- M10 NAS/网络盘整合（可选）（pending）
  - 文件：`M10-nas-integration.zh.md`
- M11 可观测与日志（pending）
  - 文件：`M11-observability-and-logging.zh.md`
- M12 打包与分发（pending）
  - 文件：`M12-packaging-and-distribution.zh.md`
- M13 Beta 验证与反馈闭环（pending）
  - 文件：`M13-beta-and-feedback.zh.md`
- M14 性能与规模优化（pending）
  - 文件：`M14-performance-optimization.zh.md`
- M15 AI 能力占位与规划（pending）
  - 文件：`M15-ai-capabilities-planning.zh.md`
- M16 文档与移交（pending）
  - 文件：`M16-docs-and-handover.zh.md`

维护策略
- 所有里程碑文件位于本目录；索引与状态在此文件统一维护。
- 变更时：
  - 新增：复制模板 `_template.zh.md`，按命名规范创建文件，加入上述列表并标注状态。
  - 推进：在里程碑文件中更新进度快照与验收达成情况；在索引更新状态。
  - 完成：将状态标记为 `completed`，在变更历史记录要点。

变更历史（摘要）
- 初始化目录与索引（v0.1）：创建 index 与模板文件；列出 M0–M16 计划。