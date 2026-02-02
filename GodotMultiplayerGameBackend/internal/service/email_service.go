package service

import (
	"context"
	"fmt"
	"os"

	brevo "github.com/getbrevo/brevo-go/lib"
)

type EmailService struct {
	client      *brevo.APIClient
	senderEmail string
	senderName  string
	apiKey      string
}

func NewEmailService() *EmailService {
	apiKey := os.Getenv("BREVO_API_KEY")
	senderEmail := os.Getenv("BREVO_SENDER_EMAIL")
	senderName := os.Getenv("BREVO_SENDER_NAME")

	cfg := brevo.NewConfiguration()
	cfg.AddDefaultHeader("api-key", apiKey)

	return &EmailService{
		client:      brevo.NewAPIClient(cfg),
		senderEmail: senderEmail,
		senderName:  senderName,
		apiKey:      apiKey,
	}
}

func (s *EmailService) SendVerificationEmail(ctx context.Context, toEmail, username, code string) error {
	body := fmt.Sprintf("Hello %s,\n\nYour verification code is: %s\n\nThis code expires in 15 minutes.", username, code)
	return s.sendEmail(ctx, toEmail, "Verify Your Account", body)
}

func (s *EmailService) SendPasswordResetEmail(ctx context.Context, toEmail, token string) error {
	link := fmt.Sprintf("http://localhost:8080/reset-password?token=%s", token)
	body := fmt.Sprintf("Click the link below to reset your password:\n\n%s\n\nThis link expires in 30 minutes.", link)
	return s.sendEmail(ctx, toEmail, "Reset Your Password", body)
}

func (s *EmailService) sendEmail(ctx context.Context, toEmail, subject, textContent string) error {
	// If API key is missing, fallback to mock instead of crashing
	if s.apiKey == "" || s.apiKey == "your_brevo_api_key_here" {
		fmt.Printf("[MOCK EMAIL] To: %s, Subject: %s, Body: %s\n", toEmail, subject, textContent)
		return nil
	}

	_, _, err := s.client.TransactionalEmailsApi.SendTransacEmail(ctx, brevo.SendSmtpEmail{
		Sender: &brevo.SendSmtpEmailSender{
			Email: s.senderEmail,
			Name:  s.senderName,
		},
		To: []brevo.SendSmtpEmailTo{
			{
				Email: toEmail,
			},
		},
		Subject:     subject,
		TextContent: textContent,
	})

	return err
}
