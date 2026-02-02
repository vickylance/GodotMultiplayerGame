# --- Project Variables ---
BACKEND_DIR = GodotMultiplayerGameBackend
CLIENT_DIR = GodotMultiplayerGameClient
GATEWAY_DIR = GodotMultiplayerGameGateway
AUTH_DIR = GodotMultiplayerGameAuth
SERVER_DIR = GodotMultiplayerGameServer

# --- Docker Commands ---
.PHONY: up down build logs db-shell clean

up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build --pull

clean:
	@echo "Cleaning up Docker resources..."
	docker-compose down --rmi local --volumes --remove-orphans

logs:
	docker-compose logs -f

db-shell:
	docker exec -it game-db psql -U user -d game_db

# --- Environment Setup ---
# Set GODOT to the path of your Godot binary (e.g., GODOT=/Applications/Godot.app/Contents/MacOS/Godot)
GODOT ?= /Applications/Godot_v4.6_mono.app/Contents/MacOS/Godot

# --- Certificate Generation ---
.PHONY: certs

certs:
	@echo "Generating SSL/TLS certificates..."
	$(GODOT) --headless --path CertificateGenerator -s res://x_509_certificate_generator.gd
	@echo "Copying certificates to Gateway..."
	mkdir -p $(GATEWAY_DIR)/cert
	cp CertificateGenerator/certs/X509_Certificate.crt $(GATEWAY_DIR)/cert/
	cp CertificateGenerator/certs/x509_key.key $(GATEWAY_DIR)/cert/
	@echo "Copying certificate to Client..."
	mkdir -p $(CLIENT_DIR)/cert
	cp CertificateGenerator/certs/X509_Certificate.crt $(CLIENT_DIR)/cert/
	@echo "Done!"

# --- Help ---
.PHONY: help

help:
	@echo "Godot Multiplayer Game - Management Commands"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make up       - Start backend (Go API + Postgres) in background"
	@echo "  make down     - Stop backend services"
	@echo "  make build    - Rebuild and start backend"
	@echo "  make logs     - View backend logs"
	@echo "  make db-shell - Jump into Postgres shell"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make certs    - Generate and distribute DTLS certificates"
	@echo "  make help     - Show this help message"
