extends Node
class_name HealthComponent

@export var max_hp: float = 80.0

@onready var current_hp: float = max_hp

signal dead()
signal damaged(health: float)
signal healed(health: float)


func take_damage(damage: float) -> void:
	if current_hp - damage > 0:
		current_hp -= damage
		damaged.emit(current_hp)
	elif current_hp - damage <= 0:
		current_hp = 0
		dead.emit()
		damaged.emit(current_hp)
	pass


func heal(heal_amount: float) -> void:
	current_hp = clampf(current_hp + heal_amount, 0, max_hp)
	healed.emit(current_hp)
	pass
