extends Marker2D
class_name DamageNumberComponent

@onready var damage_number_label: Label = %DamageNumberLabel


func set_dmg_value(dmg: float = 0) -> void:
	if damage_number_label:
		damage_number_label.text = str(dmg)
	pass
