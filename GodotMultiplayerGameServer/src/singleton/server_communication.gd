extends Node

signal verify_player(player_id: int, token: String)


@rpc("any_peer", "reliable")
func fetch_skill_damage(skill_name: String, requester_id: int) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	var damage: int = Combat.fetch_skill_damage(skill_name)
	return_skill_damage.rpc_id(player_id, damage, requester_id)
	print("Sending: " + str(damage) + " damage to player " + str(player_id))
	pass


@rpc("reliable")
func return_skill_damage(_skill_damage, _requester) -> void:
	# Only implemented in client
	pass


@rpc("any_peer", "reliable")
func fetch_player_stats() -> void:
	var player_id := multiplayer.get_remote_sender_id()
	var player_stats = get_node("/root/Server/" + str(player_id)).player_stats # TODO: Refactor better
	print("Got the player stats: ", player_stats)
	return_player_stats.rpc_id(player_id, player_stats)
	pass


@rpc("reliable")
func return_player_stats(_stats) -> void:
	# Implemented on the client
	pass


@rpc("reliable")
func fetch_token(player_id: int) -> void:
	fetch_token.rpc_id(player_id, player_id)
	pass


@rpc("any_peer", "reliable")
func return_token(token: String) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	verify_player.emit(player_id, token)
	pass


@rpc("reliable")
func return_token_verification_results(player_id: int, result: bool) -> void:
	print("return_token_verification_results: ", player_id, " result: ", result)
	return_token_verification_results.rpc_id(player_id, player_id, result)
	if result == true:
		spawn_other_player.rpc_id(0, player_id, Vector2(450, 220))
	pass


@rpc("reliable")
func spawn_other_player(_player_id: int, _spawn_position: Vector2) -> void:
	pass


@rpc("reliable")
func despawn_other_player(_player_id: int) -> void:
	pass
