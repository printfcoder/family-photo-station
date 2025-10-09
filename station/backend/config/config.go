package config

import (
    "fmt"
    "strings"

    appLog "github.com/printfcoder/family-photo-station/logger"
    "github.com/spf13/viper"
)

type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	Redis    RedisConfig    `mapstructure:"redis"`
	JWT      JWTConfig      `mapstructure:"jwt"`
	Upload   UploadConfig   `mapstructure:"upload"`
	AI       AIConfig       `mapstructure:"ai"`
}

type ServerConfig struct {
	Address string `mapstructure:"address"`
	Mode    string `mapstructure:"mode"`
}

type DatabaseConfig struct {
	Type            string `mapstructure:"type"`
	Host            string `mapstructure:"host"`
	Port            int    `mapstructure:"port"`
	User            string `mapstructure:"user"`
	Username        string `mapstructure:"username"`
	Password        string `mapstructure:"password"`
	Name            string `mapstructure:"name"`
	Database        string `mapstructure:"database"`
	SSLMode         string `mapstructure:"sslmode"`
	TimeZone        string `mapstructure:"timezone"`
	Path            string `mapstructure:"path"`
	MaxIdleConns    int    `mapstructure:"max_idle_conns"`
	MaxOpenConns    int    `mapstructure:"max_open_conns"`
	ConnMaxLifetime int    `mapstructure:"conn_max_lifetime"`
}

type RedisConfig struct {
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Password string `mapstructure:"password"`
	DB       int    `mapstructure:"db"`
}

type JWTConfig struct {
	Secret             string `mapstructure:"secret"`
	AccessTokenTTL     int    `mapstructure:"access_token_ttl"`
	RefreshTokenTTL    int    `mapstructure:"refresh_token_ttl"`
	AccessTokenExpire  int    `mapstructure:"access_token_ttl"`
	RefreshTokenExpire int    `mapstructure:"refresh_token_ttl"`
}

type UploadConfig struct {
	Path         string   `mapstructure:"path"`
	MaxSize      int64    `mapstructure:"max_size"`
	AllowedTypes []string `mapstructure:"allowed_types"`
}

type AIConfig struct {
	Enabled    bool   `mapstructure:"enabled"`
	ServiceURL string `mapstructure:"service_url"`
}

func Load() *Config {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AddConfigPath("./configs")

	// 设置默认值
	setDefaults()

	// 环境变量支持
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	if err := viper.ReadInConfig(); err != nil {
		appLog.Warnf("Could not read config file: %v", err)
	}

	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		appLog.Fatalf("Failed to unmarshal config: %v", err)
	}

	// 若配置文件使用了 server.host/port，则组合为 Address
	if config.Server.Address == "" {
		host := viper.GetString("server.host")
		port := viper.GetInt("server.port")
		if host != "" && port != 0 {
			config.Server.Address = fmt.Sprintf("%s:%d", host, port)
		}
	}

	return &config
}

func setDefaults() {
	// 服务器配置
	viper.SetDefault("server.address", ":8080")
	viper.SetDefault("server.mode", "debug")

	// 数据库配置
	viper.SetDefault("database.type", "sqlite")
	viper.SetDefault("database.host", "localhost")
	viper.SetDefault("database.port", 5432)
	viper.SetDefault("database.database", "family_photos.db")
	viper.SetDefault("database.ssl_mode", "disable")

	// Redis 配置
	viper.SetDefault("redis.host", "localhost")
	viper.SetDefault("redis.port", 6379)
	viper.SetDefault("redis.db", 0)

	// JWT 配置
	viper.SetDefault("jwt.secret", "your-secret-key-change-in-production")
	viper.SetDefault("jwt.access_token_ttl", 900)     // 15 minutes
	viper.SetDefault("jwt.refresh_token_ttl", 604800) // 7 days

	// 上传配置
	viper.SetDefault("upload.path", "./uploads")
	viper.SetDefault("upload.max_size", 52428800) // 50MB
	viper.SetDefault("upload.allowed_types", []string{
		"image/jpeg", "image/png", "image/heic", "image/tiff", "image/raw",
	})

	// AI 配置
	viper.SetDefault("ai.enabled", false)
	viper.SetDefault("ai.service_url", "http://localhost:5000")
}
