# M3 局域网同步与传输

目标
- 在局域网内完成设备到桌面库的单向同步，支持分块上传、断点续传、失败重试与带宽/并发控制。

交付内容
- 桌面端轻量服务：接收端 HTTP/WebSocket（Dart 端内置，非 station/backend）。
- 同步队列：任务模型（文件、块、重试状态）、优先级、并发度控制。
- 传输协议：分块大小与校验（SHA-256），断点续传与完整性验证。
- 错误处理：重试策略、失败告警与日志。

验收标准
- 同步成功率≥99%；支持断点续传；整库断点后恢复无数据损坏。
- 并发控制与带宽限制可配置；CPU/内存占用在可控范围（中等硬件）。
- 无明文密钥；仅本地网段可访问；服务可启停。

约束与边界
- 仅局域网；单向（设备→桌面库）；冲突处理在 M4/M5 中结合索引与浏览策略。

技术要点
- Dart 原生 server（如 shelf/http）与文件 IO；安全令牌校验。
- 传输校验：块级哈希与文件级哈希；完成后入队索引任务（M4）。
- 速率控制与队列可观测（任务日志与错误码）。

风险与预案
- 跨平台网络 API 差异 → 选用稳定的 Dart 包并做兼容层。
- 大文件与视频断点 → 优化块大小与重试阈值；提供手动“继续同步”。

执行计划与进度快照
- 当前状态：pending
- 任务清单：
  - [ ] 接收端服务与认证
  - [ ] 分块与断点续传实现
  - [ ] 队列与并发控制
  - [ ] 错误日志与告警

依赖与关联
- 依赖：M2（令牌与配对）；关联：M4（索引）、M5（浏览）。

输出与交付物链接
- 代码位置：station/desktop/lib/services/sync
- 文档链接：index.zh.md，MVP-scope.zh.md

---

## 功能设计包（M3）

协议与端点（草案）
- /upload/init: POST { device_id, user_id, file_id, size, sha256 } → { session_id, chunk_size }
- /upload/chunk: PUT { session_id, index, sha256, bytes } → { ack }
- /upload/complete: POST { session_id } → 校验文件级哈希并入队索引（M4）
- 认证：令牌校验（与 user_id 绑定），仅局域网可访问。

状态机与队列
- 任务状态：PENDING → TRANSFERRING → VERIFYING → ENCRYPTING（若相册加密）→ DONE / FAILED
- 并发与带宽：config.sync.max_concurrency、config.sync.max_bandwidth_kbps

错误与重试
- 错误码：
  - 40x：认证失败/令牌过期/越权（禁止跨 user_id）
  - 49x：分块校验失败/索引入队失败
  - 50x：IO错误/磁盘满
- 重试：指数退避，断点从最后确认块继续。

安全与隐私
- 明文传输仅限局域网；若相册启用加密，桌面侧在 complete 后进入加密队列（见 ADR-0002）。
- 管理员不可查看具体传输内容，仅可见任务统计。

测试清单
- 断点续传、完整性校验、并发限制、带宽限制、LAN 访问限制、错误码覆盖与日志。