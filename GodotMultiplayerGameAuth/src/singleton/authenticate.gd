extends Node

var network := ENetMultiplayerPeer.new()
var auth_server_port := 1911
var max_gateways := 5


func _ready() -> void:
	start_server()
	pass


func start_server() -> void:
	var err := network.create_server(auth_server_port, max_gateways)
	assert(err == OK)
	multiplayer.multiplayer_peer = network

	var err2 = network.peer_connected.connect(_peer_connected)
	assert(err2 == OK)
	err2 = network.peer_disconnected.connect(_peer_disconnected)
	assert(err2 == OK)
	
	print("AuthServer -> GatewayServer: Started on port: " + str(auth_server_port))
	print("AuthServer -> GatewayServer: Multiplayer ID: ", multiplayer.get_unique_id())
	pass


func _peer_connected(gateway_id: int) -> void:
	print("Gateway connected: " + str(gateway_id))
	pass


func _peer_disconnected(gateway_id: int) -> void:
	print("Gateway disconnected: " + str(gateway_id))
	pass


@rpc("any_peer")
func authenticate_player(username: String, password: String, player_id: int) -> void:
	print("Authentication request received")
	var token
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	print("Starting authentication")
	if not PlayerData.player_data.has(username):
		print("User not recognized")
		result = false
	elif not PlayerData.player_data[username].Password == password:
		print("Incorrect password")
		result = false
	else:
		print("Successful authentication")
		result = true
		
		# Generate token
		randomize()
		var random_number = randi()
		var hashed = str(random_number).sha256_text()
		print("Hash: ", hashed)
		var timestamp = str(int(Time.get_unix_time_from_system()))
		print("Time: ", timestamp)
		token = hashed + timestamp
		var game_server = "GameServer1" # TODO: This name should come from LoadBalancer
		GameServers.distribute_login_tokens(token, game_server)
		
	print("authentication result send to gateway server")
	rpc_id(gateway_id, "authenticate_result", result, player_id, token)
	pass


@rpc
func authenticate_result(_result: bool, _player_id: int, _token: String) -> void:
	# Only implemented on gateway client
	pass