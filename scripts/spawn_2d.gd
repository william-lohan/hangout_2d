class_name Spawn2D

extends Node2D

var _index: int = 0

var _scn: PackedScene = preload("res://player.tscn")

#@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready():
	#spawner.spawn_path = get_points()[_index].get_path()
	pass

func get_points() -> Array[Node2D]:
	var points: Array[Node2D] = []
	for child in get_children():
		if child is Node2D:
			points.append(child)
	return points

func spawn(id: int):
	var points: Array[Node2D] = get_points()
	if _index >= points.size():
		_index = 0
	var point = points[_index]
	
	#spawner.spawn_path = point.get_path()
	
	var instance = _scn.instantiate()
	instance.id = id
	point.add_child(instance)
	_index = _index + 1
	return instance
