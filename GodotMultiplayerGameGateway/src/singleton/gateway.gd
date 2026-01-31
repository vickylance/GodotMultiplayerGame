extends Node

var network := ENetMultiplayerPeer.new()
var gateway_api := SceneMultiplayer.new()
var gateway_server_port := 1910
var max_players := 100
var cert_key := load("res://cert/X509_key.key")
var cert := load("res://cert/X509_Certificate.crt")

func _ready() -> void:
	start_server()
	pass


func _process(_delta: float) -> void:
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()
	pass


func start_server() -> void:
	var err := network.create_server(gateway_server_port, max_players)
	assert(err == OK)
	network.host.dtls_server_setup(TLSOptions.server(cert_key, cert))
	
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network
	
	var err2 = network.peer_connected.connect(_peer_connected)
	assert(err2 == OK)
	err2 = network.peer_disconnected.connect(_peer_disconnected)
	assert(err2 == OK)
	
	print("GatewayServer -> Client: Started on port: ", str(gateway_server_port))
	print("GatewayServer -> Client: Multiplayer ID: ", gateway_api.get_unique_id())
	pass


func _peer_connected(player_id: int) -> void:
	print("Player connected: " + str(player_id))
	pass


func _peer_disconnected(player_id: int) -> void:
	print("Player disconnected: " + str(player_id))
	pass


@rpc("any_peer", "reliable")
func login_request(username: String, password: String) -> void:
	var player_id := gateway_api.get_remote_sender_id()
	Authenticate.authenticate_player(username.to_lower(), password, player_id)
	pass


@rpc("reliable")
func return_login_request(result: bool, player_id: int, token: String) -> void:
	print("ReturnLoginRequest: ", result, " playerID: ", player_id, " Token: ", token)
	return_login_request.rpc_id(player_id, result, player_id, token)
	await get_tree().create_timer(1).timeout
	network.disconnect_peer(player_id)
	pass


@rpc("any_peer", "reliable")
func create_new_account_request(username: String, password: String, email: String) -> void:
	var player_id := gateway_api.get_remote_sender_id()
	var valid_request = true
	if username == "":
		valid_request = false
	if password == "":
		valid_request = false
	if email == "":
		valid_request = false
		
	if valid_request == false:
		return_create_new_account_request(valid_request, player_id, 1)
	else:
		Authenticate.create_account(username.to_lower(), password, player_id, email)
	pass


@rpc("reliable")
func return_create_new_account_request(result: bool, player_id: int, message: int) -> void:
	return_create_new_account_request.rpc_id(player_id, result, player_id, message)
	# 1 = failed to create, 2 = existing user, 3 = welcome
	await get_tree().create_timer(1).timeout
	network.disconnect_peer(player_id)
	pass
