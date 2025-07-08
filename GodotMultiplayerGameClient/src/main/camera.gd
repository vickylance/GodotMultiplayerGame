extends Camera2D

@export var target: Player


func _physics_process(_delta: float) -> void:
	if target != null:
		global_position = target.global_position
	pass
