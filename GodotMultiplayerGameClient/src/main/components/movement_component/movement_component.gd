extends Node

@export var player: CharacterBody2D
@export var move_speed := 200
@export var acceleration := 500
@export var friction := 500


func _physics_process(delta: float) -> void:
	control(delta)
	player.move_and_slide()


func control(delta: float) -> void:
	player.look_at(player.get_global_mouse_position())
	var input_axis = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")).normalized()
	if input_axis != Vector2.ZERO:
		player.velocity = player.velocity.move_toward(input_axis * move_speed, acceleration * delta)
	else: # deceleration
		player.velocity = player.velocity.move_toward(Vector2.ZERO, friction * delta)
	pass
