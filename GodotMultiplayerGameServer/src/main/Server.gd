extends Node

var network := ENetMultiplayerPeer.new()
var port := 1909
var max_players := 100


func _ready() -> void:
	start_server()


func start_server() -> void:
	var err := network.create_server(port, max_players)
	assert(err == OK)
	multiplayer.multiplayer_peer = network
	print("Server started on port: " + str(port))

	print("Multiplayer ID: ", multiplayer.get_unique_id())	
	err = network.peer_connected.connect(_peer_connected)
	assert(err == OK)
	err = network.peer_disconnected.connect(_peer_disconnected)
	assert(err == OK)
	pass


func _peer_connected(player_id) -> void:
	print("Player connected: " + str(player_id))
	pass


func _peer_disconnected(player_id) -> void:
	print("Player disconnected: " + str(player_id))
	pass

