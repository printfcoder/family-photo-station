package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Photo struct {
	ID               uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Filename         string         `json:"filename" gorm:"not null;size:255"`
	OriginalFilename string         `json:"original_filename" gorm:"not null;size:255"`
	FilePath         string         `json:"file_path" gorm:"not null;size:500"`
	FileSize         int64          `json:"file_size" gorm:"not null"`
	FileHash         string         `json:"file_hash" gorm:"uniqueIndex;not null;size:64"`
	MimeType         string         `json:"mime_type" gorm:"not null;size:50"`
	Width            int            `json:"width"`
	Height           int            `json:"height"`

	// 缩略图信息
	ThumbnailPath string `json:"thumbnail_path" gorm:"size:500"`
	ThumbnailSize int64  `json:"thumbnail_size"`

	// 拍摄信息
	TakenAt      *time.Time `json:"taken_at" gorm:"index"`
	CameraMake   string     `json:"camera_make" gorm:"size:50"`
	CameraModel  string     `json:"camera_model" gorm:"size:50"`
	LensModel    string     `json:"lens_model" gorm:"size:100"`
	ISO          int        `json:"iso"`
	Aperture     string     `json:"aperture" gorm:"size:10"`
	ShutterSpeed string     `json:"shutter_speed" gorm:"size:20"`
	FocalLength  string     `json:"focal_length" gorm:"size:20"`

	// 位置信息
	Latitude  *float64 `json:"latitude" gorm:"type:decimal(10,8)"`
	Longitude *float64 `json:"longitude" gorm:"type:decimal(11,8)"`
	Address   string   `json:"address" gorm:"type:text"`

	// 上传信息
	UploadedBy      uuid.UUID  `json:"uploaded_by" gorm:"type:uuid;not null;index"`
	UploadedFrom    *uuid.UUID `json:"uploaded_from" gorm:"type:uuid;index"`
	UploadSessionID *uuid.UUID `json:"upload_session_id" gorm:"type:uuid"`

	// AI分析结果
	AIProcessed  bool     `json:"ai_processed" gorm:"default:false"`
	AITags       []string `json:"ai_tags" gorm:"type:text[]"`
	QualityScore *float64 `json:"quality_score" gorm:"type:decimal(3,2)"`

	// 状态
	IsDeleted bool       `json:"is_deleted" gorm:"default:false;index"`
	DeletedAt *time.Time `json:"deleted_at"`

	CreatedAt time.Time      `json:"created_at" gorm:"index"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedGorm gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	UploadedByUser User         `json:"uploaded_by_user,omitempty" gorm:"foreignKey:UploadedBy"`
	UploadedDevice *Device      `json:"uploaded_device,omitempty" gorm:"foreignKey:UploadedFrom"`
	AlbumPhotos    []AlbumPhoto `json:"album_photos,omitempty" gorm:"foreignKey:PhotoID"`
	PhotoTags      []PhotoTag   `json:"photo_tags,omitempty" gorm:"foreignKey:PhotoID"`
	Faces          []Face       `json:"faces,omitempty" gorm:"foreignKey:PhotoID"`
	Comments       []Comment    `json:"comments,omitempty" gorm:"foreignKey:PhotoID"`
	Likes          []Like       `json:"likes,omitempty" gorm:"foreignKey:PhotoID"`
}

func (p *Photo) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}

type Album struct {
	ID          uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	Name        string         `json:"name" gorm:"not null;size:100;index"`
	Description string         `json:"description" gorm:"type:text"`
	CreatedBy   uuid.UUID      `json:"created_by" gorm:"type:uuid;not null;index"`
	IsShared    bool           `json:"is_shared" gorm:"default:false;index"`
	IsSystem    bool           `json:"is_system" gorm:"default:false"`
	CoverPhotoID *uuid.UUID    `json:"cover_photo_id" gorm:"type:uuid"`
	PhotoCount  int            `json:"photo_count" gorm:"default:0"`
	TotalSize   int64          `json:"total_size" gorm:"default:0"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	CreatedByUser User         `json:"created_by_user,omitempty" gorm:"foreignKey:CreatedBy"`
	CoverPhoto    *Photo       `json:"cover_photo,omitempty" gorm:"foreignKey:CoverPhotoID"`
	AlbumPhotos   []AlbumPhoto `json:"album_photos,omitempty" gorm:"foreignKey:AlbumID"`
}

func (a *Album) BeforeCreate(tx *gorm.DB) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}
	return nil
}

type AlbumPhoto struct {
	ID        uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:gen_random_uuid()"`
	AlbumID   uuid.UUID      `json:"album_id" gorm:"type:uuid;not null;index"`
	PhotoID   uuid.UUID      `json:"photo_id" gorm:"type:uuid;not null;index"`
	AddedBy   uuid.UUID      `json:"added_by" gorm:"type:uuid;not null"`
	SortOrder int            `json:"sort_order" gorm:"default:0;index"`
	AddedAt   time.Time      `json:"added_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联关系
	Album   Album `json:"album,omitempty" gorm:"foreignKey:AlbumID"`
	Photo   Photo `json:"photo,omitempty" gorm:"foreignKey:PhotoID"`
	AddedByUser User `json:"added_by_user,omitempty" gorm:"foreignKey:AddedBy"`
}

func (ap *AlbumPhoto) BeforeCreate(tx *gorm.DB) error {
	if ap.ID == uuid.Nil {
		ap.ID = uuid.New()
	}
	return nil
}