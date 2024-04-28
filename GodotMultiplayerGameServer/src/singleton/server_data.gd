extends Node

var skill_data: Dictionary # TODO: Convert into a resource
var test_data: Dictionary = { # TODO: Convert into a resource
	"stats": {
		"strength": 42,
		"vitality": 68,
		"dexterity": 37,
		"intelligence": 24,
		"wisdom": 17
	}
}


func _ready() -> void:
	var skill_data_file := FileAccess.open(("res://data/skill_data.json"), FileAccess.READ)
	skill_data = JSON.parse_string(skill_data_file.get_as_text())
	skill_data_file.close()
	pass
