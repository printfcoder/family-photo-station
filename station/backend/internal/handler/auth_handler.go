package handler

import (
	"context"
	"net/http"

	"family-photo-station/internal/service"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/common/hlog"
)

type AuthHandler struct {
	authService *service.AuthService
}

func NewAuthHandler(authService *service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// Register 用户注册
func (h *AuthHandler) Register(ctx context.Context, c *app.RequestContext) {
	var req service.RegisterRequest
	if err := c.BindAndValidate(&req); err != nil {
		c.JSON(http.StatusBadRequest, Response{
			Code:    400,
			Message: "请求参数错误",
			Data:    nil,
			Error:   err.Error(),
		})
		return
	}

	user, err := h.authService.Register(&req)
	if err != nil {
		hlog.Errorf("Register failed: %v", err)
		c.JSON(http.StatusBadRequest, Response{
			Code:    400,
			Message: "注册失败",
			Data:    nil,
			Error:   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "注册成功",
		Data:    user,
	})
}

// Login 用户登录
func (h *AuthHandler) Login(ctx context.Context, c *app.RequestContext) {
	var req service.LoginRequest
	if err := c.BindAndValidate(&req); err != nil {
		c.JSON(http.StatusBadRequest, Response{
			Code:    400,
			Message: "请求参数错误",
			Data:    nil,
			Error:   err.Error(),
		})
		return
	}

	tokenResponse, err := h.authService.Login(&req)
	if err != nil {
		hlog.Errorf("Login failed: %v", err)
		c.JSON(http.StatusUnauthorized, Response{
			Code:    401,
			Message: "登录失败",
			Data:    nil,
			Error:   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "登录成功",
		Data:    tokenResponse,
	})
}

// RefreshToken 刷新令牌
func (h *AuthHandler) RefreshToken(ctx context.Context, c *app.RequestContext) {
	type RefreshRequest struct {
		RefreshToken string `json:"refresh_token" binding:"required"`
	}

	var req RefreshRequest
	if err := c.BindAndValidate(&req); err != nil {
		c.JSON(http.StatusBadRequest, Response{
			Code:    400,
			Message: "请求参数错误",
			Data:    nil,
			Error:   err.Error(),
		})
		return
	}

	tokenResponse, err := h.authService.RefreshToken(req.RefreshToken)
	if err != nil {
		hlog.Errorf("RefreshToken failed: %v", err)
		c.JSON(http.StatusUnauthorized, Response{
			Code:    401,
			Message: "刷新令牌失败",
			Data:    nil,
			Error:   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "刷新令牌成功",
		Data:    tokenResponse,
	})
}

// Logout 用户登出
func (h *AuthHandler) Logout(ctx context.Context, c *app.RequestContext) {
	// 从上下文中获取用户信息
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, Response{
			Code:    401,
			Message: "未授权",
			Data:    nil,
		})
		return
	}

	hlog.Infof("User %v logged out", userID)

	c.JSON(http.StatusOK, Response{
		Code:    200,
		Message: "登出成功",
		Data:    nil,
	})
}