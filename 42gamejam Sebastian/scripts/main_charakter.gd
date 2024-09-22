extends CharacterBody2D

var MAX_SPEED = 420.0
const JUMP_VELOCITY = -700.0
const acceleration = 5
var dir = 1 # 1 is right and -1 is left 0 is standing
var doubble_jump = 1
var dash_count = 1
var max_slide_time = 2.0
var slide_time = max_slide_time
var last_dir = 0
var WJ_pushback = 210
var wall_slide_fr = 100
var is_wall_sliding = false


func _physics_process(delta: float) -> void:
	dir = Input.get_axis("left", "right")
	if dir != 0:
		last_dir = dir
	run()
	dash()
	walking(delta)
	jump()
	wall_slide(delta)
	crouch_n_slide(delta)
	print(velocity.y)
	returning_the_points(delta)
	gravity(delta)
	move_and_slide()

func jump() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y += JUMP_VELOCITY
		if not is_on_floor() and doubble_jump >= 1 and not is_on_wall():
			velocity.y = 0
			velocity.y += JUMP_VELOCITY/1.5
			doubble_jump -= 1
		if is_on_wall() and not is_on_floor():
			velocity.y += JUMP_VELOCITY
			velocity.x = WJ_pushback * -last_dir
			dir = -dir

func wall_slide(delta):
	if is_on_wall() and not is_on_floor() and dir != 0:
		velocity.y += wall_slide_fr * delta
		velocity.y = min(velocity.y, wall_slide_fr)


func returning_the_points(delta):
	if is_on_floor():
		doubble_jump = 1
		dash_count = 1
	if not Input.is_action_pressed("down"):
		if slide_time != max_slide_time:
			slide_time += delta

func crouch_n_slide(delta):
	if Input.is_action_pressed("down") and abs(velocity.x) >= 210 and Input.is_action_pressed("run") and slide_time > 0:
		velocity.y += 420
		velocity.x = 1.5 * MAX_SPEED * last_dir
		slide_time -= delta
		$"normal hitbox".visible = false
		print(slide_time)
	elif Input.is_action_pressed("down"):
		velocity.y += 420
		velocity.x /= 1.5
		$"normal hitbox".visible = false
	else:
		$"normal hitbox".visible = true
	

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
#TODO: a slide and crouch function.


	
func gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
