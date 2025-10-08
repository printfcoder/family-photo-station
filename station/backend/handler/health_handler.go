package handler

import (
	"context"
	"net/http"

	"github.com/cloudwego/hertz/pkg/app"
)

type HealthHandler struct{}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

// Check 健康检查
func (h *HealthHandler) Check(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "服务正常",
		Data:    map[string]string{"status": "healthy"},
	})
}
