extends Area2D
class_name HitBoxComponent

signal target_hit
@export var dmg: float


func _on_area_entered(area: Area2D) -> void:
	target_hit.emit()
	print(area)
	if area is HurtBoxComponent:
		area.take_damage(dmg)
	pass
