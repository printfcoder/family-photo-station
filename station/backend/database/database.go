package database

import (
    "fmt"
    "os"
    "path/filepath"
    "time"

    "github.com/printfcoder/family-photo-station/config"
    appLog "github.com/printfcoder/family-photo-station/logger"
    model2 "github.com/printfcoder/family-photo-station/model"

	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	gormLogger "gorm.io/gorm/logger"
)

var DB *gorm.DB

func Init(cfg *config.Config) error {
	var err error
	var dialector gorm.Dialector

	appLog.Infof("Initializing database, type=%s", cfg.Database.Type)

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
		appLog.Infof("Connecting to PostgreSQL database user=%s host=%s port=%d db=%s", cfg.Database.User, cfg.Database.Host, cfg.Database.Port, cfg.Database.Name)
		dialector = postgres.Open(dsn)
	case "sqlite":
		// 检查并创建SQLite数据库文件目录
		dbPath := cfg.Database.Path
		dbDir := filepath.Dir(dbPath)

		appLog.Infof("SQLite database path: %s", dbPath)
		appLog.Infof("Checking database directory: %s", dbDir)

		// 检查目录是否存在，不存在则创建
		if _, err := os.Stat(dbDir); os.IsNotExist(err) {
			appLog.Warnf("Database directory does not exist, creating: %s", dbDir)
			if err := os.MkdirAll(dbDir, 0755); err != nil {
				return fmt.Errorf("failed to create database directory %s: %w", dbDir, err)
			}
			appLog.Infof("Database directory created successfully: %s", dbDir)
		} else if err != nil {
			return fmt.Errorf("failed to check database directory %s: %w", dbDir, err)
		} else {
			appLog.Infof("Database directory already exists: %s", dbDir)
		}

		// 主动创建SQLite数据库文件（如果不存在）
		if _, err := os.Stat(dbPath); os.IsNotExist(err) {
			f, createErr := os.Create(dbPath)
			if createErr != nil {
				return fmt.Errorf("failed to create sqlite db file %s: %w", dbPath, createErr)
			}
			_ = f.Close()
			appLog.Infof("SQLite database file created: %s", dbPath)
		}

		dialector = sqlite.Open(dbPath)
	default:
		return fmt.Errorf("unsupported database type: %s", cfg.Database.Type)
	}

	// GORM配置
    gormConfig := &gorm.Config{
        Logger: NewGormLogger().LogMode(gormLogger.Warn),
    }

	// 连接数据库
	appLog.Info("Attempting to connect to database...")
	DB, err = gorm.Open(dialector, gormConfig)
	if err != nil {
		return fmt.Errorf("failed to connect database: %w", err)
	}
	appLog.Info("Database connection established successfully")

	// 获取底层sql.DB对象进行连接池配置
	sqlDB, err := DB.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	// 设置连接池参数
	appLog.Infof("Configuring connection pool max_idle=%d max_open=%d max_lifetime_min=%d", cfg.Database.MaxIdleConns, cfg.Database.MaxOpenConns, cfg.Database.ConnMaxLifetime)
	sqlDB.SetMaxIdleConns(cfg.Database.MaxIdleConns)
	sqlDB.SetMaxOpenConns(cfg.Database.MaxOpenConns)
	sqlDB.SetConnMaxLifetime(time.Duration(cfg.Database.ConnMaxLifetime) * time.Minute)

	// 自动迁移数据库表
	appLog.Info("Starting database migration...")
	if err := autoMigrate(); err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}
	appLog.Info("Database migration completed successfully")

	// 初始化默认数据
	appLog.Info("Initializing default data...")
	if err := initDefaultData(); err != nil {
		return fmt.Errorf("failed to init default data: %w", err)
	}
	appLog.Info("Default data initialization completed")

	appLog.Info("Database connected and migrated successfully")
	return nil
}

func autoMigrate() error {
	return DB.AutoMigrate(
		&model2.User{},
		&model2.Device{},
		&model2.Photo{},
		&model2.Album{},
		&model2.AlbumPhoto{},
		&model2.Tag{},
		&model2.PhotoTag{},
		&model2.Person{},
		&model2.Face{},
		&model2.Comment{},
		&model2.Like{},
		&model2.Share{},
		&model2.SyncRecord{},
		&model2.SystemConfig{},
		&model2.UploadSession{},
	)
}

func initDefaultData() error {
	// 检查是否已经初始化过
	var count int64
	if err := DB.Model(&model2.SystemConfig{}).Count(&count).Error; err != nil {
		return err
	}

	if count > 0 {
		return nil // 已经初始化过
	}

	// 创建默认系统配置
	defaultConfigs := []model2.SystemConfig{
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

	appLog.Info("Default system configurations created")
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
