package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

type User struct {
	ID           int    `json:"id"`
	Username     string `json:"username" binding:"required"`
	Email        string `json:"email" binding:"required"`
	PasswordHash string `json:"password_hash" binding:"required"`
	Salt         string `json:"salt" binding:"required"`
}

var db *pgx.Conn

func main() {
	var err error
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://user:password@localhost:5432/game_db"
	}

	// Retry connection loop
	maxRetries := 10
	for i := 0; i < maxRetries; i++ {
		db, err = pgx.Connect(context.Background(), dbURL)
		if err == nil {
			break
		}
		log.Printf("Failed to connect to database (attempt %d/%d): %v. Retrying in 2 seconds...\n", i+1, maxRetries, err)
		time.Sleep(2 * time.Second)
	}

	if err != nil {
		log.Fatalf("Unable to connect to database after %d attempts: %v\n", maxRetries, err)
	}
	defer db.Close(context.Background())

	// Run migration
	err = runMigrations()
	if err != nil {
		log.Fatalf("Failed to run migrations: %v\n", err)
	}

	router := gin.Default()

	router.POST("/register", registerUser)
	router.POST("/login", loginUser)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Backend API listening on port %s\n", port)
	router.Run(":" + port)
}

func runMigrations() error {
	query := `
	CREATE TABLE IF NOT EXISTS users (
		id SERIAL PRIMARY KEY,
		username TEXT UNIQUE NOT NULL,
		email TEXT UNIQUE NOT NULL,
		password_hash TEXT NOT NULL,
		salt TEXT NOT NULL,
		created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
	);`
	_, err := db.Exec(context.Background(), query)
	return err
}

func registerUser(c *gin.Context) {
	var newUser User
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := `INSERT INTO users (username, email, password_hash, salt) VALUES ($1, $2, $3, $4) RETURNING id`
	err := db.QueryRow(context.Background(), query, newUser.Username, newUser.Email, newUser.PasswordHash, newUser.Salt).Scan(&newUser.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, newUser)
}

func loginUser(c *gin.Context) {
	var loginReq struct {
		Username string `json:"username" binding:"required"`
	}
	if err := c.ShouldBindJSON(&loginReq); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user User
	query := `SELECT id, username, email, password_hash, salt FROM users WHERE username = $1`
	err := db.QueryRow(context.Background(), query, loginReq.Username).Scan(&user.ID, &user.Username, &user.Email, &user.PasswordHash, &user.Salt)
	if err != nil {
		if err == pgx.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, user)
}
