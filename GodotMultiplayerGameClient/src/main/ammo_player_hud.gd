extends Label


@export var weapon_manager_component: WeaponManagerComponent


func _process(_delta: float) -> void:
	var max_ammo := weapon_manager_component.current_weapon.max_ammo
	var current_ammo := weapon_manager_component.current_weapon.current_ammo
	text = str(current_ammo) + " / " + str(max_ammo)
	pass
