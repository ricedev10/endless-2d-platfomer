extends CharacterBody3D

@onready var character_state = $"CharacterState"
@onready var roof_detector = $"RoofDetector"

const MAX_SPEED = 4.0
const SPEED_ACCELERATION = 1.0
const JUMP_VELOCITY = 4.0
const JUMP_GRAVITY = Vector3(0, -30.0, 0)
const FALL_GRAVITY = Vector3(0, -9.8, 0)

var speed: float = 0.0
var collision_shape_sizes = {
	"IDLE": {
		shape = {
			height = 1.2,
			radius = 0.245,
		},
		position = Vector3(0, 0.6, 0),
	},
	"JUMP": {
		shape = {
			height = 1.2,
			radius = 0.245,
		},
		position = Vector3(0, 0.6, 0),
	},
	"RUN": {
		shape = {
			height = 1.2,
			radius = 0.245,
		},
		position = Vector3(0, 0.6, 0),
	},
	"CROUCH": {
		shape = {
			height = 0.8,
			radius = 0.4,
		},
		position = Vector3(0, 0.4, 0)
	},
	"SLIDE": {
		shape = {
			height = 0.4,
			radius = 0.3,
		},
		position = Vector3(0, 0.35, 0)
	}
}

func set_properties(object: Object, dictionary: Dictionary) -> void:
	for key in dictionary:
		var value = dictionary[key]
		if value is Dictionary:
			set_properties(object[key], value)
		else:
			object[key] = value

func on_state_changed(new_state) -> void:
	new_state = character_state.STATES.keys()[new_state]
	var properties = collision_shape_sizes[new_state]
	set_properties($"CollisionShape3D", properties)

func _ready() -> void:
	character_state.state_changed.connect(on_state_changed)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < 0.0:
			velocity += JUMP_GRAVITY * delta
		else:
			velocity += FALL_GRAVITY * delta

	# Handle Crouching
	if Input.is_action_pressed("crouch") or roof_detector.get_collider():
		$"AnimatedSprite3D".animation = "slide"
		character_state.state = character_state.STATES.SLIDE
		if Input.is_action_pressed("move_left"):
			$"AnimatedSprite3D".flip_h = true
		elif Input.is_action_pressed("move_right"):
			$"AnimatedSprite3D".flip_h = false
		
		velocity.x = move_toward(velocity.x, 0, delta)
		velocity.z = move_toward(velocity.z, 0, delta)
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_dir.y = 0.0
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		speed = lerp(speed, MAX_SPEED, 0.01)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)
	
	if direction.length() > 0.0:
		character_state.state = character_state.STATES.RUN
		$"AnimatedSprite3D".animation = "run"
		if velocity.x > 0.0:
			$"AnimatedSprite3D".flip_h = false
		else:
			$"AnimatedSprite3D".flip_h = true
	else:
		character_state.state = character_state.STATES.IDLE
		$"AnimatedSprite3D".animation = "idle"
	
	if not is_on_floor():
		$"AnimatedSprite3D".animation = "jump"
		character_state.state = character_state.STATES.JUMP



	move_and_slide()
