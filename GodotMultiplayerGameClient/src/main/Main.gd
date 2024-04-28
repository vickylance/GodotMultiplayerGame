extends Node

@onready var login_button: Button = %LoginButton
@onready var password: LineEdit = %Password
@onready var username: LineEdit = %Username


func _ready():
	Gateway.player_authentication_failed.connect(_on_login_failed)
	ServerCommunication.player_login_verification_failed.connect(_on_login_failed)
	ServerCommunication.player_login_verification_success.connect(_on_login_success)
	pass


func _on_login_button_pressed() -> void:
	# TODO: Validate username and password field
	if username.text == "" or password.text == "":
		print("Please provide valid input for username and password")
	else:
		print("Attempting to login via GatewayServer")
		Gateway.connect_to_server(username.text, password.text)
		login_button.disabled = true
	pass


func _on_login_failed() -> void:
	login_button.disabled = false
	pass


func _on_login_success() -> void:
	get_tree().change_scene_to_file("res://src/main/game_scene.tscn")
	pass
