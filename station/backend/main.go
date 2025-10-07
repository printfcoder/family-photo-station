package main

import (
	"context"
	"family-photo-station/internal/config"
	"family-photo-station/internal/database"
	"family-photo-station/internal/handler"
	"family-photo-station/internal/middleware"
	"family-photo-station/internal/service"
	"log"

	"github.com/cloudwego/hertz/pkg/app/server"
	"github.com/cloudwego/hertz/pkg/common/hlog"
)

func main() {
	// 加载配置
	cfg := config.Load()

	// 初始化数据库
	db, err := database.Init(cfg)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	// 初始化服务层
	services := service.NewServices(db, cfg)

	// 初始化处理器
	handlers := handler.NewHandlers(services)

	// 创建 Hertz 服务器
	h := server.Default(
		server.WithHostPorts(cfg.Server.Address),
	)

	// 注册中间件
	h.Use(middleware.CORS())
	h.Use(middleware.Logger())
	h.Use(middleware.Recovery())

	// 注册路由
	registerRoutes(h, handlers)

	hlog.Infof("Server starting on %s", cfg.Server.Address)
	h.Spin()
}

func registerRoutes(h *server.Hertz, handlers *handler.Handlers) {
	// API 路由组
	api := h.Group("/api/v1")

	// 健康检查
	api.GET("/health", handlers.Health.Check)

	// 认证相关
	auth := api.Group("/auth")
	{
		auth.POST("/register", handlers.Auth.Register)
		auth.POST("/login", handlers.Auth.Login)
		auth.POST("/refresh", handlers.Auth.RefreshToken)
		auth.POST("/logout", handlers.Auth.Logout)
	}

	// 需要认证的路由
	protected := api.Group("/")
	protected.Use(middleware.JWTAuth())
	{
		// 用户相关
		users := protected.Group("/users")
		{
			users.GET("/profile", handlers.User.GetProfile)
			users.PUT("/profile", handlers.User.UpdateProfile)
			users.GET("/", handlers.User.ListUsers)
		}

		// 照片相关
		photos := protected.Group("/photos")
		{
			photos.POST("/upload", handlers.Photo.Upload)
			photos.POST("/batch-upload", handlers.Photo.BatchUpload)
			photos.GET("/", handlers.Photo.List)
			photos.GET("/:id", handlers.Photo.GetByID)
			photos.DELETE("/:id", handlers.Photo.Delete)
			photos.GET("/search", handlers.Photo.Search)
		}

		// 相册相关
		albums := protected.Group("/albums")
		{
			albums.POST("/", handlers.Album.Create)
			albums.GET("/", handlers.Album.List)
			albums.GET("/:id", handlers.Album.GetByID)
			albums.PUT("/:id", handlers.Album.Update)
			albums.DELETE("/:id", handlers.Album.Delete)
			albums.POST("/:id/photos", handlers.Album.AddPhotos)
			albums.DELETE("/:id/photos", handlers.Album.RemovePhotos)
		}

		// 同步相关
		sync := protected.Group("/sync")
		{
			sync.GET("/status", handlers.Sync.GetStatus)
			sync.POST("/trigger", handlers.Sync.Trigger)
		}
	}

	// WebSocket 路由
	h.GET("/ws/sync", handlers.WebSocket.HandleSync)
}