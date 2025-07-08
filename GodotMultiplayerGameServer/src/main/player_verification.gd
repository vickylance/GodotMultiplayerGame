extends Node

@onready var main_interface = get_parent()
@onready var player_container_scene = preload("res://src/instances/player_container.tscn")

var awaiting_verification = {}


func _ready() -> void:
	ServerCommunication.verify_player.connect(verify_player)


func start_verification(player_id: int) -> void:
	print("Starting Verification")
	awaiting_verification[player_id] = { "timestamp": Time.get_unix_time_from_system() }
	ServerCommunication.fetch_token(player_id)
	pass


func verify_player(player_id: int, token: String):
	var token_verification := false
	"""Continuously check for 30 seconds if the player can authenticate with his token
		We do this because there may be lag between Auth server to send the valid token to Game server
	"""
	print("Verifying player....")
	while Time.get_unix_time_from_system() - int(token.right(10)) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			create_player_container(player_id)
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout # Await 2 seconds before rechecking again
	print("Verification Done")
	ServerCommunication.return_token_verification_results(player_id, token_verification)
	if token_verification == false: # This is to make sure people are disconnected
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)
	pass


func _on_verification_expiration_timer_timeout() -> void:
	var current_time := Time.get_unix_time_from_system()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for player_id in awaiting_verification.keys():
			start_time = awaiting_verification[player_id].timestamp
			if current_time - start_time >= 10:
				awaiting_verification.erase(player_id)
				var connected_peers = Array(multiplayer.get_peers())
				if connected_peers.has(player_id):
					ServerCommunication.return_token_verification_results(player_id, false)
					main_interface.network.disconnect_peer(player_id)
	pass


func create_player_container(player_id: int) -> void:
	var new_player_container: PlayerContainer = player_container_scene.instantiate()
	new_player_container.name = str(player_id)
	owner.add_child(new_player_container, true)
	fill_player_container(new_player_container)
	pass


func fill_player_container(player_container: PlayerContainer) -> void:
	player_container.player_stats = ServerData.test_data.stats
	pass
