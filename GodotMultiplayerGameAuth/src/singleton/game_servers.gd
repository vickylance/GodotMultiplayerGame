extends Node

var network := ENetMultiplayerPeer.new()
var auth_api := SceneMultiplayer.new()
var auth_server_port := 1912
var max_game_servers := 100

var game_server_list = {}


func _ready() -> void:
	start_server()
	pass


func _process(_delta: float) -> void:
	if not auth_api.has_multiplayer_peer():
		return
	auth_api.poll()
	pass


func start_server() -> void:
	var err := network.create_server(auth_server_port, max_game_servers)
	assert(err == OK)
	
	get_tree().set_multiplayer(auth_api, self.get_path())
	auth_api.multiplayer_peer = network
	
	var err2 = network.peer_connected.connect(_peer_connected)
	assert(err2 == OK)
	err2 = network.peer_disconnected.connect(_peer_disconnected)
	assert(err2 == OK)
	
	print("AuthServer -> GameServer: Started on port: ", str(auth_server_port))
	print("AuthServer -> GameServer: Multiplayer ID: ", auth_api.get_unique_id())
	pass


func _peer_connected(game_server_id: int) -> void:
	print("GameServer connected: " + str(game_server_id))
	game_server_list["GameServer1"] = game_server_id # TODO: This name should come from LoadBalancer
	pass


func _peer_disconnected(game_server_id: int) -> void:
	print("GameServer disconnected: " + str(game_server_id))
	pass


func distribute_login_tokens(token: String, game_server: String) -> void:
	print("Token: ", token, " Gameserver: ", game_server)
	var game_server_peer_id = game_server_list[game_server]
	receive_login_token.rpc_id(game_server_peer_id, token)
	pass


@rpc("reliable")
func receive_login_token(_token: String) -> void:
	# Implemented on Game Servers
	pass
