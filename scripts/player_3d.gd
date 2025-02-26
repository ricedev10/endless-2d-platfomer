class_name Player
extends CharacterBody3D

@onready var character_state = $"CharacterState"
@onready var roof_detector = $"RoofDetector"

const RUN_SPEED = 6.0
const SLIDE_SPEED = 5.5
const JUMP_VELOCITY = 4.0
const JUMP_SPEED = 5.5
const JUMP_GRAVITY = Vector3(0, -9.8, 0)
const FALL_GRAVITY = Vector3(0, -30.8, 0)

var slide_start_y: float # If sliding and going down, increase speed
var is_sliding: bool
var slide_start_direction: int # 1=right, -1=left, 0=not moving

var collision_shape_sizes = {
	"IDLE": {
		shape = {
			height = 1.2,
			radius = 0.245,
		},
		position = Vector3(0, 0.6, 0),
		rotation = Vector3(0, 0, 0),
	},
	"JUMP": {
		shape = {
			height = 1.2,
			radius = 0.245,
		},
		position = Vector3(0, 0.6, 0),
		rotation = Vector3(0, 0, 0),
	},
	"RUN": {
		shape = {
			height = 1.2,
			radius = 0.245,
		},
		position = Vector3(0, 0.6, 0),
		rotation = Vector3(0, 0, 0),
	},
	"CROUCH": {
		shape = {
			height = 0.8,
			radius = 0.4,
		},
		position = Vector3(0, 0.4, 0),
		rotation = Vector3(0, 0, 0),
	},
	"SLIDE": {
		shape = {
			height = 1.25,
			radius = 0.25,
		},
		position = Vector3(0, 0.3, 0),
		rotation = Vector3(0, 0, PI / 2) 
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
			velocity += FALL_GRAVITY * delta
		else:
			velocity += JUMP_GRAVITY * delta

	# Handle Sliding
	if Input.is_action_pressed("crouch") or roof_detector.get_collider():
		$"AnimatedSprite3D".animation = "slide"
		character_state.state = character_state.STATES.SLIDE
		if not is_sliding:
			slide_start_y = position.y
			is_sliding = true
			slide_start_direction = sign(velocity.x)
			if slide_start_direction == 0: 
				slide_start_direction = Input.get_axis("move_left", "move_right")
		if Input.is_action_pressed("move_left"):
			$"AnimatedSprite3D".flip_h = true
		elif Input.is_action_pressed("move_right"):
			$"AnimatedSprite3D".flip_h = false
			
		
		var increase_speed = slide_start_direction * (slide_start_y - position.y) * 50.0
		var goal = velocity.x
		print(increase_speed)
		
		velocity.x = lerp(SLIDE_SPEED * slide_start_direction, goal + increase_speed, delta * 5.0)
		
		move_and_slide()
		return
	else:
		is_sliding = false
		slide_start_y = 0.0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#input_dir.y = 0.0
	var direction := (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
	if direction:
		var speed = JUMP_SPEED if not is_on_floor() else RUN_SPEED
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 10.0)
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
