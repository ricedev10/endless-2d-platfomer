class_name Level
extends Node3D

@export var start_marker: Marker3D
@export var end_marker: Marker3D

var chunk_position: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_level(chunk_position: int) -> void:
	pass

func unload_level() -> void:
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
