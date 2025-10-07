package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SyncRecord struct {
	ID           uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	DeviceID     uuid.UUID      `json:"device_id" gorm:"type:uuid;not null;index"`
	SyncType     string         `json:"sync_type" gorm:"not null;size:20"` // upload, download, full
	Status       string         `json:"status" gorm:"not null;size:20"`    // pending, running, completed, failed
	TotalFiles   int            `json:"total_files" gorm:"default:0"`
	ProcessedFiles int          `json:"processed_files" gorm:"default:0"`
	FailedFiles  int            `json:"failed_files" gorm:"default:0"`
	TotalSize    int64          `json:"total_size" gorm:"default:0"`
	ProcessedSize int64         `json:"processed_size" gorm:"default:0"`
	ErrorMessage string         `json:"error_message" gorm:"type:text"`
	StartedAt    *time.Time     `json:"started_at"`
	CompletedAt  *time.Time     `json:"completed_at"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Device Device `json:"device,omitempty" gorm:"foreignKey:DeviceID"`
}

func (sr *SyncRecord) BeforeCreate(tx *gorm.DB) error {
	if sr.ID == uuid.Nil {
		sr.ID = uuid.New()
	}
	return nil
}

type SystemConfig struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Key         string         `json:"key" gorm:"uniqueIndex;not null;size:100"`
	Value       string         `json:"value" gorm:"type:text"`
	Description string         `json:"description" gorm:"type:text"`
	Category    string         `json:"category" gorm:"not null;size:50;index"`
	IsPublic    bool           `json:"is_public" gorm:"default:false"` // 是否可以通过API获取
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

func (sc *SystemConfig) BeforeCreate(tx *gorm.DB) error {
	if sc.ID == uuid.Nil {
		sc.ID = uuid.New()
	}
	return nil
}

// 上传会话，用于批量上传时跟踪进度
type UploadSession struct {
	ID            uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	UserID        uuid.UUID      `json:"user_id" gorm:"type:uuid;not null;index"`
	DeviceID      *uuid.UUID     `json:"device_id" gorm:"type:uuid;index"`
	SessionToken  string         `json:"session_token" gorm:"uniqueIndex;not null;size:64"`
	TotalFiles    int            `json:"total_files" gorm:"default:0"`
	UploadedFiles int            `json:"uploaded_files" gorm:"default:0"`
	FailedFiles   int            `json:"failed_files" gorm:"default:0"`
	TotalSize     int64          `json:"total_size" gorm:"default:0"`
	UploadedSize  int64          `json:"uploaded_size" gorm:"default:0"`
	Status        string         `json:"status" gorm:"not null;size:20"` // pending, uploading, completed, failed
	ErrorMessage  string         `json:"error_message" gorm:"type:text"`
	ExpiresAt     time.Time      `json:"expires_at"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	User   User    `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Device *Device `json:"device,omitempty" gorm:"foreignKey:DeviceID"`
	Photos []Photo `json:"photos,omitempty" gorm:"foreignKey:UploadSessionID"`
}

func (us *UploadSession) BeforeCreate(tx *gorm.DB) error {
	if us.ID == uuid.Nil {
		us.ID = uuid.New()
	}
	return nil
}