extends CharacterBody2D

@export var hitpoints: int

@onready var hit_box: Area2D = %HitBox
@onready var hurt_box: HurtBoxComponent = %HurtBox
@onready var detection_area: Area2D = %DetectionArea
@onready var muzzle: Marker2D = %Muzzle
@onready var health_component: HealthComponent = %HealthComponent
@onready var damage_popup_component: DamagePopupComponent = %DamagePopupComponent

var motion := Vector2.ZERO
var player_targets = []
var closest_target
var close_target_threshold
var chase_player := false


func _ready() -> void:
	health_component.dead.connect(kill)
	hurt_box.damage_taken.connect(damage_taken)
	pass


func _physics_process(_delta: float) -> void:
	#if chase_player and closest_target:
		#position += (closest_target.position - position) / 50
		#look_at(closest_target.position)
	#check_closest_target()
	#move_and_collide(motion)
	move_and_slide()
	pass


func check_closest_target() -> void:
	for target in player_targets:
		if global_position.distance_squared_to(target.global_position) > 50:
			closest_target = target
	pass


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_targets.append(body)
		print("Target added: ", player_targets)
	pass


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_targets.erase(body)
		closest_target = null
		print("Target removed: ", player_targets)
	pass


func kill() -> void:
	queue_free()
	pass


func damage_taken(dmg: float) -> void:
	damage_popup_component.popup(dmg)
	pass
