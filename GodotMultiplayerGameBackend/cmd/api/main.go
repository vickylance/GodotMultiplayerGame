package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/api/controllers"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/api/routes"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/database"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/repository"
	"github.com/vickylance/GodotMultiplayerGameBackend/internal/service"
)

func main() {
	// 1. Init Database
	db := database.InitDB()
	defer db.Close(context.Background())

	err := database.RunMigrations(db)
	if err != nil {
		log.Fatalf("Migration failed: %v", err)
	}

	// 2. Dependency Injection
	emailService := service.NewEmailService()
	userRepo := repository.NewUserRepository(db)
	authService := service.NewAuthService(userRepo, emailService)
	authController := controllers.NewAuthController(authService)

	// 3. Setup Router
	router := gin.Default()

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	// Routes
	routes.SetupAuthRoutes(router, authController)

	// 4. Start Server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Backend API listening on port %s\n", port)
	router.Run(":" + port)
}
