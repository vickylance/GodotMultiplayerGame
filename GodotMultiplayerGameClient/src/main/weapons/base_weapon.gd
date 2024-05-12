extends Node2D
class_name BaseWeapon

signal weapon_ammo_changed(new_ammo_count: int)
signal weapon_out_of_ammo

@export var bullet: PackedScene
@export var max_ammo: int = 10
@export var semi_auto: bool = true

var current_ammo: int = max_ammo: set = _set_current_ammo

func _set_current_ammo(new_ammo: int):
	var actual_ammo = clamp(new_ammo, 0, max_ammo)
	if actual_ammo != current_ammo:
		current_ammo = actual_ammo
		if current_ammo == 0:
			weapon_ammo_changed.emit()
		weapon_ammo_changed.emit(current_ammo)

@onready var end_of_gun: Marker2D = %EndOfGun
@onready var attack_cooldown : Timer = %AttackCooldown
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var muzzle_flash: Sprite2D = %MuzzleFlash
@onready var gun_fire_sound: AudioStreamPlayer2D= %GunFireSound
@onready var reload_sound: AudioStreamPlayer2D = %ReloadSound
@onready var out_of_ammo_sound: AudioStreamPlayer2D = %OutOfAmmoSound


func _ready() -> void:
	muzzle_flash.hide()
	current_ammo = max_ammo


func start_reload() -> void:
	animation_player.play("reload")
	reload_sound.play()


func _stop_reload() -> void: # Called from animation player
	current_ammo = max_ammo
	weapon_ammo_changed.emit(current_ammo)


func shoot() -> void:
	if current_ammo <= 0:
		weapon_out_of_ammo.emit()
		out_of_ammo_sound.play()
	elif current_ammo != 0 and attack_cooldown.is_stopped() and bullet != null:
		var bullet_instance = bullet.instantiate()
		bullet_instance.transform = end_of_gun.global_transform
		get_tree().root.add_child(bullet_instance)
		print(bullet_instance)
		#var direction = (end_of_gun.global_position - global_position).normalized()
		# GlobalSignals.bullet_fired.emit(bullet_instance, team, end_of_gun.global_position, direction)
		attack_cooldown.start()
		animation_player.play("muzzle_flash")
		current_ammo = current_ammo - 1
		gun_fire_sound.pitch_scale = randf_range(0.9, 1.1)
		gun_fire_sound.play()

