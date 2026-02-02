extends Node

var network := ENetMultiplayerPeer.new()
var authenticate_api := SceneMultiplayer.new()
var authenticate_server_ip := OS.get_environment("AUTH_IP") if OS.has_environment("AUTH_IP") else "127.0.0.1"
var authenticate_server_port := int(OS.get_environment("AUTH_GAME_PORT")) if OS.has_environment("AUTH_GAME_PORT") else 1912

var game_server


func _ready() -> void:
	connect_to_server()
	game_server = get_node("/root/Server")


func _process(_delta: float) -> void:
	if not authenticate_api.has_multiplayer_peer():
		return
	authenticate_api.poll()
	pass


func connect_to_server() -> void:
	network = ENetMultiplayerPeer.new()
	authenticate_api = SceneMultiplayer.new()
	var err := network.create_client(authenticate_server_ip, authenticate_server_port)
	assert(err == OK)
	
	get_tree().set_multiplayer(authenticate_api, self.get_path())
	authenticate_api.multiplayer_peer = network

	var err2 := multiplayer.connected_to_server.connect(_on_connected_to_server)
	assert(err2 == OK)
	err2 = multiplayer.connection_failed.connect(_on_connection_failed)
	assert(err2 == OK)
	err2 = multiplayer.server_disconnected.connect(_on_server_disconnected)
	assert(err2 == OK)
	
	print("GameServer -> AuthServer: Started on port: " + str(authenticate_server_port))
	print("GameServer -> AuthServer: Multiplayer ID: ", authenticate_api.get_unique_id())
	pass


func _on_connected_to_server() -> void:
	print("Connected to AuthServer")


func _on_connection_failed() -> void:
	print("Failed to connect to AuthServer")


func _on_server_disconnected() -> void:
	print("AuthServer disconnected")


@rpc("reliable")
func receive_login_token(token: String) -> void:
	print("Received Token: ", token)
	game_server.expected_tokens.append(token)
	pass
