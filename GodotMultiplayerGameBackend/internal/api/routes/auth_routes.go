package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/api/controllers"
)

func SetupAuthRoutes(router *gin.Engine, authCtrl *controllers.AuthController) {
	router.POST("/register", authCtrl.Register)
	router.POST("/verify-email", authCtrl.VerifyEmail)
	router.POST("/login", authCtrl.Login)
	router.POST("/forgot-password", authCtrl.ForgotPassword)
	router.POST("/reset-password", authCtrl.ResetPassword)
	router.POST("/change-password", authCtrl.ChangePassword)
}
