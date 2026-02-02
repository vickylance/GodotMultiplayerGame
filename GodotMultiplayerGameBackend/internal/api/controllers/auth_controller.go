package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/api/dto"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/domain"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/service"
)

type AuthController struct {
	authService *service.AuthService
}

func NewAuthController(authService *service.AuthService) *AuthController {
	return &AuthController{authService: authService}
}

func (ctrl *AuthController) Register(c *gin.Context) {
	var req dto.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user := &domain.User{
		Username: req.Username,
		Email:    req.Email,
	}

	err := ctrl.authService.Register(c.Request.Context(), user, req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, dto.UserResponse{
		ID:         user.ID,
		Username:   user.Username,
		Email:      user.Email,
		IsVerified: user.IsVerified,
	})
}

func (ctrl *AuthController) VerifyEmail(c *gin.Context) {
	var req dto.VerifyEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := ctrl.authService.VerifyEmail(c.Request.Context(), req.Username, req.Code)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Email verified successfully"})
}

func (ctrl *AuthController) Login(c *gin.Context) {
	var req dto.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := ctrl.authService.Login(c.Request.Context(), req.Username, req.Password, req.DeviceID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.UserResponse{
		ID:         user.ID,
		Username:   user.Username,
		Email:      user.Email,
		IsVerified: user.IsVerified,
	})
}

func (ctrl *AuthController) ForgotPassword(c *gin.Context) {
	var req dto.ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_ = ctrl.authService.ForgotPassword(c.Request.Context(), req.Email)

	c.JSON(http.StatusOK, gin.H{"message": "If this email is registered, you will receive a reset link"})
}

func (ctrl *AuthController) ResetPassword(c *gin.Context) {
	var req dto.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := ctrl.authService.ResetPassword(c.Request.Context(), req.Token, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password updated successfully"})
}

func (ctrl *AuthController) ChangePassword(c *gin.Context) {
	var req dto.ChangePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := ctrl.authService.ChangePassword(c.Request.Context(), req.Username, req.OldPassword, req.NewPassword, req.ConfirmPassword)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password changed successfully"})
}
