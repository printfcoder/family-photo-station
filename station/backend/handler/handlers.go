package handler

import (
	"github.com/printfcoder/family-photo-station/service"
)

// Handlers 包含所有处理器的结构体
type Handlers struct {
	Auth      *AuthHandler
	Health    *HealthHandler
	User      *UserHandler
	Photo     *PhotoHandler
	Album     *AlbumHandler
	Sync      *SyncHandler
	WebSocket *WebSocketHandler
}

// NewHandlers 创建新的处理器实例
func NewHandlers(services *service.Services) *Handlers {
	return &Handlers{
		Auth:      NewAuthHandler(services.Auth),
		Health:    NewHealthHandler(),
		User:      NewUserHandler(),
		Photo:     NewPhotoHandler(),
		Album:     NewAlbumHandler(),
		Sync:      NewSyncHandler(),
		WebSocket: NewWebSocketHandler(),
	}
}
