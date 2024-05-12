extends Node

@onready var lo = %LightOccluder2D

func _ready() -> void:
	lo.occluder_light_mask = 0
	
