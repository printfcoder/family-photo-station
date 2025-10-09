package middleware

import (
    "context"
    "net/http"
    "strings"

    "github.com/printfcoder/family-photo-station/handler"
    appLog "github.com/printfcoder/family-photo-station/logger"
    "github.com/printfcoder/family-photo-station/service"

    "github.com/cloudwego/hertz/pkg/app"
)

func AuthMiddleware(authService *service.AuthService) app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		// 获取Authorization头
		authHeader := string(c.GetHeader("Authorization"))
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, handler.ErrorResponse(401, "缺少认证令牌", nil))
			c.Abort()
			return
		}

		// 检查Bearer前缀
		if !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, handler.ErrorResponse(401, "认证令牌格式错误", nil))
			c.Abort()
			return
		}

		// 提取token
		token := strings.TrimPrefix(authHeader, "Bearer ")
		if token == "" {
			c.JSON(http.StatusUnauthorized, handler.ErrorResponse(401, "认证令牌为空", nil))
			c.Abort()
			return
		}

		// 验证token
		claims, err := authService.ValidateToken(token)
		if err != nil {
			appLog.Errorf("Token validation failed: %v", err)
			c.JSON(http.StatusUnauthorized, handler.ErrorResponse(401, "认证令牌无效", err))
			c.Abort()
			return
		}

		// 将用户信息存储到上下文中
		c.Set("user_id", claims.UserID)
		c.Set("username", claims.Username)
		c.Set("user_role", claims.Role)

		c.Next(ctx)
	}
}

// OptionalAuthMiddleware 可选认证中间件，不强制要求认证
func OptionalAuthMiddleware(authService *service.AuthService) app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		authHeader := string(c.GetHeader("Authorization"))
		if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
			token := strings.TrimPrefix(authHeader, "Bearer ")
			if token != "" {
				if claims, err := authService.ValidateToken(token); err == nil {
					c.Set("user_id", claims.UserID)
					c.Set("username", claims.Username)
					c.Set("user_role", claims.Role)
				}
			}
		}
		c.Next(ctx)
	}
}

// AdminMiddleware 管理员权限中间件
func AdminMiddleware() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		role, exists := c.Get("user_role")
		if !exists {
			c.JSON(http.StatusUnauthorized, handler.ErrorResponse(401, "未授权", nil))
			c.Abort()
			return
		}

		if role != "admin" {
			c.JSON(http.StatusForbidden, handler.ErrorResponse(403, "权限不足", nil))
			c.Abort()
			return
		}

		c.Next(ctx)
	}
}
