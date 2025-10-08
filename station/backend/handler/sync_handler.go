package handler

import (
	"context"
	"net/http"

	"github.com/cloudwego/hertz/pkg/app"
)

type SyncHandler struct{}

func NewSyncHandler() *SyncHandler {
	return &SyncHandler{}
}

// GetStatus 获取同步状态
func (h *SyncHandler) GetStatus(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取同步状态成功",
		Data:    nil,
	})
}

// Trigger 触发同步
func (h *SyncHandler) Trigger(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "触发同步成功",
		Data:    nil,
	})
}
