extends Node

var network := ENetMultiplayerPeer.new()
var auth_server_ip := "127.0.0.1"
var auth_server_port := 1911


func _ready() -> void:
	connect_to_server()
	pass


func connect_to_server() -> void:
	var err := network.create_client(auth_server_ip, auth_server_port)
	assert(err == OK)
	multiplayer.multiplayer_peer = network
	

	# network.peer_connected.connect(_on_peer_connected)
	# network.peer_disconnected.connect(_on_peer_disconnected)

	var err2 = multiplayer.connected_to_server.connect(_on_connected_to_server)
	assert(err2 == OK)
	err2 = multiplayer.connection_failed.connect(_on_connection_failed)
	assert(err2 == OK)
	err2 = multiplayer.server_disconnected.connect(_on_server_disconnected)
	assert(err2 == OK)
	
	print("GatewayServer -> AuthServer: Multiplayer ID: ", multiplayer.get_unique_id())
	pass


func _on_connected_to_server() -> void:
	print("Connected to AuthServer")
	#authenticate_player("Test", "Test123", 1234)


func _on_connection_failed() -> void:
	print("Failed to connect to AuthServer")


func _on_server_disconnected() -> void:
	print("AuthServer disconnected")


# func _on_peer_connected(id: int) -> void:
#     print("Peer connected: ", id)

# func _on_peer_disconnected(id: int) -> void:
#     print("Peer disconnected: ", id)


@rpc("reliable")
func authenticate_player(username: String, password: String, player_id: int) -> void:
	authenticate_player.rpc_id(1, username, password, player_id)
	pass


@rpc("reliable")
func authenticate_result(result: bool, player_id: int, token: String) -> void:
	print("Got result: ", result, " PlayerID: ", player_id, " TOKEN: ",  token)
	Gateway.return_login_request(result, player_id, token)
	pass
