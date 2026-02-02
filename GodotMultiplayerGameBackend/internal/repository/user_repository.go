package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/domain"
)

type UserRepository struct {
	db *pgx.Conn
}

func NewUserRepository(db *pgx.Conn) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	query := `INSERT INTO users (username, email, password_hash, salt) VALUES ($1, $2, $3, $4) RETURNING id`
	return r.db.QueryRow(ctx, query, user.Username, user.Email, user.PasswordHash, user.Salt).Scan(&user.ID)
}

func (r *UserRepository) GetUserByUsername(ctx context.Context, username string) (*domain.User, error) {
	var user domain.User
	query := `SELECT id, username, email, password_hash, salt, is_verified FROM users WHERE username = $1`
	err := r.db.QueryRow(ctx, query, username).Scan(&user.ID, &user.Username, &user.Email, &user.PasswordHash, &user.Salt, &user.IsVerified)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User
	query := `SELECT id, username, email, password_hash, salt, is_verified FROM users WHERE email = $1`
	err := r.db.QueryRow(ctx, query, email).Scan(&user.ID, &user.Username, &user.Email, &user.PasswordHash, &user.Salt, &user.IsVerified)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) UpdateVerificationStatus(ctx context.Context, userID int, status bool) error {
	_, err := r.db.Exec(ctx, "UPDATE users SET is_verified = $1 WHERE id = $2", status, userID)
	return err
}

func (r *UserRepository) UpdatePassword(ctx context.Context, userID int, passwordHash string) error {
	_, err := r.db.Exec(ctx, "UPDATE users SET password_hash = $1 WHERE id = $2", passwordHash, userID)
	return err
}

// Verification Codes
func (r *UserRepository) CreateVerificationCode(ctx context.Context, code *domain.VerificationCode) error {
	query := `INSERT INTO verification_codes (user_id, code, type, expires_at) VALUES ($1, $2, $3, $4)`
	_, err := r.db.Exec(ctx, query, code.UserID, code.Code, code.Type, code.ExpiresAt)
	return err
}

func (r *UserRepository) GetVerificationCode(ctx context.Context, userID int, code string, codeType string) (*domain.VerificationCode, error) {
	var vc domain.VerificationCode
	query := `SELECT id, user_id, code, type, expires_at FROM verification_codes WHERE user_id = $1 AND code = $2 AND type = $3 AND expires_at > $4`
	err := r.db.QueryRow(ctx, query, userID, code, codeType, time.Now()).Scan(&vc.ID, &vc.UserID, &vc.Code, &vc.Type, &vc.ExpiresAt)
	if err != nil {
		return nil, err
	}
	return &vc, nil
}

func (r *UserRepository) GetVerificationCodeByToken(ctx context.Context, token string, codeType string) (*domain.VerificationCode, error) {
	var vc domain.VerificationCode
	query := `SELECT id, user_id, code, type, expires_at FROM verification_codes WHERE code = $1 AND type = $2 AND expires_at > $3`
	err := r.db.QueryRow(ctx, query, token, codeType, time.Now()).Scan(&vc.ID, &vc.UserID, &vc.Code, &vc.Type, &vc.ExpiresAt)
	if err != nil {
		return nil, err
	}
	return &vc, nil
}

func (r *UserRepository) DeleteVerificationCode(ctx context.Context, userID int, codeType string) error {
	_, err := r.db.Exec(ctx, "DELETE FROM verification_codes WHERE user_id = $1 AND type = $2", userID, codeType)
	return err
}

// Device Logging
func (r *UserRepository) GetDevice(ctx context.Context, userID int, deviceID string) (*domain.UserDevice, error) {
	var device domain.UserDevice
	query := `SELECT id, user_id, device_id FROM user_devices WHERE user_id = $1 AND device_id = $2`
	err := r.db.QueryRow(ctx, query, userID, deviceID).Scan(&device.ID, &device.UserID, &device.DeviceID)
	if err != nil {
		return nil, err
	}
	return &device, nil
}

func (r *UserRepository) UpsertDevice(ctx context.Context, userID int, deviceID string) error {
	query := `
		INSERT INTO user_devices (user_id, device_id, last_login) VALUES ($1, $2, $3)
		ON CONFLICT (user_id, device_id) DO UPDATE SET last_login = $3`
	_, err := r.db.Exec(ctx, query, userID, deviceID, time.Now())
	return err
}
