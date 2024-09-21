extends CharacterBody2D


const SPEED = 420.0
const JUMP_VELOCITY = -2100.0
var dj = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > 600:
			velocity.y = 600
	
	if dj == 1 and not is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		dj -= 1
	if is_on_floor():
		dj = 1

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# faster decend
	if Input.is_action_pressed("down"):
		velocity.y = 800
		velocity.x /= 2
		

	move_and_slide()
