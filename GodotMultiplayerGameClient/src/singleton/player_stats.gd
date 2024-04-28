extends Node

var strength := "0"
var vitality := "0"
var dexterity := "0"
var intelligence := "0"
var wisdom := "0"


func load_player_stats(stats) -> void:
	strength = str(stats.strength)
	vitality = str(stats.vitality)
	dexterity = str(stats.dexterity)
	intelligence = str(stats.intelligence)
	wisdom = str(stats.wisdom)
	pass
