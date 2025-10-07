package database

import (
	"fmt"
	"log"
	"time"

	"family-photo-station/internal/config"
	"family-photo-station/internal/model"

	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func Init(cfg *config.Config) error {
	var err error
	var dialector gorm.Dialector

	// 根据配置选择数据库驱动
	switch cfg.Database.Type {
	case "postgres":
		dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=%s TimeZone=%s",
			cfg.Database.Host,
			cfg.Database.User,
			cfg.Database.Password,
			cfg.Database.Name,
			cfg.Database.Port,
			cfg.Database.SSLMode,
			cfg.Database.TimeZone,
		)
		dialector = postgres.Open(dsn)
	case "sqlite":
		dialector = sqlite.Open(cfg.Database.Path)
	default:
		return fmt.Errorf("unsupported database type: %s", cfg.Database.Type)
	}

	// GORM配置
	gormConfig := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	}

	// 连接数据库
	DB, err = gorm.Open(dialector, gormConfig)
	if err != nil {
		return fmt.Errorf("failed to connect database: %w", err)
	}

	// 获取底层sql.DB对象进行连接池配置
	sqlDB, err := DB.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(cfg.Database.MaxIdleConns)
	sqlDB.SetMaxOpenConns(cfg.Database.MaxOpenConns)
	sqlDB.SetConnMaxLifetime(time.Duration(cfg.Database.ConnMaxLifetime) * time.Minute)

	// 自动迁移数据库表
	if err := autoMigrate(); err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	// 初始化默认数据
	if err := initDefaultData(); err != nil {
		return fmt.Errorf("failed to init default data: %w", err)
	}

	log.Println("Database connected and migrated successfully")
	return nil
}

func autoMigrate() error {
	return DB.AutoMigrate(
		&model.User{},
		&model.Device{},
		&model.Photo{},
		&model.Album{},
		&model.AlbumPhoto{},
		&model.Tag{},
		&model.PhotoTag{},
		&model.Person{},
		&model.Face{},
		&model.Comment{},
		&model.Like{},
		&model.Share{},
		&model.SyncRecord{},
		&model.SystemConfig{},
		&model.UploadSession{},
	)
}

func initDefaultData() error {
	// 检查是否已经初始化过
	var count int64
	if err := DB.Model(&model.SystemConfig{}).Count(&count).Error; err != nil {
		return err
	}

	if count > 0 {
		return nil // 已经初始化过
	}

	// 创建默认系统配置
	defaultConfigs := []model.SystemConfig{
		{
			Key:         "system.version",
			Value:       "1.0.0",
			Description: "系统版本号",
			Category:    "system",
			IsPublic:    true,
		},
		{
			Key:         "upload.max_file_size",
			Value:       "50MB",
			Description: "单个文件最大上传大小",
			Category:    "upload",
			IsPublic:    true,
		},
		{
			Key:         "upload.allowed_types",
			Value:       "jpg,jpeg,png,gif,bmp,webp,tiff,raw,heic",
			Description: "允许上传的文件类型",
			Category:    "upload",
			IsPublic:    true,
		},
		{
			Key:         "ai.face_detection_enabled",
			Value:       "true",
			Description: "是否启用人脸检测",
			Category:    "ai",
			IsPublic:    true,
		},
		{
			Key:         "ai.auto_tagging_enabled",
			Value:       "true",
			Description: "是否启用自动标签",
			Category:    "ai",
			IsPublic:    true,
		},
		{
			Key:         "storage.thumbnail_quality",
			Value:       "80",
			Description: "缩略图质量(1-100)",
			Category:    "storage",
			IsPublic:    true,
		},
		{
			Key:         "storage.thumbnail_sizes",
			Value:       "150x150,300x300,800x600",
			Description: "缩略图尺寸",
			Category:    "storage",
			IsPublic:    true,
		},
	}

	for _, config := range defaultConfigs {
		if err := DB.Create(&config).Error; err != nil {
			return err
		}
	}

	log.Println("Default system configurations created")
	return nil
}

func Close() error {
	if DB != nil {
		sqlDB, err := DB.DB()
		if err != nil {
			return err
		}
		return sqlDB.Close()
	}
	return nil
}