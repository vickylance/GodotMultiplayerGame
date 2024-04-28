extends Node

var network := ENetMultiplayerPeer.new()
var gateway_api := SceneMultiplayer.new()
var gateway_server_ip := "127.0.0.1"
var gateway_server_port := 1910

signal player_successfully_authenticated
signal player_authentication_failed
var player_authenticated := false

var username: String
var password: String


func _process(_delta: float) -> void:
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()
	pass


func connect_to_server(_username: String, _password: String) -> void:
	username = _username
	password = _password
	network = ENetMultiplayerPeer.new()
	gateway_api = SceneMultiplayer.new()
	var err := network.create_client(gateway_server_ip, gateway_server_port)
	assert(err == OK)
	
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network

	var err2 := multiplayer.connected_to_server.connect(_on_connected_to_server)
	assert(err2 == OK)
	err2 = multiplayer.connection_failed.connect(_on_connection_failed)
	assert(err2 == OK)
	err2 = multiplayer.server_disconnected.connect(_on_server_disconnected)
	assert(err2 == OK)
	
	print("Client -> GatewayServer: Multiplayer ID: ", gateway_api.get_unique_id())
	pass


func _on_connected_to_server() -> void:
	print("Connected to gateway server")
	login_request()


func _on_connection_failed() -> void:
	print("Failed to connect to gateway server")
	player_authentication_failed.emit()


func _on_server_disconnected() -> void:
	print("Gateway server disconnected")


@rpc("reliable")
func login_request() -> void:
	#gateway_api.rpc_id(1)
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""
	pass


@rpc("reliable")
func return_login_request(result: bool, _player_id: int, token: String) -> void:
	print("Received result: ", result, " TOKEN: ", token)
	if result:
		player_authenticated = true
		print("Player successfully authenticated. Connecting to game server")
		ServerCommunication.token = token
		ServerCommunication.connect_to_server()
		player_successfully_authenticated.emit()
	else:
		print("Player authentication failed")
		player_authentication_failed.emit()
	pass
