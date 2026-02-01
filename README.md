# Godot Multiplayer Game

A robust, distributed multiplayer architecture for Godot Engine 4.6+, featuring a secure multi-server setup with specialized components for authentication, load balancing, and dedicated game logic.

## 🚀 Overview

This project implements a scalable multiplayer system that separates concerns between different server types. This architecture ensures better security, scalability, and maintainability.

### Key Components

- **[Auth Server](GodotMultiplayerGameAuth)**: The source of truth for player data and credentials. Uses Godot 4.6 Mono
  - **[Player Data](GodotMultiplayerGameAuth/src/singleton/player_data.gd)**: Manages player data and credentials.
  - **[Game Servers](GodotMultiplayerGameAuth/src/singleton/game_servers.gd)**: Manages game servers.
  - **[Player Verification](GodotMultiplayerGameAuth/src/singleton/player_verification.gd)**: Handles player verification.
- **[Gateway Server](GodotMultiplayerGameGateway)**: A DTLS-secured entry point for clients to authenticate and register. Uses Godot 4.6 Mono
  - **[Gateway](GodotMultiplayerGameGateway/src/main/gateway.gd)**: Handles client authentication and registration.
  - **[Server Communication](GodotMultiplayerGameGateway/src/singleton/server_communication.gd)**: Handles communication between servers.
- **[Game Server](GodotMultiplayerGameServer)**: Authoritative game logic server where the actual gameplay happens. Uses Godot 4.6 Mono
  - **[Server](GodotMultiplayerGameServer/src/main/server.gd)**: Handles game logic and player management.
  - **[Server Communication](GodotMultiplayerGameServer/src/singleton/server_communication.gd)**: Handles communication between servers.
  - **[Combat](GodotMultiplayerGameServer/src/singleton/combat.gd)**: Handles combat logic.
- **[Game Client](GodotMultiplayerGameClient)**: The player's interface to the game world. Uses Godot 4.6
  - **[Client](GodotMultiplayerGameClient/src/main/client.gd)**: Handles client authentication and registration.
  - **[Server Communication](GodotMultiplayerGameClient/src/singleton/server_communication.gd)**: Handles communication between servers.
  - **[Login](GodotMultiplayerGameClient/src/main/login.gd)**: Handles client login.
  - **[Register](GodotMultiplayerGameClient/src/main/register.gd)**: Handles client registration.
- **[Certificate Generator](CertificateGenerator)**: A utility to generate SSL/TLS certificates for secure communication. Uses Godot 4.6 Mono

---

## 🏗 Architecture

### Architecture Overview

The system follows a distributed authoritative server model:

1. **Client**: Godot UI for login, registration, and gameplay.
2. **Gateway Server**: Public-facing entry point (DTLS secure) that proxies authentication.
3. **Auth Server**: Internal server managing sessions, tokens, and verification.
4. **Backend API (Go)**: Internal REST API managing database persistence.
5. **PostgreSQL**: Secure storage for user credentials and profiles.
6. **Game Server**: Authoritative instance managing real-time physics and combat.

The system uses a token-based handoff mechanism to move clients from authentication to gameplay.

### Communication Flow

```mermaid
sequenceDiagram
    participant Client
    participant Gateway
    participant Auth
    participant GameServer

    Note over Client, Gateway: DTLS Connection (Port 1910)
    Client->>Gateway: Login Request
    Gateway->>Auth: Forward Auth Request (Port 1911)
    Auth->>Auth: Validate Credentials
    Auth-->>GameServer: Distribute Login Token (Port 1912)
    Auth->>Gateway: Return Token & GameServer IP
    Gateway->>Client: Return Token & Connection Info
    Gateway--xClient: Disconnect

    Note over Client, GameServer: ENet Connection (Port 1909)
    Client->>GameServer: Connect with Token
    GameServer->>GameServer: Verify Token
    GameServer-->>Client: Spawn Player
```

---

## 🔌 Network Infrastructure

| Component | Connected To | Port | Protocol | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Gateway** | Client | `1910` | ENet + DTLS | Public entry point for Auth/Register |
| **Auth** | Gateway | `1911` | ENet | Internal Auth processing |
| **Auth** | Game Server | `1912` | ENet | Token distribution interface |
| **Game Server** | Client | `1909` | ENet | Authoritative Game State |

---

### Setup & Running

#### 1. Start the Backend Infrastructure

The project uses a Go API and PostgreSQL for data persistence. This must be running before the Godot servers.

```bash
make build
```

#### 2. Generate Certificates

For secure DTLS communication between the Client and Gateway:

```bash
make certs
```

#### 3. Start Order

Run the Godot instances in this order (using `--headless` for servers):

1. **Auth Server** (`Auth/project.godot`)
2. **Gateway Server** (`Gateway/project.godot`)
3. **Game Server** (`Server/project.godot`)
4. **Client** (`Client/project.godot`)

---

## 📂 Project Structure

- `GodotMultiplayerGameAuth/`: Manages `player_data.json` and session tokens.
- `GodotMultiplayerGameGateway/`: Handles client requests and provides SSL termination.
- `GodotMultiplayerGameServer/`: authoritative server with combat systems and player stats.
- `GodotMultiplayerGameClient/`: UI for login/register and the game scene.

---

> [!NOTE]
> This project is built for **Godot 4.6 Forward Plus**. Ensure all components are running the same engine version to avoid compatibility issues.
