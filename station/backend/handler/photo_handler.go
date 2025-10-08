package handler

import (
	"context"
	"net/http"

	"github.com/cloudwego/hertz/pkg/app"
)

type PhotoHandler struct{}

func NewPhotoHandler() *PhotoHandler {
	return &PhotoHandler{}
}

// Upload 上传照片
func (h *PhotoHandler) Upload(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "上传照片成功",
		Data:    nil,
	})
}

// BatchUpload 批量上传照片
func (h *PhotoHandler) BatchUpload(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "批量上传照片成功",
		Data:    nil,
	})
}

// List 获取照片列表
func (h *PhotoHandler) List(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取照片列表成功",
		Data:    nil,
	})
}

// GetByID 根据ID获取照片
func (h *PhotoHandler) GetByID(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "获取照片成功",
		Data:    nil,
	})
}

// Delete 删除照片
func (h *PhotoHandler) Delete(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "删除照片成功",
		Data:    nil,
	})
}

// Search 搜索照片
func (h *PhotoHandler) Search(ctx context.Context, c *app.RequestContext) {
	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "搜索照片成功",
		Data:    nil,
	})
}
