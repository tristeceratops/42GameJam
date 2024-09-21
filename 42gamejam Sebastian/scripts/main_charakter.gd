extends CharacterBody2D

var SPEED = 420.0
const JUMP_VELOCITY = -700.0
var dj = 1
var dsh = 1
var dir = 0
var running = false
var SLIDE_SPEED = 1500
var SLIDE_DURATION = 2.0
var sliding = false
var slide_timer = SLIDE_DURATION

func _physics_process(delta: float) -> void:
	run()

	# If sliding, update the slide timer
	if sliding:
		slide(delta)
	else:
		# Reset the slide timer when not sliding
		slide_timer = SLIDE_DURATION

		# Handle input direction and dashing
		if Input.is_action_just_pressed("left"):
			dir = 1
		elif Input.is_action_just_pressed("right"):
			dir = 0

		# Dash function
		if Input.is_action_just_pressed("dash") and not is_on_floor():
			dash()

		# Handle double jump
		if is_on_floor():
			dsh = 1
			dj = 1
		else:
			velocity += get_gravity() * delta
			if velocity.y > 600:
				velocity.y = 600

		# Handle jumps
		if dj == 1 and not is_on_floor() and Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			dj -= 1

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Handle movement
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Faster descend logic
		if Input.is_action_pressed("down"):
			velocity.y = 800
			velocity.x /= 2
			$"normal hitbox".visible = false
		else:
			$"normal hitbox".visible = true

		# Check if sliding conditions are met
		if running and is_on_floor() and Input.is_action_pressed("down"):
			# Ensure the slide only starts if the velocity is sufficient
			if abs(velocity.x) >= 200:  # Use an appropriate threshold
				slide_timer = SLIDE_DURATION  # Reset the timer when sliding starts
				sliding = true  # Start sliding

	move_and_slide()

func dash() -> void:
	if dir == 0 and dsh == 1:
		position.x += 300
	elif dir == 1 and dsh == 1:
		position.x -= 300
	dsh -= 1

func run() -> void:
	if Input.is_action_pressed("run") and Input.is_action_pressed("down") and not velocity.x >= 419:
		SPEED = 419
		running = false
	if Input.is_action_pressed("run") and not Input.is_action_pressed("down"):
		SPEED = 840
		running = true
	elif Input.is_action_just_released("run"):
		SPEED = 420
		running = false

func slide(delta: float) -> void:
	if slide_timer > 0:
		# Set velocity based on direction
		velocity.x = SLIDE_SPEED if dir == 0 else -SLIDE_SPEED
		slide_timer -= delta  # Decrease slide timer
	else:
		sliding = false  # Stop sliding if timer runs out
		velocity.x = 0  # Stop movement after sliding

	# Stop sliding if "down" or "run" is released
	if Input.is_action_just_released("down") or Input.is_action_just_released("run"):
		sliding = false  # Reset sliding state when buttons are released
		velocity.x = 0  # Ensure to stop movement
