# Family Photo Station Backend

基于 Go + Hertz + GORM 的家庭照片管理系统后端服务。

## 技术栈

- **Web框架**: [CloudWeGo Hertz](https://www.cloudwego.io/zh/docs/hertz/)
- **ORM**: [GORM](https://gorm.io/)
- **数据库**: SQLite (开发) / PostgreSQL (生产)
- **缓存**: Redis
- **认证**: JWT
- **日志**: Logrus

## 功能特性

- 用户认证与授权
- 照片上传与管理
- 相册管理
- 智能标签与分类
- 人脸识别
- 实时同步
- RESTful API

## 项目结构

```
backend/
├── main.go                 # 应用入口
├── go.mod                  # Go模块文件
├── config.yaml             # 配置文件
├── Dockerfile              # Docker配置
├── internal/               # 内部包
│   ├── config/            # 配置管理
│   ├── database/          # 数据库连接
│   ├── model/             # 数据模型
│   ├── service/           # 业务逻辑
│   ├── handler/           # HTTP处理器
│   └── middleware/        # 中间件
└── data/                  # 数据目录
    ├── photos/            # 照片存储
    ├── thumbnails/        # 缩略图
    └── temp/              # 临时文件
```

## 快速开始

### 环境要求

- Go 1.21+
- SQLite3 (开发环境)
- PostgreSQL 13+ (生产环境)
- Redis 6+ (可选)

### 安装依赖

```bash
go mod download
```

### 配置

复制并修改配置文件：

```bash
cp config.yaml config.local.yaml
# 编辑 config.local.yaml 设置你的配置
```

### 运行

```bash
# 开发模式
go run main.go

# 构建并运行
go build -o family-photo-station
./family-photo-station
```

### Docker 运行

```bash
# 构建镜像
docker build -t family-photo-station-backend .

# 运行容器
docker run -p 8080:8080 -v $(pwd)/data:/root/data family-photo-station-backend
```

## API 文档

### 认证相关

- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/refresh` - 刷新令牌
- `POST /api/auth/logout` - 用户登出

### 用户管理

- `GET /api/users/profile` - 获取用户信息
- `PUT /api/users/profile` - 更新用户信息
- `GET /api/users` - 获取用户列表 (管理员)

### 照片管理

- `POST /api/photos/upload` - 上传照片
- `POST /api/photos/batch-upload` - 批量上传
- `GET /api/photos` - 获取照片列表
- `GET /api/photos/:id` - 获取照片详情
- `DELETE /api/photos/:id` - 删除照片
- `GET /api/photos/search` - 搜索照片

### 相册管理

- `POST /api/albums` - 创建相册
- `GET /api/albums` - 获取相册列表
- `GET /api/albums/:id` - 获取相册详情
- `PUT /api/albums/:id` - 更新相册
- `DELETE /api/albums/:id` - 删除相册

### 同步管理

- `GET /api/sync/status` - 获取同步状态
- `POST /api/sync/trigger` - 触发同步
- `GET /ws/sync` - WebSocket同步连接

## 开发指南

### 添加新的API

1. 在 `internal/model/` 中定义数据模型
2. 在 `internal/service/` 中实现业务逻辑
3. 在 `internal/handler/` 中创建HTTP处理器
4. 在 `main.go` 中注册路由

### 数据库迁移

GORM会自动处理数据库迁移，新的模型会在应用启动时自动创建表结构。

### 配置管理

配置文件支持环境变量覆盖，格式为 `FAMILY_PHOTO_STATION_<SECTION>_<KEY>`，例如：

```bash
export FAMILY_PHOTO_STATION_DATABASE_TYPE=postgres
export FAMILY_PHOTO_STATION_JWT_SECRET=your-secret-key
```

## 部署

### 生产环境配置

1. 使用PostgreSQL作为数据库
2. 配置Redis缓存
3. 设置强密码和JWT密钥
4. 启用HTTPS
5. 配置反向代理 (Nginx)

### Docker Compose

```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      - FAMILY_PHOTO_STATION_DATABASE_TYPE=postgres
      - FAMILY_PHOTO_STATION_DATABASE_HOST=postgres
    depends_on:
      - postgres
      - redis
    volumes:
      - ./data:/root/data

  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: family_photo_station
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## 许可证

MIT License