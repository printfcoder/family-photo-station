package middleware

import (
	"context"

	"github.com/cloudwego/hertz/pkg/app"
)

func CORSMiddleware() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		method := string(c.Method())
		origin := string(c.GetHeader("Origin"))

		// 设置CORS头
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Content-Type")
		c.Header("Access-Control-Allow-Credentials", "true")

		// 处理预检请求
		if method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		// 记录请求来源
		if origin != "" {
			c.Header("Access-Control-Allow-Origin", origin)
		}

		c.Next(ctx)
	}
}
