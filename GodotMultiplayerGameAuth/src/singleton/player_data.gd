extends Node

@onready var BACKEND_URL := OS.get_environment("BACKEND_URL") if OS.has_environment("BACKEND_URL") else "http://localhost:8080"


func api_register(username: String, email: String, password_hash: String, salt: String) -> Dictionary:
	"""Calls the Go Backend to register a new user
	"""
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var body = JSON.stringify({
		"username": username,
		"email": email,
		"password_hash": password_hash,
		"salt": salt
	})
	
	var headers = ["Content-Type: application/json"]
	var err = http_request.request(BACKEND_URL + "/register", headers, HTTPClient.METHOD_POST, body)
	
	if err != OK:
		push_error("An error occurred in the HTTP request.")
		http_request.queue_free()
		return {"result": false, "message": 1}
		
	var response = await http_request.request_completed
	http_request.queue_free()
	
	var response_code = response[1]
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	if response_code == 201:
		return {"result": true, "message": 3}
	else:
		if response_body and response_body.has("error") and "unique constraint" in response_body["error"]:
			return {"result": false, "message": 2} # Existing user
		return {"result": false, "message": 1} # General failure


func api_get_user(username: String) -> Dictionary:
	"""Calls the Go Backend to fetch user data for authentication
	"""
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var body = JSON.stringify({
		"username": username
	})
	
	var headers = ["Content-Type: application/json"]
	var err = http_request.request(BACKEND_URL + "/login", headers, HTTPClient.METHOD_POST, body)
	
	if err != OK:
		push_error("An error occurred in the HTTP request.")
		http_request.queue_free()
		return {}
		
	var response = await http_request.request_completed
	http_request.queue_free()
	
	var response_code = response[1]
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	if response_code == 200:
		# Return in format expected by Authenticate.gd
		# Password in DB is what was previously hashed_password (Password + salt hashed multiple times)
		# Salt is the original salt.
		return {
			"Password": response_body["password_hash"],
			"Salt": response_body["salt"]
		}
	else:
		return {}
