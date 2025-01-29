extends CharacterBody3D


const SPEED = 3.6
const JUMP_VELOCITY = 4.5
const JUMP_GRAVITY = Vector3(0, -9.8, 0)
const FALL_GRAVITY = Vector3(0, -15.8, 0)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y <= 0:
			velocity += FALL_GRAVITY * delta
		else:
			velocity += JUMP_GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if direction.length() > 0.0:
		# we are moving; change to RUN animation
		$"PaperCharacter/AnimationPlayer".current_animation = "Run"
	else:
		# we are not moving; change to IDLE animation
		$"PaperCharacter/AnimationPlayer".current_animation = "Idle"

	move_and_slide()
