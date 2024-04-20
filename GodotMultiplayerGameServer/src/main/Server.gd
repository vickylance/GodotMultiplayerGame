extends Node

var network := ENetMultiplayerPeer.new()
var port := 1909
var max_players := 100


func _ready() -> void:
	start_server()


func start_server() -> void:
	network.create_server(port, max_players)
	multiplayer.multiplayer_peer = network
	print("Server started on port: " + str(port))
	network.peer_connected.connect(_peer_connected)
	network.peer_disconnected.connect(_peer_disconnected)
	pass


func _peer_connected(player_id) -> void:
	print("Player connected: " + str(player_id))
	pass


func _peer_disconnected(player_id) -> void:
	print("Player disconnected: " + str(player_id))
	pass

