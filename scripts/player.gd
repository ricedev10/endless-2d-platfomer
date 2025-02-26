extends CharacterBody2D


const SPEED = 1000.0
const JUMP_VELOCITY = -1500.0
const JUMP_GRAVITY = Vector2(0.0, 2100.0)
const FALL_ACCELERATION = Vector2(0.0, 3280.0)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0.0:
			print("falling")
			velocity += FALL_ACCELERATION * delta
		else:
			velocity += JUMP_GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
