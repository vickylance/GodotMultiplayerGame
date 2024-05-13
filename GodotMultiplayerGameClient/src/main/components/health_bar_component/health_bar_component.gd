extends ProgressBar

@export var health_component: HealthComponent

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $DamageBar

var health: float = 0 : set = set_health


func set_health(new_health) -> void:
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		queue_free()
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health
	pass


func _ready() -> void:
	init_health(health_component.max_hp, health_component.current_hp)
	health_component.damaged.connect(func (x): health = x)
	health_component.healed.connect(func (x): health = x)
	pass


func _process(_delta: float) -> void:
	rotation_degrees = 0
	pass


func init_health(max_hp: float, current_hp: float) -> void:
	health = current_hp
	max_value = max_hp
	value = current_hp
	damage_bar.max_value = max_hp
	damage_bar.value = current_hp
	pass


func _on_timer_timeout() -> void:
	damage_bar.value = health
	pass
