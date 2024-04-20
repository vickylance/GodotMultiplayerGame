extends Node

func _ready():
	print("Main")
	print(multiplayer.get_instance_id())
	print(get_instance_id())
	print("---MAIN")
	await ServerCommunication.player_connected
	ServerCommunication.fetch_skill_damage("Ice Spear", get_instance_id())
	print("End main")
	pass


func set_damage(skill_damage: int) -> void:
	print("SKILL: ", skill_damage)
	pass
