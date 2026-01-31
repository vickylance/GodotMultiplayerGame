extends Node

var player_data: Dictionary = {}
const DATA_FOLDER = "user://data/"
const PLAYER_DATA = "player_data.json"

func _ready() -> void:
	print(OS.get_user_data_dir())
	if not DirAccess.dir_exists_absolute(DATA_FOLDER):
		DirAccess.make_dir_recursive_absolute(DATA_FOLDER)
	load_player_ids()
	pass


func load_player_ids() -> void:
	# Check if file exists if not create
	if not FileAccess.file_exists(DATA_FOLDER + PLAYER_DATA):
		save_player_ids()
	
	var player_data_file := FileAccess.open(DATA_FOLDER + PLAYER_DATA, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		var error_str = error_string(FileAccess.get_open_error())
		push_error("Couldn't open file because: %s" % error_str)
	player_data = JSON.parse_string(player_data_file.get_as_text())
	player_data_file.close()
	pass


func save_player_ids() -> void:
	var player_data_file := FileAccess.open(DATA_FOLDER + PLAYER_DATA, FileAccess.WRITE)
	player_data_file.store_line(JSON.stringify(player_data))
	player_data_file.close()
	pass
