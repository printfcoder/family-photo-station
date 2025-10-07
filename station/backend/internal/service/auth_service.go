package service

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"family-photo-station/internal/config"
	"family-photo-station/internal/database"
	"family-photo-station/internal/model"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthService struct {
	cfg *config.Config
}

func NewAuthService(cfg *config.Config) *AuthService {
	return &AuthService{cfg: cfg}
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required,min=3,max=50"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	DeviceID string `json:"device_id"`
	DeviceName string `json:"device_name"`
	DeviceType string `json:"device_type"`
	OSType   string `json:"os_type"`
	OSVersion string `json:"os_version"`
	AppVersion string `json:"app_version"`
}

type TokenResponse struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	ExpiresAt    time.Time `json:"expires_at"`
	User         *model.User `json:"user"`
}

type Claims struct {
	UserID   uuid.UUID `json:"user_id"`
	Username string    `json:"username"`
	Role     string    `json:"role"`
	jwt.RegisteredClaims
}

func (s *AuthService) Register(req *RegisterRequest) (*model.User, error) {
	// 检查用户名是否已存在
	var existingUser model.User
	if err := database.DB.Where("username = ? OR email = ?", req.Username, req.Email).First(&existingUser).Error; err == nil {
		return nil, errors.New("用户名或邮箱已存在")
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, fmt.Errorf("检查用户失败: %w", err)
	}

	// 生成盐值
	salt, err := generateSalt()
	if err != nil {
		return nil, fmt.Errorf("生成盐值失败: %w", err)
	}

	// 加密密码
	passwordHash, err := hashPassword(req.Password, salt)
	if err != nil {
		return nil, fmt.Errorf("密码加密失败: %w", err)
	}

	// 创建用户
	user := &model.User{
		Username:     req.Username,
		Email:        req.Email,
		PasswordHash: passwordHash,
		Salt:         salt,
		Role:         "member",
		IsActive:     true,
	}

	if err := database.DB.Create(user).Error; err != nil {
		return nil, fmt.Errorf("创建用户失败: %w", err)
	}

	// 清除敏感信息
	user.PasswordHash = ""
	user.Salt = ""

	return user, nil
}

func (s *AuthService) Login(req *LoginRequest) (*TokenResponse, error) {
	// 查找用户
	var user model.User
	if err := database.DB.Where("username = ? OR email = ?", req.Username, req.Username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户名或密码错误")
		}
		return nil, fmt.Errorf("查找用户失败: %w", err)
	}

	// 验证密码
	if !verifyPassword(req.Password, user.Salt, user.PasswordHash) {
		return nil, errors.New("用户名或密码错误")
	}

	// 检查用户状态
	if !user.IsActive {
		return nil, errors.New("用户已被禁用")
	}

	// 更新最后登录时间
	now := time.Now()
	user.LastLoginAt = &now
	database.DB.Save(&user)

	// 处理设备信息
	var device *model.Device
	if req.DeviceID != "" {
		device, _ = s.registerOrUpdateDevice(&user, req)
	}

	// 生成JWT令牌
	accessToken, refreshToken, expiresAt, err := s.generateTokens(&user)
	if err != nil {
		return nil, fmt.Errorf("生成令牌失败: %w", err)
	}

	// 清除敏感信息
	user.PasswordHash = ""
	user.Salt = ""

	return &TokenResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresAt:    expiresAt,
		User:         &user,
	}, nil
}

func (s *AuthService) RefreshToken(refreshToken string) (*TokenResponse, error) {
	// 验证refresh token
	claims, err := s.validateToken(refreshToken)
	if err != nil {
		return nil, errors.New("无效的刷新令牌")
	}

	// 查找用户
	var user model.User
	if err := database.DB.First(&user, "id = ?", claims.UserID).Error; err != nil {
		return nil, errors.New("用户不存在")
	}

	// 检查用户状态
	if !user.IsActive {
		return nil, errors.New("用户已被禁用")
	}

	// 生成新的令牌
	accessToken, newRefreshToken, expiresAt, err := s.generateTokens(&user)
	if err != nil {
		return nil, fmt.Errorf("生成令牌失败: %w", err)
	}

	// 清除敏感信息
	user.PasswordHash = ""
	user.Salt = ""

	return &TokenResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		ExpiresAt:    expiresAt,
		User:         &user,
	}, nil
}

func (s *AuthService) ValidateToken(tokenString string) (*Claims, error) {
	return s.validateToken(tokenString)
}

func (s *AuthService) registerOrUpdateDevice(user *model.User, req *LoginRequest) (*model.Device, error) {
	var device model.Device
	
	// 查找现有设备
	err := database.DB.Where("user_id = ? AND device_id = ?", user.ID, req.DeviceID).First(&device).Error
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	if errors.Is(err, gorm.ErrRecordNotFound) {
		// 创建新设备
		device = model.Device{
			UserID:     user.ID,
			DeviceID:   req.DeviceID,
			DeviceName: req.DeviceName,
			DeviceType: req.DeviceType,
			OSType:     req.OSType,
			OSVersion:  req.OSVersion,
			AppVersion: req.AppVersion,
			IsActive:   true,
		}
		if err := database.DB.Create(&device).Error; err != nil {
			return nil, err
		}
	} else {
		// 更新现有设备
		device.DeviceName = req.DeviceName
		device.OSVersion = req.OSVersion
		device.AppVersion = req.AppVersion
		device.IsActive = true
		now := time.Now()
		device.LastSyncAt = &now
		if err := database.DB.Save(&device).Error; err != nil {
			return nil, err
		}
	}

	return &device, nil
}

func (s *AuthService) generateTokens(user *model.User) (string, string, time.Time, error) {
	now := time.Now()
	expiresAt := now.Add(time.Duration(s.cfg.JWT.AccessTokenExpire) * time.Hour)

	// Access Token Claims
	accessClaims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "family-photo-station",
			Subject:   user.ID.String(),
		},
	}

	// Refresh Token Claims
	refreshClaims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(time.Duration(s.cfg.JWT.RefreshTokenExpire) * time.Hour * 24)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "family-photo-station",
			Subject:   user.ID.String(),
		},
	}

	// 生成tokens
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)

	accessTokenString, err := accessToken.SignedString([]byte(s.cfg.JWT.Secret))
	if err != nil {
		return "", "", time.Time{}, err
	}

	refreshTokenString, err := refreshToken.SignedString([]byte(s.cfg.JWT.Secret))
	if err != nil {
		return "", "", time.Time{}, err
	}

	return accessTokenString, refreshTokenString, expiresAt, nil
}

func (s *AuthService) validateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.cfg.JWT.Secret), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}

func generateSalt() (string, error) {
	salt := make([]byte, 16)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	return hex.EncodeToString(salt), nil
}

func hashPassword(password, salt string) (string, error) {
	saltedPassword := password + salt
	hash := sha256.Sum256([]byte(saltedPassword))
	hashedPassword, err := bcrypt.GenerateFromPassword(hash[:], bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

func verifyPassword(password, salt, hashedPassword string) bool {
	saltedPassword := password + salt
	hash := sha256.Sum256([]byte(saltedPassword))
	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), hash[:])
	return err == nil
}