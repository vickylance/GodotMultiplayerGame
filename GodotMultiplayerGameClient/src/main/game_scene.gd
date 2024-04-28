extends Control

@onready var stats_panel: Control = %StatsPanel
var show_stats_toggle := false


func _ready() -> void:
	ServerCommunication.fetch_skill_damage("Ice Spear", get_instance_id())
	ServerCommunication.fetch_player_stats()
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			show_stats_toggle = !show_stats_toggle
			if show_stats_toggle:
				stats_panel.show_player_stats()
			else:
				stats_panel.hide_player_stats()
			pass


func set_damage(skill_damage: int) -> void: # This function gets called from the above ServerCommunication with the help of get_instance_id()
	print("DMG: ", skill_damage)
	pass
