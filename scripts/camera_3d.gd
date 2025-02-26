extends Camera3D

@export var follow: Node3D
@export var smoothing_interpolation: float = 0.2
@export var interpolation_x: float = 0.9
@export var default_fov: float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var last_position: Vector3
func _process(delta: float) -> void:
	if follow:
		var velocity = ((follow.global_position - last_position) / delta).length()
		var added_fov = abs(velocity) * 1.9
		fov = lerp(fov, (default_fov + (added_fov)), 0.08)
		
		# Convert basis to quaternion, keep in mind scale is lost
		var camera_quaternion = Quaternion(global_basis)
		var goal_quaternion = Quaternion(follow.global_basis)
		# Interpolate using spherical-linear interpolation (SLERP).
		var interpolated = camera_quaternion.slerp(goal_quaternion, smoothing_interpolation) # find halfway point between a and b
		# Apply back
		global_basis = Basis(interpolated)
		
		var camera_position = global_position
		var goal_position = follow.global_position
		var interpolated_position = camera_position.lerp(goal_position, smoothing_interpolation)
		global_transform.origin = interpolated_position
		global_transform.origin.x = lerp(camera_position.x, goal_position.x, interpolation_x)
		
		last_position = follow.global_position
