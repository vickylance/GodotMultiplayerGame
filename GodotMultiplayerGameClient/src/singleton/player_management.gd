extends Node

@export var player_template: PackedScene


func spawn_other_player(player_id: int, spawn_point: Vector2) -> void:
	if multiplayer.get_unique_id() == player_id:
		return
	var other_players_container: Node = get_node("/root/GameScene/OtherPlayers")
	if not other_players_container:
		printerr("Not in GameScene")
		return
	var new_player: PlayerTemplate = player_template.instantiate()
	new_player.position = spawn_point
	new_player.name = str(player_id)
	other_players_container.add_child(new_player)
	pass


func despawn_other_player(player_id: int) -> void:
	var other_players_container: Node = get_node("/root/GameScene/OtherPlayers")
	if not other_players_container:
		printerr("Not in GameScene despawn")
		return
	var other_player = other_players_container.get_node(str(player_id))
	if other_player:
		other_player.queue_free()
	pass
