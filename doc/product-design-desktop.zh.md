# 桌面端产品设计

## UI 风格

简洁风：https://dribbble.com/shots/25512715-AI-text-to-image-generator-dashboard
家庭幼儿奶油风： https://dribbble.com/shots/26450677-Kidory-Audiobook-Mobile-App-Exploration
免费png转svg：https://www.adobe.com/cn/express/feature/image/convert/png-to-svg

## 初始化流程设计

### 启动检测阶段

#### 用户状态判断

- 已有用户：直接进入登录界面
- 无用户：进入管理员创建流程

- 管理员其它字段：头像等其它重要但是非必填的，用户可以在桌面端创建后再进行设置

## 用户相关

### 管理员

- 创建管理员：用户名、密码、确认密码
- 在桌面端只用创建管理员，其他用户不需要手动在桌面端创建，而是通过家庭成员的手机安装的mobile端扫码来注册
- 管理员只能通过当前运行程序的电脑修改所有人密码(方式还需要再定，在安全相关里完成)
- 支持普通成员扫码绑定为管理员
- 当没有普通用户时，提醒管理员注册为普通用户绑定为管理员，并提供注册与绑定的二维码

### 普通家庭成员用户

- 家庭成员通过手机安装的mobile端扫码注册
- 暂不通过管理员新增用户，没有意义
- 在mobile注册时需要输入用户名+密码即可

### 用户登录

- 登录桌面端则使用扫码登录，普通用户与管理员都一样
- 如果是管理员，则页面上选择登录管理员或者登录普通用户
- 设备不在身边无法扫码，则可使用密码登录
- 对于所有非管理账户找回密码，让管理员重置

### 切换管理员

- 普通用户退出，重新登录管理员即可。

### 登录后检测

#### 存储检查

- 主要检查存储容易是否够用，是否连接正常

## 设置

### 通用设置

- 语言设置
  - 支持英文与中文
- 主题设置
  - 支持白天与夜间切换

### 应用数据存储

#### 数据库目录

- Windows : %APPDATA%\FamilyPhotoStation\database\family_photo_station.db
- macOS : ~/Library/Application Support/FamilyPhotoStation/database/family_photo_station.db
- Linux : ~/.local/share/FamilyPhotoStation/database/family_photo_station.db

#### 配置存储

- 建不同的表用于存储不同的业务

### 照片存储设置

- 元数据存储
  - 存储照片的元数据，在SQLite中
- 存储位置
  - 支持选择本地协议存储目录
  - 支持SMB协议指定网络存储
  - 需要验证每个存储位置的可用性

## 安全相关

- 安装后，当前设备id要以某种方式保存，用于重置用户密码的授权

## 预览模式
- 无需后端连接的演示模式
- 使用本地示例数据展示所有功能
- 明确标识"演示模式"，所有写操作禁用
- 可随时退出预览，返回正常初始化流程
