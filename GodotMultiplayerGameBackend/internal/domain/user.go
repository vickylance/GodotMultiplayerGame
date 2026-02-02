package domain

import "time"

type User struct {
	ID           int
	Username     string
	Email        string
	PasswordHash string
	Salt         string
	IsVerified   bool
	CreatedAt    time.Time
}

type VerificationCode struct {
	ID        int
	UserID    int
	Code      string
	Type      string
	ExpiresAt time.Time
	CreatedAt time.Time
}

type UserDevice struct {
	ID        int
	UserID    int
	DeviceID  string
	LastLogin time.Time
}
