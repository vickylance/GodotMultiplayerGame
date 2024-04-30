extends Node

# screens
@onready var register_screen: Control = %RegisterScreen
@onready var login_screen: Control = %LoginScreen
# login screen
@onready var username: LineEdit = %Username
@onready var password: LineEdit = %Password
@onready var login_button: Button = %LoginButton
@onready var create_account_button: Button = %CreateAccountButton
# register screen
@onready var new_username: LineEdit = %NewUsername
@onready var email_address: LineEdit = %EmailAddress
@onready var new_password: LineEdit = %NewPassword
@onready var repeat_password: LineEdit = %RepeatPassword
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton


func _ready():
	Gateway.player_authentication_failed.connect(_on_login_failed)
	ServerCommunication.player_login_verification_failed.connect(_on_login_failed)
	ServerCommunication.player_login_verification_success.connect(_on_login_success)
	Gateway.player_created_successfully.connect(_on_back_button_pressed)
	Gateway.player_creation_failed.connect(_on_create_account_failed)
	login_screen.show()
	register_screen.hide()
	pass


func _on_login_failed() -> void:
	login_button.disabled = false
	create_account_button.disabled = false
	pass


func _on_create_account_failed() -> void:
	confirm_button.disabled = false
	back_button.disabled = false
	pass


func _on_login_success() -> void:
	get_tree().change_scene_to_file("res://src/main/game_scene.tscn")
	pass


func _on_login_button_pressed() -> void:
	# TODO: Validate username and password field
	if username.text == "" or password.text == "":
		print("Please provide valid input for username and password")
	else:
		print("Attempting to login via GatewayServer")
		Gateway.connect_to_server(username.text, password.text, false)
		login_button.disabled = true
		create_account_button.disabled = true
	pass


func _on_create_account_button_pressed() -> void:
	login_screen.hide()
	register_screen.show()
	pass


func _on_back_button_pressed() -> void:
	login_screen.show()
	register_screen.hide()
	pass


func _on_confirm_button_pressed() -> void:
	if new_username.text == "":
		print("Enter your new username")
	elif email_address.text == "":
		print("Enter a valid email address")
	elif new_password.text == "" or repeat_password.text == "":
		print("Enter a valid new password and repeat password")
	elif new_password.text != repeat_password.text:
		print("New password and repeat password are not matching")
	elif new_password.text.length() < 10:
		print("Enter atleast 9 characters for password")
	else:
		confirm_button.disabled = true
		back_button.disabled = true
		Gateway.connect_to_server(new_username.text, new_password.text, true)
	pass
