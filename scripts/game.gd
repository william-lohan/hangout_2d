extends Node

@onready var connectionUI: Control = $ConnectionUI
@onready var serverInput: LineEdit = $ConnectionUI/VBoxContainer/Server
@onready var portInput: LineEdit = $ConnectionUI/VBoxContainer/Port
@onready var playerSpawnPath: Node = $World2D/PlayerSpawnPath

var playerScn = preload("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true # pause until connected
	
	# Dedicated server
	if is_headless():
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(4433)
		var status = peer.get_connection_status()
		print(status)
		if status != MultiplayerPeer.CONNECTION_DISCONNECTED:
			start_with_peer(peer)

func _exit_tree():
	if multiplayer.is_server():
		multiplayer.peer_connected.disconnect(add_player)
		multiplayer.peer_connected.disconnect(remove_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func is_headless() -> bool:
	return DisplayServer.get_name() == "headless"

func add_player(id: int):
	var player = playerScn.instantiate()
	player.name = str(id)
	playerSpawnPath.add_child(player)

func remove_player(id: int):
	playerSpawnPath.get_node(str(id)).queue_free()

func start_with_peer(peer: MultiplayerPeer):
	multiplayer.multiplayer_peer = peer
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_connected.connect(remove_player)
		for id in multiplayer.get_peers():
			add_player(id)
		if not is_headless():
			add_player(1)
	connectionUI.hide()
	get_tree().paused = false
	

func _on_connect_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(serverInput.text, int(portInput.text))
	var status = peer.get_connection_status()
	print(status)
	if status != MultiplayerPeer.CONNECTION_DISCONNECTED:
		start_with_peer(peer)


func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(portInput.text))
	var status = peer.get_connection_status()
	print(status)
	if status != MultiplayerPeer.CONNECTION_DISCONNECTED:
		start_with_peer(peer)
