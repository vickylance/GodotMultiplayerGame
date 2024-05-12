extends Node2D
class_name Bullet

@export var dmg: int

@onready var hit_box: HitBoxComponent = %HitBox

var speed: int = 1000


func _ready() -> void:
	hit_box.dmg = dmg
	hit_box.target_hit.connect(kill_bullet)
	pass


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	pass


func _on_kill_timer_timeout() -> void:
	kill_bullet()
	pass


func kill_bullet() -> void:
	queue_free()
