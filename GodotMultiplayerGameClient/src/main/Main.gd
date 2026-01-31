extends Node

@export var show_icon: Texture2D
@export var hide_icon: Texture2D

# screens
@onready var register_screen: Control = %RegisterScreen
@onready var login_screen: Control = %LoginScreen
# login screen
@onready var username: LineEdit = %Username
@onready var password: LineEdit = %Password
@onready var login_button: Button = %LoginButton
@onready var create_account_button: Button = %CreateAccountButton
@onready var show_hide_login_password: TextureButton = %ShowHideLoginPassword
@onready var login_username_error: HBoxContainer = %LoginUsernameError
@onready var login_username_error_label: Label = %LoginUsernameErrorLabel
@onready var login_password_error: HBoxContainer = %LoginPasswordError
@onready var login_password_error_label: Label = %LoginPasswordErrorLabel
@onready var login_overall_error: HBoxContainer = %LoginOverallError
@onready var login_overall_error_label: Label = %LoginOverallErrorLabel
# register screen
@onready var new_username: LineEdit = %NewUsername
@onready var email_address: LineEdit = %EmailAddress
@onready var new_password: LineEdit = %NewPassword
@onready var repeat_password: LineEdit = %RepeatPassword
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton
@onready var show_hide_register_password: TextureButton = %ShowHideRegisterPassword
@onready var show_hide_register_repeat_password: TextureButton = %ShowHideRegisterRepeatPassword
@onready var register_username_error: HBoxContainer = %RegisterUsernameError
@onready var register_username_error_label: Label = %RegisterUsernameErrorLabel
@onready var register_email_error: HBoxContainer = %RegisterEmailError
@onready var register_email_error_label: Label = %RegisterEmailErrorLabel
@onready var register_password_error: HBoxContainer = %RegisterPasswordError
@onready var register_password_error_label: Label = %RegisterPasswordErrorLabel
@onready var register_repeat_password_error: HBoxContainer = %RegisterRepeatPasswordError
@onready var register_repeat_password_error_label: Label = %RegisterRepeatPasswordErrorLabel
@onready var register_overall_error: HBoxContainer = %RegisterOverallError
@onready var register_overall_error_label: Label = %RegisterOverallErrorLabel


func _ready():
	Gateway.player_authentication_failed.connect(_on_login_failed)
	ServerCommunication.player_login_verification_failed.connect(_on_login_failed)
	ServerCommunication.player_login_verification_success.connect(_on_login_success)
	Gateway.player_created_successfully.connect(_on_back_button_pressed)
	Gateway.player_creation_failed.connect(_on_create_account_failed)
	show_hide_login_password.toggled.connect(_on_show_hide_login_password_toggle)
	show_hide_register_password.toggled.connect(_on_show_hide_register_password_toggle)
	show_hide_register_repeat_password.toggled.connect(_on_show_hide_register_repeat_password_toggle)
	back_button.button_up.connect(_on_show_hide_register_password_toggle.bind(false))
	back_button.button_up.connect(_on_show_hide_register_repeat_password_toggle.bind(false))
	create_account_button.button_up.connect(_on_show_hide_login_password_toggle.bind(false))
	hide_errors()
	login_screen.show()
	register_screen.hide()
	pass


func hide_errors() -> void:
	login_username_error.hide()
	login_password_error.hide()
	login_overall_error.hide()
	register_username_error.hide()
	register_email_error.hide()
	register_password_error.hide()
	register_repeat_password_error.hide()
	register_overall_error.hide()
	pass


func _on_login_failed(message: String = "Login failed") -> void:
	login_button.disabled = false
	create_account_button.disabled = false
	login_overall_error_label.text = message
	login_overall_error.show()
	pass


func _on_create_account_failed(message: String = "Account creation failed") -> void:
	confirm_button.disabled = false
	back_button.disabled = false
	register_overall_error_label.text = message
	register_overall_error.show()
	pass


func _on_login_success() -> void:
	get_tree().change_scene_to_file("res://src/main/game_scene.tscn")
	pass


func _on_login_button_pressed() -> void:
	hide_errors()
	var has_error := false
	if username.text == "":
		login_username_error_label.text = "Please enter your username"
		login_username_error.show()
		has_error = true
	if password.text == "":
		login_password_error_label.text = "Please enter your password"
		login_password_error.show()
		has_error = true

	if not has_error:
		print("Attempting to login via GatewayServer")
		Gateway.connect_to_server(username.text, password.text, false)
		login_button.disabled = true
		create_account_button.disabled = true
	pass


func _on_create_account_button_pressed() -> void:
	hide_errors()
	login_screen.hide()
	register_screen.show()
	pass


func _on_back_button_pressed() -> void:
	hide_errors()
	login_screen.show()
	register_screen.hide()
	pass


func _on_confirm_button_pressed() -> void:
	hide_errors()
	var has_error := false
	
	var username_regex = RegEx.new()
	username_regex.compile("^[a-zA-Z0-9_]{3,16}$")
	
	var password_regex = RegEx.new()
	# Min 8, Max 16, 1 Upper, 1 Lower, 1 Number, 1 Special
	password_regex.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,16}$")
	
	var email_regex = RegEx.new()
	email_regex.compile("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$")

	if new_username.text == "" or not username_regex.search(new_username.text):
		register_username_error_label.text = "Username must be 3-16 characters (alphanumeric/underscore)"
		register_username_error.show()
		has_error = true
		
	if email_address.text == "" or not email_regex.search(email_address.text):
		register_email_error_label.text = "Enter a valid email address"
		register_email_error.show()
		has_error = true
		
	if new_password.text == "" or not password_regex.search(new_password.text):
		register_password_error_label.text = "8-16 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char"
		register_password_error.show()
		has_error = true
		
	if new_password.text != repeat_password.text:
		register_repeat_password_error_label.text = "Passwords do not match"
		register_repeat_password_error.show()
		has_error = true
		
	if not has_error:
		confirm_button.disabled = true
		back_button.disabled = true
		Gateway.connect_to_server(new_username.text, new_password.text, true, email_address.text)
	pass


func _on_show_hide_login_password_toggle(toggle_state: bool) -> void:
	show_hide_login_password.set_pressed_no_signal(toggle_state)
	password.secret = not toggle_state
	show_hide_login_password.texture_normal = show_icon if toggle_state else hide_icon
	pass


func _on_show_hide_register_password_toggle(toggle_state: bool) -> void:
	show_hide_register_password.set_pressed_no_signal(toggle_state)
	new_password.secret = not toggle_state
	show_hide_register_password.texture_normal = show_icon if toggle_state else hide_icon
	pass


func _on_show_hide_register_repeat_password_toggle(toggle_state: bool) -> void:
	show_hide_register_repeat_password.set_pressed_no_signal(toggle_state)
	repeat_password.secret = not toggle_state
	show_hide_register_repeat_password.texture_normal = show_icon if toggle_state else hide_icon
	pass
