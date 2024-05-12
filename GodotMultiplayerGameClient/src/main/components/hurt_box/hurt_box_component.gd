extends Area2D
class_name HurtBoxComponent

@export var health_component: HealthComponent


func take_damage(dmg: float) -> void:
	print("Take DMG")
	health_component.take_damage(dmg)
	pass
