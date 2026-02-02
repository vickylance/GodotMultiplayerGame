package service

import (
	"context"
	"crypto/rand"
	"fmt"
	"math/big"
	"time"

	"github.com/vickylance/GodotMultiplayerGameBackend/internal/domain"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/repository"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	repo         *repository.UserRepository
	emailService *EmailService
}

func NewAuthService(repo *repository.UserRepository, emailService *EmailService) *AuthService {
	return &AuthService{
		repo:         repo,
		emailService: emailService,
	}
}

func (s *AuthService) Register(ctx context.Context, user *domain.User, rawPassword string) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(rawPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	user.PasswordHash = string(hashedPassword)
	user.Salt = "" // Bcrypt handles salting internally

	err = s.repo.CreateUser(ctx, user)
	if err != nil {
		return err
	}

	// Generate verification code
	codeStr := s.generateRandomCode(6)
	expiresAt := time.Now().Add(15 * time.Minute)
	vc := &domain.VerificationCode{
		UserID:    user.ID,
		Code:      codeStr,
		Type:      "email_verify",
		ExpiresAt: expiresAt,
	}

	_ = s.repo.CreateVerificationCode(ctx, vc)

	// Send Real Email via Brevo
	err = s.emailService.SendVerificationEmail(ctx, user.Email, user.Username, codeStr)
	if err != nil {
		fmt.Printf("[ERROR] Failed to send email: %v\n", err)
	}

	return nil
}

func (s *AuthService) VerifyEmail(ctx context.Context, username, code string) error {
	user, err := s.repo.GetUserByUsername(ctx, username)
	if err != nil {
		return err
	}

	_, err = s.repo.GetVerificationCode(ctx, user.ID, code, "email_verify")
	if err != nil {
		return fmt.Errorf("invalid or expired code")
	}

	err = s.repo.UpdateVerificationStatus(ctx, user.ID, true)
	if err != nil {
		return err
	}

	return s.repo.DeleteVerificationCode(ctx, user.ID, "email_verify")
}

func (s *AuthService) Login(ctx context.Context, username, rawPassword, deviceID string) (*domain.User, error) {
	user, err := s.repo.GetUserByUsername(ctx, username)
	if err != nil {
		return nil, err
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(rawPassword))
	if err != nil {
		return nil, fmt.Errorf("invalid credentials")
	}

	// Check device
	_, err = s.repo.GetDevice(ctx, user.ID, deviceID)
	if err != nil {
		// New device logic
		fmt.Printf("[MOCK NOTIFY] User %s logged in from new device: %s\n", user.Username, deviceID)
	}

	err = s.repo.UpsertDevice(ctx, user.ID, deviceID)
	return user, err
}

func (s *AuthService) ForgotPassword(ctx context.Context, email string) error {
	user, err := s.repo.GetUserByEmail(ctx, email)
	if err != nil {
		// Return nil to avoid email enumeration
		return nil
	}

	token := s.generateRandomCode(12)
	expiresAt := time.Now().Add(30 * time.Minute)
	vc := &domain.VerificationCode{
		UserID:    user.ID,
		Code:      token,
		Type:      "password_reset",
		ExpiresAt: expiresAt,
	}

	_ = s.repo.CreateVerificationCode(ctx, vc)

	// Send Real Email via Brevo
	err = s.emailService.SendPasswordResetEmail(ctx, email, token)
	if err != nil {
		fmt.Printf("[ERROR] Failed to send reset email: %v\n", err)
	}

	return nil
}

func (s *AuthService) ResetPassword(ctx context.Context, token, newPassword string) error {
	vc, err := s.repo.GetVerificationCodeByToken(ctx, token, "password_reset")
	if err != nil {
		return fmt.Errorf("invalid or expired reset token")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	err = s.repo.UpdatePassword(ctx, vc.UserID, string(hashedPassword))
	if err != nil {
		return err
	}

	return s.repo.DeleteVerificationCode(ctx, vc.UserID, "password_reset")
}

func (s *AuthService) ChangePassword(ctx context.Context, username, oldPassword, newPassword, confirmPassword string) error {
	if newPassword != confirmPassword {
		return fmt.Errorf("new passwords do not match")
	}

	user, err := s.repo.GetUserByUsername(ctx, username)
	if err != nil {
		return fmt.Errorf("user not found")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(oldPassword))
	if err != nil {
		return fmt.Errorf("incorrect old password")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	return s.repo.UpdatePassword(ctx, user.ID, string(hashedPassword))
}

func (s *AuthService) generateRandomCode(length int) string {
	const charset = "0123456789"
	b := make([]byte, length)
	for i := range b {
		num, _ := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		b[i] = charset[num.Int64()]
	}
	return string(b)
}
