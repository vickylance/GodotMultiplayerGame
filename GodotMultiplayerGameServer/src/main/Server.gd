extends Node
class_name GameServer

var network := ENetMultiplayerPeer.new()
var game_server_port := int(OS.get_environment("GAME_SERVER_PORT")) if OS.has_environment("GAME_SERVER_PORT") else 1909
var max_players := 150
var expected_tokens: Array[String] = []

@onready var player_verification_process := $PlayerVerification


func _ready() -> void:
	start_server()


func start_server() -> void:
	var err := network.create_server(game_server_port, max_players)
	assert(err == OK)
	multiplayer.multiplayer_peer = network
	var err2 = network.peer_connected.connect(_peer_connected)
	assert(err2 == OK)
	err2 = network.peer_disconnected.connect(_peer_disconnected)
	assert(err2 == OK)
	
	print("GameServer -> Client: Started on port: " + str(game_server_port))
	print("GameServer -> Client: Multiplayer ID: ", multiplayer.get_unique_id())
	pass


func _peer_connected(player_id: int) -> void:
	print("Player connected: " + str(player_id))
	player_verification_process.start_verification(player_id)
	pass


func _peer_disconnected(player_id: int) -> void:
	print("Player disconnected: " + str(player_id))
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		ServerCommunication.despawn_other_player.rpc_id(0, player_id)
	pass


func _on_token_expiration_timer_timeout() -> void:
	var current_time := Time.get_unix_time_from_system()
	var token_time: int
	if expected_tokens.is_empty():
		pass
	else:
		for i in range(expected_tokens.size() - 1, -1, -1): # Loop through reverse as we might be deleting multiple items
			token_time = int(expected_tokens[i].right(10))
			if current_time - token_time >= 30:
				expected_tokens.remove_at(i)
	pass
