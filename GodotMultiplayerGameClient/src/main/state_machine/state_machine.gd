extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(on_child_state_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		
	print(current_state)
	pass


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	pass


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	pass


func on_child_state_transition(state: State, new_state_name: String) -> void:
	if state != current_state: return
	var new_state: State = states.get(new_state_name.to_lower())
	if not new_state: return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
	pass
