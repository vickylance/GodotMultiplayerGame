extends CharacterBody2D
class_name Player

@export var bullet: PackedScene
@onready var health_component: HealthComponent = %HealthComponent


func _ready() -> void:
	health_component.dead.connect(kill)
	pass


#func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("shoot"):
		#shoot()
	#pass
#
#
#func shoot():
	#var bullet = Bullet.instantiate()
	#get_tree().root.add_child(bullet)
	#bullet.transform = $Muzzle.global_transform


func kill() -> void:
	get_tree().reload_current_scene()
	pass
