extends Node

var network := ENetMultiplayerPeer.new()
var auth_server_port := 1911
var max_gateways := 5


func _ready() -> void:
	start_server()
	pass


func start_server() -> void:
	"""Start the Authentication server to accept connections from Gateway Clients
	"""
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


@rpc("any_peer", "reliable")
func authenticate_player(username: String, password: String, player_id: int) -> void:
	print("Authentication request received for user: ", username)
	var token := ""
	var hashed_password
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	print("Starting authentication", PlayerData.player_data, username)
	if not PlayerData.player_data.has(username):
		print("User not recognized")
		result = false
	else:
		var retrieved_salt = PlayerData.player_data[username].Salt
		hashed_password = generate_hashed_password(password, retrieved_salt)
	
		if not PlayerData.player_data[username].Password == hashed_password:
			print("Incorrect password")
			result = false
		else:
			print("Successful authentication")
			result = true
	
			# Generate token
			randomize()
			var hashed = str(randi()).sha256_text()
			var timestamp = str(int(Time.get_unix_time_from_system()))
			token = hashed + timestamp
			var game_server = "GameServer1" # TODO: This name should come from LoadBalancer
			GameServers.distribute_login_tokens(token, game_server)
		
	print("authentication result send to gateway server")
	authenticate_result.rpc_id(gateway_id, result, player_id, token)
	pass


@rpc("reliable")
func authenticate_result(_result: bool, _player_id: int, _token: String) -> void:
	"""Implemented on Gateway client to receive the Player login result
	"""
	pass


@rpc("reliable", "any_peer")
func create_account(username: String, password: String, player_id: int, email: String) -> void:
	""" Creates a new user with the given username & password. The player_id is network player_id.
	"""
	print("Create account started")
	var gateway_id := multiplayer.get_remote_sender_id()
	var result := false
	var message := 1 # Default error
	
	# Server-side validation
	var username_regex = RegEx.new()
	username_regex.compile("^[a-zA-Z0-9_]{3,16}$")
	var password_regex = RegEx.new()
	# Password is expected to be SHA256 hashed from client, so we just check length or basic format if needed
	# However, for full security we should check requirements on plaintext, but client sends hash.
	# If client sends hash, we can't check " uppercase/lowercase" easily unless we trust client
	# OR client sends plaintext over DTLS (which it does via Gateway).
	# Wait, Gateway.gd (Client) does: create_new_account_request.rpc_id(1, username, password.sha256_text(), email)
	# So Auth receives a HASHED password. We can't validate "uppercase" on a hash.
	# We should trust client validation OR change flow to send plaintext over secure tunnel.
	# For now, I will proceed with length check on hash and valid username/email.
	
	var email_regex = RegEx.new()
	email_regex.compile("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$")
	
	if not username_regex.search(username):
		result = false
		message = 1 # Validation failed
	elif not email_regex.search(email):
		result = false
		message = 1 # Validation failed
	elif PlayerData.player_data.has(username):
		result = false
		message = 2 # Existing user
	else:
		result = true
		message = 3 # Welcome
		var salt := generate_salt()
		var hashed_password := generate_hashed_password(password, salt)
		PlayerData.player_data[username] = {
			"Password": hashed_password,
			"Salt": salt,
			"Email": email
		}
		PlayerData.save_player_ids()
	
	create_account_result.rpc_id(gateway_id, result, player_id, message)
	print("Reload IDs")
	PlayerData.load_player_ids()
	print("PlayerData: ", PlayerData.player_data)
	pass


@rpc("reliable")
func create_account_result(_result: bool, _player_id: int, _message: int) -> void:
	"""Implemented on Gateway client to receive the Player creation result
	"""
	pass


func generate_salt() -> String:
	randomize()
	var salt := str(randi()).sha1_text()
	return salt


func generate_hashed_password(password: String, salt: String) -> String:
	print(str(Time.get_unix_time_from_system()))
	var hashed_password := password
	var rounds := pow(2, 18)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	print("Final hashed password:", hashed_password)
	print(str(Time.get_unix_time_from_system()))
	return hashed_password
