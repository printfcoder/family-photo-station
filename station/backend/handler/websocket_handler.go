package handler

import (
	"context"
	"net/http"

	"github.com/cloudwego/hertz/pkg/app"
)

type WebSocketHandler struct{}

func NewWebSocketHandler() *WebSocketHandler {
	return &WebSocketHandler{}
}

// HandleSync 处理同步WebSocket连接
func (h *WebSocketHandler) HandleSync(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "WebSocket连接处理成功",
		Data:    nil,
	})
}
