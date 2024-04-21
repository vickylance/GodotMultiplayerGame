extends Node

func _ready():
	await ServerCommunication.player_connected
	ServerCommunication.fetch_skill_damage("Ice Spear", get_instance_id())
	pass


func set_damage(skill_damage: int) -> void:
	print("DMG: ", skill_damage)
	pass
