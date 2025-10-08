package handler

import (
	"context"
	"net/http"

	"github.com/cloudwego/hertz/pkg/app"
)

type AlbumHandler struct{}

func NewAlbumHandler() *AlbumHandler {
	return &AlbumHandler{}
}

// Create 创建相册
func (h *AlbumHandler) Create(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "创建相册成功",
		Data:    nil,
	})
}

// List 获取相册列表
func (h *AlbumHandler) List(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取相册列表成功",
		Data:    nil,
	})
}

// GetByID 根据ID获取相册
func (h *AlbumHandler) GetByID(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取相册成功",
		Data:    nil,
	})
}

// Update 更新相册
func (h *AlbumHandler) Update(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "更新相册成功",
		Data:    nil,
	})
}

// Delete 删除相册
func (h *AlbumHandler) Delete(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "删除相册成功",
		Data:    nil,
	})
}

// AddPhotos 向相册添加照片
func (h *AlbumHandler) AddPhotos(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "添加照片到相册成功",
		Data:    nil,
	})
}

// RemovePhotos 从相册移除照片
func (h *AlbumHandler) RemovePhotos(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "从相册移除照片成功",
		Data:    nil,
	})
}
