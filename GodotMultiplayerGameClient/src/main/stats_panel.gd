extends Control


@onready var strength: Label = %Strength
@onready var vitality: Label = %Vitality
@onready var dexterity: Label = %Dexterity
@onready var intelligence: Label = %Intelligence
@onready var wisdom: Label = %Wisdom


func _ready() -> void:
	pass


func show_player_stats() -> void:
	visible = true
	load_player_stats()
	pass


func hide_player_stats() -> void:
	visible = false
	pass


func load_player_stats() -> void:
	strength.text = PlayerStats.strength
	vitality.text = PlayerStats.vitality
	dexterity.text = PlayerStats.dexterity
	intelligence.text = PlayerStats.intelligence
	wisdom.text = PlayerStats.wisdom
	pass
