package service

import (
	"github.com/printfcoder/family-photo-station/config"
	"gorm.io/gorm"
)

// Services 包含所有服务的结构体
type Services struct {
	Auth *AuthService
}

// NewServices 创建新的服务实例
func NewServices(db *gorm.DB, cfg *config.Config) *Services {
	return &Services{
		Auth: NewAuthService(cfg),
	}
}
