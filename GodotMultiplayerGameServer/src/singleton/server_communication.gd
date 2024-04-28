extends Node


signal verify_player(player_id: int, token: String)

@rpc("any_peer", "reliable")
func fetch_skill_damage(skill_name: String, requester_id: int) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	var damage: int = Combat.fetch_skill_damage(skill_name)
	rpc_id(player_id, "return_skill_damage", damage, requester_id)
	print("Sending: " + str(damage) + " damage to player " + str(player_id))
	pass


@rpc("reliable")
func return_skill_damage(_skill_damage, _requester) -> void:
	# Only implemented in client
	pass


@rpc("any_peer", "reliable")
func fetch_player_stats() -> void:
	print("Yolo")
	var player_id := multiplayer.get_remote_sender_id()
	var player_stats = get_node("/root/Server/" + str(player_id)).player_stats # TODO: Refactor better
	print("Got the player stats: ", player_stats)
	rpc_id(player_id, "return_player_stats", player_stats)
	pass


@rpc("reliable")
func return_player_stats(_stats) -> void:
	# Implemented on the client
	pass


@rpc("reliable")
func fetch_token(player_id: int) -> void:
	rpc_id(player_id, "fetch_token", player_id)
	pass


@rpc("any_peer", "reliable")
func return_token(token: String) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	verify_player.emit(player_id, token)
	pass


@rpc("reliable")
func return_token_verification_results(player_id: int, result: bool) -> void:
	print("return_token_verification_results: ", player_id, " result: ", result)
	rpc_id(player_id, "return_token_verification_results", player_id, result)
	pass
