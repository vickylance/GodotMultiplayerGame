extends Node

var network := ENetMultiplayerPeer.new()
var gateway_api := SceneMultiplayer.new()
var gateway_server_ip := "127.0.0.1"
var gateway_server_port := 1910
var cert = load("res://cert/X509_Certificate.crt")

signal player_successfully_authenticated
signal player_authentication_failed
signal player_created_successfully
signal player_creation_failed

var username: String
var password: String
var create_account: bool


func _process(_delta: float) -> void:
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()
	pass


func connect_to_server(_username: String, _password: String, _create_account: bool = false) -> void:
	username = _username
	password = _password
	create_account = _create_account
	network = ENetMultiplayerPeer.new()
	gateway_api = SceneMultiplayer.new()
	var err := network.create_client(gateway_server_ip, gateway_server_port)
	assert(err == OK)
	err = network.host.dtls_client_setup("GodotMultiplayerGame", TLSOptions.client(cert))
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
	if create_account:
		create_new_account_request()
	else:
		login_request()


func _on_connection_failed() -> void:
	print("Failed to connect to gateway server")
	player_authentication_failed.emit()


func _on_server_disconnected() -> void:
	print("Gateway server disconnected")


@rpc("reliable")
func login_request() -> void:
	login_request.rpc_id(1, username, password.sha256_text())
	username = ""
	password = ""
	pass


@rpc("reliable")
func return_login_request(result: bool, _player_id: int, token: String) -> void:
	print("Received result: ", result, " TOKEN: ", token)
	if result:
		print("Player successfully authenticated. Connecting to game server")
		ServerCommunication.token = token
		ServerCommunication.connect_to_server()
		player_successfully_authenticated.emit()
	else:
		print("Player authentication failed")
		player_authentication_failed.emit()
	multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	pass


@rpc("reliable")
func create_new_account_request() -> void:
	print("Requesting new account creation")
	create_new_account_request.rpc_id(1, username, password.sha256_text())
	username = ""
	password = ""
	pass


@rpc("reliable")
func return_create_new_account_request(result: bool, _player_id: int, message: int) -> void:
	print("Create account results received")
	if result:
		print("Account created, please proceed with login")
		player_created_successfully.emit()
	else:
		if message == 1:
			print("Coundn't create account")
		elif message == 2:
			print("Username already exists, please use different username")
		player_creation_failed.emit()
	multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	multiplayer.connection_failed.disconnect(_on_connection_failed)
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	pass
