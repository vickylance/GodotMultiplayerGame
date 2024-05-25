extends Marker2D
class_name DamagePopupComponent

var damage_number_component = preload("res://src/main/components/ui/damage_number_component/damage_number_component.tscn")


func _ready() -> void:
	randomize()
	pass


func popup(dmg: float) -> void:
	var damage: DamageNumberComponent = damage_number_component.instantiate()
	damage.position = global_position
	var tween = get_tree().create_tween()
	tween.tween_property(damage, "position", global_position + _get_direction(), 0.75)
	get_tree().current_scene.add_child(damage)
	damage.set_dmg_value(dmg)
	pass


func _get_direction() -> Vector2:
	return Vector2(randf_range(-1, 1), -randf()) * 16
