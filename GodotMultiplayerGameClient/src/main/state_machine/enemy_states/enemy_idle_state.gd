extends State
class_name EnemyPatrolState

@export var enemy: CharacterBody2D
@export var patrol_area: CollisionShape2D
@export var move_speed: float

var move_direction: Vector2
var wander_time: float


func randomize_wander() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	pass


func enter() -> void:
	var x: CircleShape2D = patrol_area.shape
	print(x.radius)
	randomize_wander()
	pass


func update(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
	pass


func physics_update(delta: float) -> void:
	if enemy:
		enemy.velocity = move_direction * move_speed * delta
	pass
