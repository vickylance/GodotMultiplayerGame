extends Area2D
class_name HurtBoxComponent

@export var health_component: HealthComponent

signal damage_taken(dmg: float)


func take_damage(dmg: float) -> void:
	health_component.take_damage(dmg)
	damage_taken.emit(dmg)
	pass
