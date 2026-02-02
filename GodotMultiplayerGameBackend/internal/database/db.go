package database

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/jackc/pgx/v5"
)

func InitDB() *pgx.Conn {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://user:password@localhost:5432/game_db"
	}

	maxRetries := 10
	var db *pgx.Conn
	var err error

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

	return db
}

func RunMigrations(db *pgx.Conn) error {
	query := `
	CREATE TABLE IF NOT EXISTS users (
		id SERIAL PRIMARY KEY,
		username TEXT UNIQUE NOT NULL,
		email TEXT UNIQUE NOT NULL,
		password_hash TEXT NOT NULL,
		salt TEXT NOT NULL,
		is_verified BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS verification_codes (
		id SERIAL PRIMARY KEY,
		user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
		code TEXT NOT NULL,
		type TEXT NOT NULL,
		expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
		created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS user_devices (
		id SERIAL PRIMARY KEY,
		user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
		device_id TEXT NOT NULL,
		last_login TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
		UNIQUE(user_id, device_id)
	);`
	_, err := db.Exec(context.Background(), query)
	return err
}
