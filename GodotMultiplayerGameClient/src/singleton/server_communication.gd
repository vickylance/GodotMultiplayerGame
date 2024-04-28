extends Node

signal player_connected
signal player_login_verification_failed
signal player_login_verification_success

var network := ENetMultiplayerPeer.new()
var game_server_ip := "127.0.0.1"
var game_server_port := 1909

var token


func connect_to_server() -> void:
	var err := network.create_client(game_server_ip, game_server_port)
	assert(err == OK)
	multiplayer.multiplayer_peer = network

	# network.peer_connected.connect(_on_peer_connected)
	# network.peer_disconnected.connect(_on_peer_disconnected)

	var err2 := multiplayer.connected_to_server.connect(_on_connected_to_server)
	assert(err2 == OK)
	err2 = multiplayer.connection_failed.connect(_on_connection_failed)
	assert(err2 == OK)
	err2 = multiplayer.server_disconnected.connect(_on_server_disconnected)
	assert(err2 == OK)
	print("Client -> GameServer: Multiplayer ID: ", multiplayer.get_unique_id())


func _on_connected_to_server() -> void:
	print("Connected to server")
	player_connected.emit()


func _on_connection_failed() -> void:
	print("Connection failed")


func _on_server_disconnected() -> void:
	print("Server disconnected")

# func _on_peer_connected(id: int) -> void:
#     print("Peer connected: ", id)

# func _on_peer_disconnected(id: int) -> void:
#     print("Peer disconnected: ", id)


@rpc("reliable")
func fetch_skill_damage(skill_name: String, instance_id: int) -> void:
	fetch_skill_damage.rpc_id(1, skill_name, instance_id)


@rpc("reliable")
func return_skill_damage(skill_damage, requester) -> void:
	var requester_instance = instance_from_id(requester)
	if requester_instance.has_method("set_damage"):
		requester_instance.set_damage(skill_damage)


@rpc("reliable")
func fetch_player_stats() -> void:
	rpc_id(1, "fetch_player_stats")
	pass


@rpc("reliable")
func return_player_stats(stats) -> void:
	PlayerStats.load_player_stats(stats)
	pass


@rpc("reliable")
func fetch_token(_player_id: int) -> void:
	rpc_id(1, "return_token", token)
	pass


@rpc("reliable")
func return_token(_token: String) -> void:
	# Implemented on the server
	pass


@rpc("reliable")
func return_token_verification_results(_player_id: int, result: bool) -> void:
	if result == true:
		print("Player token verification success")
		player_login_verification_success.emit()
	else:
		print("Player token verification failed")
		player_login_verification_failed.emit()
	pass
