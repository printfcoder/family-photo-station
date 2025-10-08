package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/common/hlog"
	"github.com/printfcoder/family-photo-station/handler"
)

// JWTAuth JWT认证中间件
func JWTAuth() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		// 获取Authorization头
		authHeader := string(c.GetHeader("Authorization"))
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, handler.Response{
				Code:    401,
				Message: "缺少认证令牌",
				Data:    nil,
			})
			c.Abort()
			return
		}

		// 检查Bearer前缀
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, handler.Response{
				Code:    401,
				Message: "认证令牌格式错误",
				Data:    nil,
			})
			c.Abort()
			return
		}

		// 提取token
		token := strings.TrimPrefix(authHeader, "Bearer ")
		if token == "" {
			c.JSON(http.StatusUnauthorized, handler.Response{
				Code:    401,
				Message: "认证令牌为空",
				Data:    nil,
			})
			c.Abort()
			return
		}

		// TODO: 实际的token验证逻辑
		// 这里暂时跳过验证，后续需要实现完整的JWT验证
		hlog.Infof("JWT token received: %s", token)

		// 继续处理请求
		c.Next(ctx)
	}
}

// CORS CORS中间件
func CORS() app.HandlerFunc {
	return CORSMiddleware()
}

// Logger 日志中间件
func Logger() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		hlog.Infof("Request: %s %s", c.Method(), c.URI().String())
		c.Next(ctx)
	}
}

// Recovery 恢复中间件
func Recovery() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		defer func() {
			if err := recover(); err != nil {
				hlog.Errorf("Panic recovered: %v", err)
				c.JSON(http.StatusInternalServerError, handler.Response{
					Code:    500,
					Message: "服务器内部错误",
					Data:    nil,
				})
				c.Abort()
			}
		}()
		c.Next(ctx)
	}
}
