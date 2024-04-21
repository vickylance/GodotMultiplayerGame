extends Node

signal player_connected

var network := ENetMultiplayerPeer.new()
var server_ip := "127.0.0.1"
var server_port := 1909

func _ready() -> void:
	connect_to_server()

func connect_to_server() -> void:
	var err := network.create_client(server_ip, server_port)
	assert(err == OK)
	multiplayer.multiplayer_peer = network
	
	print("Multiplayer ID: ", multiplayer.get_unique_id())

	# network.peer_connected.connect(_on_peer_connected)
	# network.peer_disconnected.connect(_on_peer_disconnected)

	err = multiplayer.connected_to_server.connect(_on_connected_to_server)
	assert(err == OK)
	err = multiplayer.connection_failed.connect(_on_connection_failed)
	assert(err == OK)
	err = multiplayer.server_disconnected.connect(_on_server_disconnected)
	assert(err == OK)

func _on_connected_to_server() -> void:
	print("Connected to server")
	player_connected.emit()

func _on_connection_failed() -> void:
	print("Connection failed")

func _on_server_disconnected() -> void:
	print("Server disconnected")

# func _on_peer_connected(id: int) -> void:
#     print("Peer connected: ", id)

# func _on_peer_disconnected(id: int) -> void:
#     print("Peer disconnected: ", id)

@rpc
func fetch_skill_damage(skill_name: String, instance_id: int) -> void:
	fetch_skill_damage.rpc_id(1, skill_name, instance_id)

@rpc
func return_skill_damage(skill_damage, requester) -> void:
	var requester_instance = instance_from_id(requester)
	if requester_instance.has_method("set_damage"):
		requester_instance.set_damage(skill_damage)
