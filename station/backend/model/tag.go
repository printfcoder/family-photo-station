package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Tag struct {
	ID          uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	Name        string         `json:"name" gorm:"uniqueIndex;not null;size:50"`
	Description string         `json:"description" gorm:"type:text"`
	Color       string         `json:"color" gorm:"size:7"` // hex color
	IsSystem    bool           `json:"is_system" gorm:"default:false"`
	CreatedBy   *uuid.UUID     `json:"created_by" gorm:"type:char(36)"`
	UsageCount  int            `json:"usage_count" gorm:"default:0"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	CreatedByUser *User      `json:"created_by_user,omitempty" gorm:"foreignKey:CreatedBy"`
	PhotoTags     []PhotoTag `json:"photo_tags,omitempty" gorm:"foreignKey:TagID"`
}

func (t *Tag) BeforeCreate(tx *gorm.DB) error {
	if t.ID == uuid.Nil {
		t.ID = uuid.New()
	}
	return nil
}

type PhotoTag struct {
	ID         uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	PhotoID    uuid.UUID      `json:"photo_id" gorm:"type:char(36);not null;index"`
	TagID      uuid.UUID      `json:"tag_id" gorm:"type:char(36);not null;index"`
	AddedBy    *uuid.UUID     `json:"added_by" gorm:"type:char(36)"`
	IsAI       bool           `json:"is_ai" gorm:"default:false"`          // AI自动标记还是用户手动标记
	Confidence *float64       `json:"confidence" gorm:"type:decimal(3,2)"` // AI标记的置信度
	CreatedAt  time.Time      `json:"created_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Photo       Photo `json:"photo,omitempty" gorm:"foreignKey:PhotoID"`
	Tag         Tag   `json:"tag,omitempty" gorm:"foreignKey:TagID"`
	AddedByUser *User `json:"added_by_user,omitempty" gorm:"foreignKey:AddedBy"`
}

func (pt *PhotoTag) BeforeCreate(tx *gorm.DB) error {
	if pt.ID == uuid.Nil {
		pt.ID = uuid.New()
	}
	return nil
}

type Person struct {
	ID          uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	Name        string         `json:"name" gorm:"not null;size:100;index"`
	AvatarURL   string         `json:"avatar_url" gorm:"size:500"`
	Description string         `json:"description" gorm:"type:text"`
	CreatedBy   *uuid.UUID     `json:"created_by" gorm:"type:char(36)"`
	FaceCount   int            `json:"face_count" gorm:"default:0"`
	IsConfirmed bool           `json:"is_confirmed" gorm:"default:false"` // 是否已确认身份
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	CreatedByUser *User  `json:"created_by_user,omitempty" gorm:"foreignKey:CreatedBy"`
	Faces         []Face `json:"faces,omitempty" gorm:"foreignKey:PersonID"`
}

func (p *Person) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}

type Face struct {
	ID          uuid.UUID      `json:"id" gorm:"type:char(36);primary_key"`
	PhotoID     uuid.UUID      `json:"photo_id" gorm:"type:char(36);not null;index"`
	PersonID    *uuid.UUID     `json:"person_id" gorm:"type:char(36);index"`
	BoundingBox string         `json:"bounding_box" gorm:"not null;type:text"` // JSON格式存储边界框坐标
	Confidence  float64        `json:"confidence" gorm:"type:decimal(5,4)"`    // 人脸检测置信度
	Encoding    []byte         `json:"-" gorm:"type:bytea"`                    // 人脸编码向量
	IsConfirmed bool           `json:"is_confirmed" gorm:"default:false"`      // 是否已确认身份
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Photo  Photo   `json:"photo,omitempty" gorm:"foreignKey:PhotoID"`
	Person *Person `json:"person,omitempty" gorm:"foreignKey:PersonID"`
}

func (f *Face) BeforeCreate(tx *gorm.DB) error {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}
	return nil
}
