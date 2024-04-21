extends Node


@rpc("any_peer", "reliable")
func fetch_skill_damage(skill_name: String, requester_id: int) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	var damage: int = Combat.fetch_skill_damage(skill_name)
	rpc_id(player_id, "return_skill_damage", damage, requester_id)
	print("Sending: " + str(damage) + " damage to player " + str(player_id))
	pass


@rpc
func return_skill_damage(_skill_damage, _requester) -> void:
	# Only implemented in client
	pass
