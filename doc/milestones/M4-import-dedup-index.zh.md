# M4 导入、去重与索引

目标
- 将同步到库根的媒体导入索引；解析元数据；进行文件级哈希去重；生成预览缩略图，建立本地检索基础。

交付内容
- 元数据解析：EXIF/IPTC/XMP（拍摄时间、设备、地理等基础字段）。
- 去重：文件级哈希（SHA-256）；重复文件软合并或标记；（近似重复 pHash 后续占位）。
- 预览生成：WebP/AVIF 缩略图队列；失败重试；清理策略。
- 索引库：SQLite（drift/ffi）定义表结构（照片、相册、设备、标签等）。

验收标准
- 去重检出率≈100%，误报≈0；索引吞吐≥3000 媒体/小时（视硬件可调）。
- 预览生成成功率≥99%；失败有重试与日志；存储空间可控。
- 索引一致性：文件/索引一一对应；变更有审计轨迹。

约束与边界
- 不回写原文件元数据（MVP）；仅本地索引与预览。

技术要点
- 流水线：导入→元数据→哈希→索引→预览（可并行队列）。
- 数据库：表结构与迁移版本；事务保证一致性；读写分离（可选）。

风险与预案
- 异常文件/损坏元数据 → 容错解析、降级策略、错误库。
- 大量预览生成耗时 → 队列分级、后台任务、功耗控制。

执行计划与进度快照
- 当前状态：pending
- 任务清单：
  - [ ] EXIF/IPTC/XMP 解析模块
  - [ ] 哈希与去重流程
  - [ ] 预览生成队列
  - [ ] SQLite 表结构与迁移

依赖与关联
- 依赖：M3（同步）；关联：M5（浏览与检索）。

输出与交付物链接
- 代码位置：station/desktop/lib/services/indexer
- 文档链接：index.zh.md，MVP-scope.zh.md

---

## 功能设计包（M4）

SQLite 表结构（草案）
- users(user_id PK, name, role, dir_abs_path)
- devices(device_id PK, user_id FK)
- albums(album_id PK, user_id FK, name, is_encrypted BOOL, created_at, updated_at)
- photos(photo_id PK, user_id FK, album_id FK, file_abs_path, sha256, taken_at, device_id, mime, encrypted BOOL)
- previews(photo_id FK, blob/encrypted_blob, mime, generated_at)
- tags(tag_id PK, user_id FK, name)
- photo_tags(photo_id FK, tag_id FK)

索引策略
- 常用查询索引：photo(user_id, taken_at)、album(user_id, updated_at)、photo(user_id, album_id)
- 去重：sha256 唯一约束（同 user_id 范围）；跨用户去重后续评估。

预览队列
- 策略：加密相册不生成明文预览；若生成则加密存储并关联相册密钥。
- 失败重试：指数退避；错误库记录。

一致性与审计
- 事务化导入；文件与索引一一对应；变更记录审计轨迹。

测试清单
- 解析兼容性、去重正确性、预览生成率、索引吞吐、用户隔离查询、加密相册索引流程。