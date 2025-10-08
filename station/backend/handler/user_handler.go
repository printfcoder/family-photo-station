package handler

import (
	"context"
	"net/http"

	"github.com/cloudwego/hertz/pkg/app"
)

type UserHandler struct{}

func NewUserHandler() *UserHandler {
	return &UserHandler{}
}

// GetProfile 获取用户资料
func (h *UserHandler) GetProfile(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取用户资料成功",
		Data:    nil,
	})
}

// UpdateProfile 更新用户资料
func (h *UserHandler) UpdateProfile(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "更新用户资料成功",
		Data:    nil,
	})
}

// ListUsers 获取用户列表
func (h *UserHandler) ListUsers(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取用户列表成功",
		Data:    nil,
	})
}
