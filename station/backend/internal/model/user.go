package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Username    string         `json:"username" gorm:"uniqueIndex;not null;size:50"`
	Email       string         `json:"email" gorm:"uniqueIndex;size:100"`
	PasswordHash string        `json:"-" gorm:"not null;size:255"`
	Salt        string         `json:"-" gorm:"not null;size:32"`
	Role        string         `json:"role" gorm:"default:member;size:20"`
	AvatarURL   string         `json:"avatar_url" gorm:"size:500"`
	IsActive    bool           `json:"is_active" gorm:"default:true"`
	LastLoginAt *time.Time     `json:"last_login_at"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Photos  []Photo  `json:"photos,omitempty" gorm:"foreignKey:UploadedBy"`
	Albums  []Album  `json:"albums,omitempty" gorm:"foreignKey:CreatedBy"`
	Devices []Device `json:"devices,omitempty" gorm:"foreignKey:UserID"`
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}

type Device struct {
	ID         uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	UserID     uuid.UUID      `json:"user_id" gorm:"type:uuid;not null;index"`
	DeviceID   string         `json:"device_id" gorm:"uniqueIndex;not null;size:100"`
	DeviceName string         `json:"device_name" gorm:"not null;size:100"`
	DeviceType string         `json:"device_type" gorm:"not null;size:20"` // mobile, desktop, web
	OSType     string         `json:"os_type" gorm:"size:20"`              // ios, android, windows, macos, linux
	OSVersion  string         `json:"os_version" gorm:"size:50"`
	AppVersion string         `json:"app_version" gorm:"size:20"`
	LastSyncAt *time.Time     `json:"last_sync_at"`
	IsActive   bool           `json:"is_active" gorm:"default:true"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	User User `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

func (d *Device) BeforeCreate(tx *gorm.DB) error {
	if d.ID == uuid.Nil {
		d.ID = uuid.New()
	}
	return nil
}