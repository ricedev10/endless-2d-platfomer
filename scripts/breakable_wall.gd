extends Node3D

const FRACTURE_INTENSITY: float = 8.0

@onready var static_body_3d: StaticBody3D = $StaticBody3D
var wall_broken: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Player) -> void:
	if not wall_broken and (body is Player) and body.is_sliding:
		wall_broken = true
		static_body_3d.queue_free()
		
		for child in self.get_children():
			if child is RigidBody3D:
				child.freeze = false
				child.apply_impulse(
					child.position * FRACTURE_INTENSITY, 
					self.global_position + Vector3(-10.0, 0, 0)
				)
		#var tween = get_tree().create_tween()
		#tween.tween_property(self, "position", Vector3(0, -10.0, 0), 2.0)
		await get_tree().create_timer(1.5).timeout
		for child in self.get_children():
			if child is RigidBody3D:
				child.queue_free()
		
