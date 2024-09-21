extends CharacterBody2D

var MAX_SPEED = 420.0
const JUMP_VELOCITY = -700.0
const acceleration = 5
var dir = 1 # 1 is right and -1 is left 0 is standing
var doubble_jump = 1
var dash_count = 1


func _physics_process(delta: float) -> void:
	dir = Input.get_axis("left", "right")
	run()
	dash()
	walking(delta)
	gravity(delta)
	jump()
	
	returning_the_points()
	move_and_slide()

func jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y += JUMP_VELOCITY
	if not is_on_floor() and doubble_jump >= 1 and Input.is_action_just_pressed("ui_accept"):
		velocity.y = 0
		velocity.y += JUMP_VELOCITY/1.5
		doubble_jump -= 1
		
func returning_the_points():
	if is_on_floor():
		doubble_jump = 1
		dash_count = 1

func run()-> void:
	if dir != 0 and Input.is_action_pressed("run"):
		velocity.x += dir * (MAX_SPEED * 2 / acceleration)
	if abs(velocity.x) > MAX_SPEED * 2:
		velocity.x = MAX_SPEED * 2 * dir

func dash() -> void:
	if Input.is_action_just_pressed("dash") and not is_on_floor() and dash_count > 0:
		position.x += 500 * dir
		dash_count -= 1
		
func walking(delta) -> void:
	# Accelerate when moving left or right
	if dir != 0:
		velocity.x += dir * (MAX_SPEED / acceleration)
		
		# Clamp the velocity to the maximum speed
	if abs(velocity.x) > MAX_SPEED and not Input.is_action_pressed("run"):
		velocity.x = MAX_SPEED * dir
	else:
			# Decelerate smoothly when no input is given
		if velocity.x != 0:
			velocity.x = lerp(velocity.x, 0.0, 0.1)  # Lerp for smooth deceleration

		# Stop small movements (to avoid sliding)
	if abs(velocity.x) < 0.1:
		velocity.x = 0
	print(velocity.x)
#TODO: a slide and crouch function.


	
func gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
