# M1 技术架构与环境初始化

目标
- 建立 Flutter Desktop/Mobile 项目骨架与基础依赖；规范项目结构与分析规则；确保跨平台构建运行。

交付内容
- Flutter 桌面端基础工程与目录结构对齐（station/desktop 已存在，补齐架构说明与依赖）。
- 状态管理：GetX 基础引入与模块化结构；避免默认使用 StatefulWidget。
- 配置与常量：不使用相对路径；平台路径选择器与配置持久化（准备后续 M2）。
- Lint/格式化：analysis_options.yaml 对齐；CI 本地脚本（可选）。

验收标准
- 桌面端工程在 macOS/Windows/Linux 可构建与运行（至少 macOS 本机验证）。
- 基础路由、依赖与入口完整；空白壳可启动，日志与错误处理可用。
- 代码注释统一英文；不暴露任何密钥；SVG 作为默认图标/插图格式。

约束与边界
- 技术：Flutter + GetX；不使用 station/backend；所有路径使用绝对路径保存在配置中。

技术要点
- 项目结构：`lib/app`, `lib/modules`, `lib/services`, `lib/routes` 等分层。
- 配置管理：本地 JSON/YAML 配置与安全读写，后续 M2 使用。
- 本地数据库选型占位：SQLite（drift/sqflite_common_ffi），于 M4 定案与落地。

风险与预案
- 多平台差异：打包/插件可用性差异 → 优先验证 macOS，Windows/Linux 跟进。
- 路径与权限：桌面沙箱/权限 → 使用系统文件选择器，持久化安全路径。

执行计划与进度快照
- 当前状态：pending
- 任务清单：
  - [ ] 骨架结构与依赖声明
  - [ ] GetX 初始化（路由/控制器示例）
  - [ ] 配置模块与路径工具封装
  - [ ] 构建与运行验证

依赖与关联
- 关联：doc/product-design-desktop.gdp.zh.md；M2/M4 需要本阶段产出。

输出与交付物链接
- 代码位置：station/desktop/
- 文档链接：index.zh.md，MVP-scope.zh.md