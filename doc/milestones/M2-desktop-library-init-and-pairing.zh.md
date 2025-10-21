# M2 桌面库初始化与配对向导

目标
- 首启向导完成“库根路径选择+设备ID/令牌生成+局域网配对方式（扫码/发现）”，为同步打基础。

交付内容
- 向导 UI：欢迎页→库路径选择→生成设备ID与令牌→LAN 配对入口（二维码/发现）。
- 配置持久化：库根绝对路径、安全存储设备令牌（不明文）、可导出二维码。
- 配对机制：二维码包含设备ID与短期令牌；LAN 发现广播（可选，后续增强）。

验收标准
- 库路径选择与校验通过，持久化成功；不使用相对路径。
- 配对流程≤30秒（扫码→认证→配对状态确认）。
- 秘钥不明文持久化；令牌可轮换；无 station/backend 依赖。

约束与边界
- 局域网内配对；不做公网注册；移动端将在后续里程碑适配。
- 多用户目录隔离：库根下按用户隔离子目录（例如 /LibraryRoot/{user_id}/），绝对路径持久化，权限隔离。
- 管理员受限视图：管理员仅可查看用户清单与照片计数，不能浏览具体内容。

技术要点
- 二维码生成与解析；局域网发现（mDNS/UDP 广播占位）。
- 令牌生成与存储（加密存储/系统钥匙串，跨平台差异考虑）。
- 配置文件结构与版本（用于后续备份/恢复）。

风险与预案
- 跨平台二维码/存储兼容 → 选择跨平台库并验证。
- 局域网广播可靠性 → 提供扫码作为主路径，发现为辅助。

执行计划与进度快照
- 当前状态：pending
- 任务清单：
  - [ ] 向导 UI 与流程串联
  - [ ] 路径选择器与校验
  - [ ] 设备ID/令牌生成与保存
  - [ ] 二维码生成与配对确认页

依赖与关联
- 依赖：M1（架构与配置模块）；关联：M3（同步）、M7（备份）。

输出与交付物链接
- 代码位置：station/desktop/lib/modules/onboarding
- 文档链接：index.zh.md，MVP-scope.zh.md

---

## 功能设计包（M2）

范围与流程
- 首启向导：欢迎 → 库根路径选择（绝对路径校验） → 生成设备ID/令牌 → 选择用户或创建用户 → 展示二维码/局域网发现 → 配对成功页。
- 多用户：新建用户会创建 /LibraryRoot/{user_id}/ 目录；管理员视图仅显示用户清单与计数。

数据结构（草案）
- Config:
  - library_root: string
  - users: [{ user_id: string, name: string, dir_abs_path: string, role: 'user'|'admin' }]
  - tokens: [{ device_id: string, user_id: string, token_id: string, expires_at: int64 }]
- QR Payload:
  - { device_id, token_id, user_id, issued_at, ttl_seconds }

接口契约
- OnboardingController（GetX）：
  - pickLibraryRoot(): 验证绝对路径，不允许相对路径。
  - createUser(name, role): 生成 user_id，创建目录并写入配置。
  - issueToken(user_id): 生成令牌并持久化（安全存储/钥匙串）。
  - generateQr(user_id): 返回二维码内容（包含短期令牌）。
  - confirmPairing(device_id, token_id): 验证并完成配对。

校验与测试
- 用例：路径校验、用户创建目录、令牌生成与过期、二维码解析与配对耗时（≤30秒）、管理员受限视图。
- 失败场景：路径不可写、钥匙串不可用、二维码失效、重复配对冲突。

与 ADR 的关系
- 目录隔离：参见 ADR-0001。
- 管理员受限视图：参见 ADR-0003。