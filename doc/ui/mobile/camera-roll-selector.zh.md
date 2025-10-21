# Camera Roll Selector 相册选择器（手机端）

页面概述
- 选择本机媒体加入上传队列。

里程碑与协同
- M3（同步）

路由与模块路径
- 路由：/selector
- 模块路径：mobile/lib/sync 或 mobile/lib/selector（建议新建）

角色与权限
- 普通用户

功能列表
- 浏览本机相册与照片
- 多选加入队列

UI结构与元素位置
- Header：筛选/排序
- Grid：缩略图网格与选中标记
- Footer：加入队列按钮

交互与流程
- 选择 → 加入队列 → 跳转 Upload Manager

状态与空态
- 无权限：引导开启读取权限

错误与提示
- 读取失败提示

指标与验收
- 选择与加入成功率

关联文档与代码
- M3 文档