extends Node

var player_data: Dictionary

func _ready() -> void:
	var player_data_file := FileAccess.open(("res://data/player_data.json"), FileAccess.READ)
	player_data = JSON.parse_string(player_data_file.get_as_text())
	player_data_file.close()
	pass
