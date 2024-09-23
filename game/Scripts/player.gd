extends CharacterBody2D


@export var MAX_SPEED = 420.0
@export var JUMP_VELOCITY = -700.0
@export var WALL_SLIDE_SPEED = 100
@export var SLIDE_SPEED = 400
@export var CROUCH_SLOWDOWN = 0.5
@export var GRAVITY = 1200.0
@export var FALL_GRAVITY_MULTIPLIER = 1.5
@export var JUMP_GRAVITY_MULTIPLIER = 0.7
@export var DASH_SPEED = 600
@export var DASH_TIME = 0.2
const double_jump_modifier = 1.5
const acceleration = 5
var dir = 1 # 1 is right and -1 is left 0 is standing
var double_jump = 1
var dash_count = 1
var dashing = false
var dash_timer = 0.0
var max_slide_time = 2.0
var slide_time = max_slide_time
var last_dir = 0
var WJ_pushback = 420
var last_wall_dir = 0 # To track the direction of the last wall jump (left or right)
var running = false
var crouching = false
var run_multiplier = 3


func walking() -> void:
	# Accelerate when moving left or right
	if dir != 0:
		velocity.x += dir * (MAX_SPEED / acceleration)
		# Clamp the velocity to max speed when not running
		if not Input.is_action_pressed("run"):
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		# Decelerate smoothly when no input is given
		velocity.x = lerp(velocity.x, 0.0, 0.1)

	# Stop tiny movement to avoid sliding when very close to 0
	if abs(velocity.x) < 0.1:
		velocity.x = 0

func	 run() -> void:
	if dir != 0 and Input.is_action_pressed("sprint") and not is_on_wall():
		velocity.x += dir * (MAX_SPEED * run_multiplier / acceleration)
	velocity.x = clamp(velocity.x, -MAX_SPEED * run_multiplier, MAX_SPEED * run_multiplier)

func jump() -> void:
	if Input.is_action_just_pressed("jump"):
		# Ground jump
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			double_jump = 1  # Reset double jump when landing on the ground
			last_wall_dir = 0  # Reset wall jump tracking when on the ground

		# Double jump (in air, not on wall)
		elif not is_on_floor() and double_jump >= 1 and not is_on_wall():
			velocity.y = JUMP_VELOCITY / double_jump_modifier
			double_jump -= 1

		# Wall jump (ensure it's a different wall than last jump)
		elif is_on_wall() and last_dir != last_wall_dir:
			velocity.y = JUMP_VELOCITY
			velocity.x += WJ_pushback * -last_dir
			last_wall_dir = last_dir
			dir = -dir

func dash(delta) -> void:
	# Trigger dash if the player presses dash, is not on the ground, and has dashes available
	if Input.is_action_just_pressed("dash") and not is_on_floor() and dash_count > 0 and not dashing:
		dashing = true
		dash_timer = DASH_TIME  # Set dash duration
		velocity.x = DASH_SPEED * dir  # Set dash speed in the current direction
		velocity.y = 0  # Cancel vertical movement during the dash
		dash_count -= 1  # Decrease available dash count

	# Handle dash duration
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false  # End dash when the timer runs out

func wall_slide(delta: float) -> void:
	if is_on_wall() and not is_on_floor() and dir != 0:
		velocity.y = lerp(velocity.y, WALL_SLIDE_SPEED, delta * 0.5)
		velocity.y = clamp(velocity.y, -INF, WALL_SLIDE_SPEED)
	
func crouch_n_slide(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		if Input.is_action_pressed("sprint") and !crouching and abs(velocity.x) >= SLIDE_SPEED and slide_time > 0:
			# Player is sliding
			velocity.x = lerp(velocity.x, 0.0, delta * 2)
			slide_time -= delta
			crouching = true
			$"normal hitbox".disabled = true
			$"sliding hitbox".disabled = false
		else:
			# Player is crouching but not sliding
			velocity.x *= CROUCH_SLOWDOWN  # Reduce speed while crouching
			crouching = true
			$"normal hitbox".disabled = true
			$"sliding hitbox".disabled = false
	else:
		# Player is neither crouching nor sliding
		crouching = false
		slide_time = max_slide_time
		$"normal hitbox".disabled = false 
		$"sliding hitbox".disabled = true
		
func apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
	else:
		if velocity.y < 0:
			velocity.y += GRAVITY * JUMP_GRAVITY_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * FALL_GRAVITY_MULTIPLIER * delta

func reset_abilities_on_land(delta: float) -> void:
	if is_on_floor():
		double_jump = 1
		dash_count = 1
		slide_time = max_slide_time
		
	if not Input.is_action_pressed("down"):
		slide_time = clamp(slide_time + delta, 0, max_slide_time)

func _physics_process(delta: float) -> void:
	dir = Input.get_axis("left", "right")
	if dir != 0:
		last_dir = dir
	if is_on_wall() and not is_on_floor():
		wall_slide(delta)  # Perform wall sliding
	elif crouching:
		crouch_n_slide(delta)  # Handle crouching and sliding
	else:
		if Input.is_action_pressed("sprint"):
			run()  # Handle running
		else:
			walking()  # Handle walking
	jump()
	dash(delta)
	apply_gravity(delta)
	move_and_slide()
	reset_abilities_on_land(delta)

func	 _ready() -> void:
	$"normal hitbox".disabled = false
	$"sliding hitbox".disabled = true
