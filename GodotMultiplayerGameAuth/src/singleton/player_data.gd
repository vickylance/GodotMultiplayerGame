extends Node

var player_data: Dictionary = {}


func _ready() -> void:
	print(OS.get_user_data_dir())
	if not DirAccess.dir_exists_absolute("user://data"):
		DirAccess.make_dir_recursive_absolute("user://data")
	load_player_ids()
	pass


func load_player_ids() -> void:
	var player_data_file := FileAccess.open(("user://data/player_data.json"), FileAccess.READ)
	player_data = JSON.parse_string(player_data_file.get_as_text())
	player_data_file.close()
	pass


func save_player_ids() -> void:
	var player_data_file := FileAccess.open(("user://data/player_data.json"), FileAccess.WRITE)
	player_data_file.store_line(JSON.stringify(player_data))
	player_data_file.close()
	pass
