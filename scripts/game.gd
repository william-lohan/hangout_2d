class_name Game

extends Node

@onready var connectionUI: Control = $ConnectionUI
@onready var serverInput: LineEdit = $ConnectionUI/VBoxContainer/ServerInput
@onready var portInput: LineEdit = $ConnectionUI/VBoxContainer/PortInput
@onready var playerSpawn: Spawn2D = $World2D/Map/PlayerSpawn

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true # pause until connected
	
	# Dedicated server
	if is_headless():
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(4433)
		var status = peer.get_connection_status()
		#print(status)
		if status != MultiplayerPeer.CONNECTION_DISCONNECTED:
			start_with_peer(peer)
		
		if OS.is_debug_build():
			# comment out to debug multiplayer
			#_on_host_button_pressed()
			pass

func _exit_tree():
	if multiplayer.is_server():
		multiplayer.peer_connected.disconnect(add_player)
		multiplayer.peer_disconnected.disconnect(remove_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func is_headless() -> bool:
	return DisplayServer.get_name() == "headless"

func add_player(id: int):
	print("add: " + str(id))
	playerSpawn.spawn(id)

func remove_player(id: int):
	print("remove: " + str(id))
	#playerSpawnPath.get_node(str(id)).queue_free()

func start_with_peer(peer: MultiplayerPeer):
	multiplayer.multiplayer_peer = peer
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(remove_player)
		for id in multiplayer.get_peers():
			print(id)
			add_player(id)
		if not is_headless():
			add_player(1)
	connectionUI.hide()
	get_tree().paused = false

func _on_connect_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(serverInput.text, int(portInput.text))
	var status = peer.get_connection_status()
	#print(status)
	if status != MultiplayerPeer.CONNECTION_DISCONNECTED:
		start_with_peer(peer)

func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(portInput.text))
	var status = peer.get_connection_status()
	
	#print(status)
	if status != MultiplayerPeer.CONNECTION_DISCONNECTED:
		start_with_peer(peer)
