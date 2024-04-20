extends Node

var network := ENetMultiplayerPeer.new()
var server_ip := "127.0.0.1"
var server_port := 1909

func _ready() -> void:
    connect_to_server()

func connect_to_server() -> void:
    network.create_client(server_ip, server_port)
    multiplayer.multiplayer_peer = network

    # network.peer_connected.connect(_on_peer_connected)
    # network.peer_disconnected.connect(_on_peer_disconnected)

    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_to_server() -> void:
    print("Connected to server")

func _on_connection_failed() -> void:
    print("Connection failed")

func _on_server_disconnected() -> void:
    print("Server disconnected")

# func _on_peer_connected(id: int) -> void:
#     print("Peer connected: ", id)

# func _on_peer_disconnected(id: int) -> void:
#     print("Peer disconnected: ", id)
