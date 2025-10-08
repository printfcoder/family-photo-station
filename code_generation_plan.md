# 基于Proto的统一代码生成方案

## 目标
- 消除手写模型，所有模型都从Proto生成
- 统一mobile和desktop的模型定义
- 简化模型结构，移除复杂的part语法和hive依赖
- 保持模型的干净和直观

## 方案设计

### 1. 目录结构重构
```
mobile/lib/core/models/
├── photo.dart          # 从photo.pb.dart重命名而来
├── album.dart          # 从album.pb.dart重命名而来
├── photo_list.dart     # PhotoList模型
├── album_list.dart     # AlbumList模型
└── exif_data.dart      # ExifData模型

desktop/lib/core/models/
├── photo.dart          # 与mobile完全相同
├── album.dart          # 与mobile完全相同
├── photo_list.dart     # 与mobile完全相同
├── album_list.dart     # 与mobile完全相同
└── exif_data.dart      # 与mobile完全相同
```

### 2. 生成策略
- 使用protoc生成标准的Dart protobuf模型
- 移除generated/子目录，直接放在models/下
- 统一命名：photo.pb.dart -> photo.dart
- 移除所有手写模型文件

### 3. 依赖简化
- 移除hive依赖（不使用本地存储注解）
- 移除json_annotation依赖
- 移除part语法
- 保留protobuf核心依赖

### 4. 代码生成脚本
创建统一的生成脚本，同时为mobile和desktop生成相同的模型文件

## 实施步骤

1. 创建代码生成脚本
2. 重构desktop项目模型
3. 重构mobile项目模型
4. 更新所有引用
5. 测试功能完整性

## 优势
- 单一数据源（Proto文件）
- 零冗余（mobile和desktop使用相同生成的模型）
- 简化维护（只需维护Proto文件）
- 类型安全（Proto生成的强类型模型）
- 跨平台一致性