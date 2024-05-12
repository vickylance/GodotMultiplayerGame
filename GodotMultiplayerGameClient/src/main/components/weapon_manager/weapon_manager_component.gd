extends Node

signal weapon_changed(new_weapon)

@export var gun_pos: RemoteTransform2D
@onready var current_weapon: BaseWeapon = $Pistol

var weapons: Array = []


func _ready() -> void:
	weapons = get_children()
	for weapon in weapons:
		weapon.hide()
	print(current_weapon.name)
	current_weapon.show()
	
	print(gun_pos.get_path_to(current_weapon))
	gun_pos.remote_path = current_weapon.get_path()


func _physics_process(_delta: float) -> void:
	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		current_weapon.shoot()


#func initialize(team: int) -> void:
	#for weapon in weapons:
		#weapon.initialize(team)


func get_current_weapon() -> BaseWeapon:
	return current_weapon


func switch_weapon(weapon: BaseWeapon):
	if weapon == current_weapon:
		return
	current_weapon.hide()
	weapon.show()
	current_weapon = weapon
	gun_pos.remote_path = current_weapon.get_path()
	weapon_changed.emit(current_weapon)


func _unhandled_input(event: InputEvent) -> void:
	if current_weapon.semi_auto and event.is_action_released("shoot"):
		current_weapon.shoot()
	elif event.is_action_released("reload"):
		current_weapon.start_reload()
	elif event.is_action_released("weapon_1"):
		switch_weapon(weapons[0])
	elif event.is_action_released("weapon_2"):
		switch_weapon(weapons[1])
