package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Comment struct {
	ID        uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	PhotoID   uuid.UUID      `json:"photo_id" gorm:"type:char(36);not null;index"`
	UserID    uuid.UUID      `json:"user_id" gorm:"type:char(36);not null;index"`
	Content   string         `json:"content" gorm:"not null;type:text"`
	ParentID  *uuid.UUID     `json:"parent_id" gorm:"type:char(36);index"` // 回复评论的父评论ID
	IsDeleted bool           `json:"is_deleted" gorm:"default:false"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Photo   Photo     `json:"photo,omitempty" gorm:"foreignKey:PhotoID"`
	User    User      `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Parent  *Comment  `json:"parent,omitempty" gorm:"foreignKey:ParentID"`
	Replies []Comment `json:"replies,omitempty" gorm:"foreignKey:ParentID"`
}

func (c *Comment) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return nil
}

type Like struct {
	ID        uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	PhotoID   uuid.UUID      `json:"photo_id" gorm:"type:char(36);not null;index"`
	UserID    uuid.UUID      `json:"user_id" gorm:"type:char(36);not null;index"`
	CreatedAt time.Time      `json:"created_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Photo Photo `json:"photo,omitempty" gorm:"foreignKey:PhotoID"`
	User  User  `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

func (l *Like) BeforeCreate(tx *gorm.DB) error {
	if l.ID == uuid.Nil {
		l.ID = uuid.New()
	}
	return nil
}

type Share struct {
	ID          uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	PhotoID     uuid.UUID      `json:"photo_id" gorm:"type:char(36);not null;index"`
	SharedBy    uuid.UUID      `json:"shared_by" gorm:"type:char(36);not null;index"`
	ShareToken  string         `json:"share_token" gorm:"uniqueIndex;not null;size:64"`
	ShareType   string         `json:"share_type" gorm:"not null;size:20"` // public, private, password
	Password    string         `json:"-" gorm:"size:255"`                  // 分享密码（加密存储）
	ExpiresAt   *time.Time     `json:"expires_at"`
	ViewCount   int            `json:"view_count" gorm:"default:0"`
	IsActive    bool           `json:"is_active" gorm:"default:true"`
	Description string         `json:"description" gorm:"type:text"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Photo        Photo `json:"photo,omitempty" gorm:"foreignKey:PhotoID"`
	SharedByUser User  `json:"shared_by_user,omitempty" gorm:"foreignKey:SharedBy"`
}

func (s *Share) BeforeCreate(tx *gorm.DB) error {
	if s.ID == uuid.Nil {
		s.ID = uuid.New()
	}
	return nil
}
